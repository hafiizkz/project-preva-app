import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false; // Tambahan state loading agar lebih pro

  String _selectedRole = "karyawan"; 

  void _handleRegister() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password wajib diisi")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Sekarang error akan menerima String? dari AuthService
    final String? error = await _authService.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
      _selectedRole,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (error == null) {
        // Sukses, kembali ke login
        Navigator.pop(context);
      } else {
        // Gagal, tampilkan pesan error yang warna merah tadi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Icon(Icons.person_add_rounded, size: 80, color: Colors.lightBlue),
            const SizedBox(height: 20),
            const Text(
              "Daftar Akun Preva",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.lightBlue),
            ),
            const SizedBox(height: 30),
            CustomTextField(controller: _nameController, label: "Nama Lengkap", icon: Icons.person),
            const SizedBox(height: 15),
            CustomTextField(controller: _emailController, label: "Email", icon: Icons.email),
            const SizedBox(height: 15),
            CustomTextField(controller: _passwordController, label: "Password", icon: Icons.lock, isPassword: true),
            const SizedBox(height: 15),
            
            // Dropdown Role
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: "admin", child: Text("Admin")),
                    DropdownMenuItem(value: "karyawan", child: Text("Karyawan")),
                  ],
                  onChanged: (val) => setState(() => _selectedRole = val!),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _isLoading 
              ? const CircularProgressIndicator()
              : CustomButton(text: "DAFTAR", onPressed: _handleRegister),
          ],
        ),
      ),
    );
  }
}