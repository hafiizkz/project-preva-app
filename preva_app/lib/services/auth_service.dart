import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Cek perubahan status login (Sign In / Sign Out)
  Stream<User?> get userStatus => _auth.authStateChanges();

  // Fungsi Daftar (Sign Up) dengan Role
  Future<String?> signUp(String email, String password, String name, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Simpan data tambahan user ke Firestore
      UserModel newUser = UserModel(
        uid: result.user!.uid,
        name: name,
        email: email,
        role: role,
      );

      await _db.collection('users').doc(result.user!.uid).set(newUser.toMap());
      return null; // Berhasil
    } catch (e) {
      return e.toString(); // Kirim pesan error
    }
  }

  // Fungsi Masuk (Sign In)
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Fungsi Keluar (Sign Out)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}