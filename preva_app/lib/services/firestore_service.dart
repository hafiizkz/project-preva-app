import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Mendapatkan semua post
  Stream<List<PostModel>> getPosts() {
    return _db.collection('posts').orderBy('timestamp', descending: true).snapshots().map(
      (s) => s.docs.map((d) => PostModel.fromMap(d.data(), d.id)).toList());
  }

  // FIX: Fungsi ini untuk menghilangkan error di NotificationScreen kamu
  Stream<QuerySnapshot> getNotifications(String uid) {
    return _db.collection('notifications')
        .where('toUserId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Fitur Toggle Favorit (Love)
  Future<void> toggleFavorite(String postId, String userId) async {
    final docRef = _db.collection('posts').doc(postId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    List favorites = List.from(doc.data()?['favorites'] ?? []);
    if (favorites.contains(userId)) {
      await docRef.update({'favorites': FieldValue.arrayRemove([userId])});
    } else {
      await docRef.update({'favorites': FieldValue.arrayUnion([userId])});
    }
  }

  // Update & Create tetap seperti sebelumnya...
  Future<void> updatePost(String id, Map<String, dynamic> data) async => await _db.collection('posts').doc(id).update(data);
  Future<void> createPost(PostModel post) async => await _db.collection('posts').add(post.toMap());
  Future<void> deletePost(String id) async => await _db.collection('posts').doc(id).delete();
}