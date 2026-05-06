import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Deteksi Mode Gelap
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        // 2. Warna background field: Slate gelap jika Dark Mode, Putih jika Terang
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark) // Shadow hanya muncul di mode terang agar tidak kusam di mode gelap
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        // 3. Warna teks saat mengetik
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          // 4. Warna label (teks yang melayang)
          labelStyle: TextStyle(
            color: isDark ? Colors.blueGrey[300] : Colors.blueGrey,
          ),
          // 5. Warna Icon
          prefixIcon: Icon(
            icon, 
            color: isDark ? Colors.lightBlueAccent : Colors.lightBlue
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}