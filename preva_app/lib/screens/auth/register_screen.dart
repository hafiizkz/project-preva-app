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
  bool _isLoading = false; 

  String _selectedRole = "karyawan"; 

  void _handleRegister() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan Password wajib diisi")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final String? error = await _authService.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
      _selectedRole,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (error == null) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Cek mode gelap
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // 2. Background adaptif
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.blue[50],
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Icon(Icons.person_add_rounded, size: 80, color: isDark ? Colors.lightBlueAccent : Colors.lightBlue),
            const SizedBox(height: 20),
            Text(
              "Daftar Akun Preva",
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.lightBlueAccent : Colors.lightBlue
              ),
            ),
            const SizedBox(height: 30),
            
            CustomTextField(controller: _nameController, label: "Nama Lengkap", icon: Icons.person),
            const SizedBox(height: 15),
            CustomTextField(controller: _emailController, label: "Email", icon: Icons.email),
            const SizedBox(height: 15),
            CustomTextField(controller: _passwordController, label: "Password", icon: Icons.lock, isPassword: true),
            const SizedBox(height: 15),
            
            // Dropdown Role Adaptif
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                // 3. Warna box dropdown: Slate gelap jika Dark Mode
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: isDark ? Border.all(color: Colors.blueGrey.withOpacity(0.3)) : null,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  // 4. Warna popup menu dropdown
                  dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
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
              ? const CircularProgressIndicator(color: Colors.lightBlueAccent)
              : CustomButton(text: "DAFTAR", onPressed: _handleRegister),
          ],
        ),
      ),
    );
  }
}