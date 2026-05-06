import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'register_screen.dart';
import '../dashboard/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  void _handleLogin() async {
    final error = await _authService.signIn(_emailController.text, _passwordController.text);

    if (error == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
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
    // 1. Cek apakah sedang dalam mode gelap
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // 2. Background dinamis: Biru muda jika terang, Slate gelap jika Dark Mode
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO PREVA APP
              Image.asset(
                'lib/img/logo.png',
                width: 200, 
                fit: BoxFit.contain,
                // Opsional: Jika logo kamu warna gelap, bisa pakai colorFilter agar putih saat Dark Mode
                color: isDark ? Colors.white : null, 
              ),
              const SizedBox(height: 10),
            
              Text(
                "Hardware & Software Maintenance", 
                style: TextStyle(
                  // 3. Warna teks deskripsi yang adaptif
                  color: isDark ? Colors.blueGrey[300] : Colors.blueGrey, 
                  fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 40),
              
              // INPUT TEXTFIELD
              // (Pastikan CustomTextField kamu sudah menggunakan Theme.of(context).cardColor atau sejenisnya)
              CustomTextField(
                controller: _emailController, 
                label: "Email", 
                icon: Icons.email
              ),
              const SizedBox(height: 15),
              CustomTextField(
                controller: _passwordController, 
                label: "Password", 
                icon: Icons.lock, 
                isPassword: true
              ),
              const SizedBox(height: 30),
              
              // TOMBOL MASUK
              CustomButton(
                text: "MASUK", 
                onPressed: _handleLogin
              ),
              const SizedBox(height: 20),
              
              // TOMBOL DAFTAR
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                },
                child: Text(
                  "Belum punya akun? Daftar di sini", 
                  style: TextStyle(
                    // 4. Warna link yang lebih cerah di mode gelap agar kontras
                    color: isDark ? Colors.lightBlueAccent : Colors.lightBlue,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}