import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../main.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isEditing = false;
  UserModel? _user;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _passController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _user = UserModel.fromMap(doc.data()!);
          _nameController = TextEditingController(text: _user!.name);
          _emailController = TextEditingController(text: _user!.email);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat data: $e");
    }
  }

  Future<void> _updateProfilePic() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );
    if (image != null) {
      Uint8List imageBytes = await image.readAsBytes();
      String base64String = base64Encode(imageBytes);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'profilePic': base64String});

      _fetchUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto profil diperbarui!")),
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ganti Password"),
        content: TextField(
          controller: _passController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: "Password baru minimal 6 karakter",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_passController.text.length < 6) return;
              try {
                await _auth.currentUser!.updatePassword(
                  _passController.text.trim(),
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Berhasil diubah!")),
                  );
                  _passController.clear();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check, size: 28, color: Colors.lightBlue),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(_auth.currentUser!.uid)
                    .update({
                  'name': _nameController.text.trim(),
                  'email': _emailController.text.trim(),
                });
                setState(() => _isEditing = false);
                _fetchUserData();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.lightBlue, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      child: _user!.profilePic.isNotEmpty
                          ? ClipOval(
                              child: Image.memory(
                                base64Decode(_user!.profilePic),
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            )
                          : const Icon(Icons.person, size: 60, color: Colors.lightBlue),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _updateProfilePic,
                      child: const CircleAvatar(
                        backgroundColor: Colors.lightBlue,
                        radius: 18,
                        child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Nama (Tanpa pensil di sini)
            _isEditing
                ? TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: "Nama"),
                  )
                : Text(
                    _user!.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
            
            Text(
              _user!.role.toUpperCase(),
              style: const TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  // Email Satu Baris + Pensil Pindah Ke Sini
                  _buildInlineRowTile(
                    Icons.email_outlined,
                    "Email",
                    controller: _emailController,
                    isEdit: _isEditing,
                    // Ikon pensil muncul di sini jika tidak sedang mengedit
                    trailing: _isEditing 
                        ? null 
                        : IconButton(
                            icon: const Icon(Icons.edit_note, color: Colors.lightBlue),
                            onPressed: () => setState(() => _isEditing = true),
                          ),
                  ),
                  const Divider(height: 1, indent: 50),
                  _buildInlineRowTile(
                    Icons.lock_outline,
                    "Ganti Password",
                    onTap: _showChangePasswordDialog,
                  ),
                  const Divider(height: 1, indent: 50),
                  _buildInlineRowTile(
                    Icons.dark_mode_outlined,
                    "Mode Gelap",
                    trailing: Switch(
                      value: isDark,
                      activeThumbColor: Colors.lightBlue,
                      onChanged: (val) => PrevaApp.of(context).changeTheme(val ? ThemeMode.dark : ThemeMode.light),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            CustomButton(
              text: "LOGOUT",
              color: Colors.redAccent,
              onPressed: () async {
                await AuthService().signOut();
                if (mounted) {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget baru untuk tampilan satu baris (Inline)
  Widget _buildInlineRowTile(
    IconData icon,
    String title, {
    TextEditingController? controller,
    bool isEdit = false,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.lightBlue),
      title: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          if (controller != null) ...[
            const Text(" : ", style: TextStyle(fontWeight: FontWeight.w500)),
            Expanded(
              child: isEdit
                  ? TextField(
                      controller: controller,
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  : Text(
                      controller.text,
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ]
        ],
      ),
      trailing: trailing,
    );
  }
}