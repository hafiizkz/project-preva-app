import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/post_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_button.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _service = FirestoreService();
  final ImagePicker _picker = ImagePicker();

  String _category = "Hardware";
  String _subCategory = "RAM";
  String _condition = "Baik";
  String _imageBase64 = ""; 
  Uint8List? _webImage;

  final List<String> _hwList = ["RAM", "SSD", "Monitor", "Mouse", "VGA"];
  final List<String> _swList = ["Microsoft Office", "Sistem Operasi", "Lisensi Lainnya"];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (image != null) {
      Uint8List bytes = await image.readAsBytes();
      setState(() {
        _webImage = bytes;
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Buat Laporan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Preview Image Box
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.lightBlue.withOpacity(0.3)),
                ),
                child: _webImage == null
                    ? const Icon(Icons.add_a_photo, size: 40, color: Colors.lightBlue)
                    : ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.memory(_webImage!, fit: BoxFit.cover)),
              ),
            ),
            const SizedBox(height: 25),

            // INPUTS: Menggunakan warna dinamis
            _buildInputLabel("Judul Perangkat"),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 15),

            _buildInputLabel("Kategori"),
            DropdownButtonFormField(
              value: _category,
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              items: ["Hardware", "Software"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() {
                _category = val.toString();
                _subCategory = _category == "Hardware" ? _hwList[0] : _swList[0];
              }),
            ),
            const SizedBox(height: 15),

            _buildInputLabel("Sub Kategori"),
            DropdownButtonFormField(
              value: _subCategory,
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              items: (_category == "Hardware" ? _hwList : _swList).map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _subCategory = val.toString()),
            ),
            const SizedBox(height: 15),

            _buildInputLabel("Kondisi"),
            DropdownButtonFormField(
              value: _condition,
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              items: ["Baik", "Rusak", "Perlu Maintenance"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _condition = val.toString()),
            ),
            const SizedBox(height: 15),

            _buildInputLabel("Deskripsi Masalah"),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 30),

            CustomButton(
              text: "KIRIM LAPORAN", 
              onPressed: () async {
                if (_titleController.text.isEmpty || _imageBase64.isEmpty) return;
                final user = FirebaseAuth.instance.currentUser!;
                final newPost = PostModel(
                  id: "", 
                  userId: user.uid,
                  userName: user.displayName ?? "User",
                  userRole: "karyawan",
                  title: _titleController.text,
                  category: _category,
                  subCategory: _subCategory,
                  condition: _condition,
                  description: _descController.text,
                  locationName: "Office",
                  latitude: "0", longitude: "0",
                  imageUrl: _imageBase64,
                  timestamp: DateTime.now(),
                  favorites: [],
                );
                await _service.createPost(newPost);
                if (mounted) Navigator.pop(context);
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 5, bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}