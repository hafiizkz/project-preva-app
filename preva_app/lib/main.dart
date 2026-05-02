import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/main_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PrevaApp());
}

class PrevaApp extends StatefulWidget {
  const PrevaApp({super.key});

  static PrevaAppState of(BuildContext context) =>
      context.findAncestorStateOfType<PrevaAppState>()!;

  @override
  State<PrevaApp> createState() => PrevaAppState();
}

class PrevaAppState extends State<PrevaApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Preva App',
      
      // TEMA TERANG
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.blue[50],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),

      // TEMA GELAP (CINEMATIC & HIGH CONTRAST)
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.lightBlue,
        scaffoldBackgroundColor: const Color(0xFF020617), // Deep Black-Navy
        cardColor: const Color(0xFF1E293B),
        // Paksa teks menjadi putih terang agar tidak nyaru
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      
      themeMode: _themeMode,
      home: StreamBuilder(
        stream: AuthService().userStatus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.hasData ? const MainScreen() : const LoginScreen();
        },
      ),
    );
  }
}