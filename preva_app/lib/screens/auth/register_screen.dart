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

  String _selectedRole = "karyawan"; // Default role

  void _handleRegister() async {
    final error = await _authService.signUp(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
      _selectedRole,
    );

    if (error == null) {
      if (mounted) Navigator.pop(context); // Kembali ke login setelah sukses
    } else {
      if (mounted) {
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
            
            // Dropdown Pemilihan Role
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
            CustomButton(text: "DAFTAR", onPressed: _handleRegister),
          ],
        ),
      ),
    );
  }
}