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
  // === VARIABEL INI YANG TADI TERHAPUS ===
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  // === FUNGSI INI JUGA TADI TERHAPUS ===
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
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // === LOGO BARU PREVA APP ===
              Image.asset(
                'lib/img/logo.png',
                width: 200, 
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
            
              const Text(
                "Hardware & Software Maintenance", 
                style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              
              // === INPUT TEXTFIELD ===
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
              
              // === TOMBOL MASUK ===
              CustomButton(
                text: "MASUK", 
                onPressed: _handleLogin
              ),
              const SizedBox(height: 20),
              
              // === TOMBOL DAFTAR ===
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                },
                child: const Text(
                  "Belum punya akun? Daftar di sini", 
                  style: TextStyle(color: Colors.lightBlue)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}