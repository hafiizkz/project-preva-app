import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. SINGLETON PATTERN
  // Biar instance AuthService tetap satu dan konsisten di seluruh aplikasi
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // 2. STREAM STATUS LOGIN
  Stream<User?> get userStatus => _auth.authStateChanges();

  // 3. AMBIL DATA USER (Untuk Foto Profil & Nama di Komentar)
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  // 4. FUNGSI LOGIN (Return String? untuk handle error di UI)
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; 
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'Email tidak ditemukan.';
      if (e.code == 'wrong-password') return 'Password salah.';
      return e.message ?? 'Terjadi kesalahan saat login.';
    } catch (e) {
      return 'Gagal terhubung ke sistem.';
    }
  }

  // 5. FUNGSI LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 6. FUNGSI DAFTAR (REGISTER)
  Future<String?> signUp(String email, String password, String name, String role) async {
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      if (res.user != null) {
        await _db.collection('users').doc(res.user!.uid).set({
          'uid': res.user!.uid,
          'name': name,
          'email': email,
          'role': role,
          'profilePic': "", 
          'createdAt': FieldValue.serverTimestamp(),
        });
        await res.user!.updateDisplayName(name);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') return 'Password terlalu lemah.';
      if (e.code == 'email-already-in-use') return 'Email sudah terdaftar.';
      return e.message ?? 'Terjadi kesalahan.';
    } catch (e) {
      return e.toString();
    }
  }

  // 7. FUNGSI HAPUS KOMENTAR (YANG TADI KETINGGALAN, ANJAY!)
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _db
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      print("Gagal hapus komentar: $e");
    }
  }
}