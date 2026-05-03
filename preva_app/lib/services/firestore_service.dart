import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Ambil Semua Postingan
  Stream<List<PostModel>> getPosts() {
    return _db.collection('posts').orderBy('timestamp', descending: true).snapshots().map(
      (s) => s.docs.map((d) => PostModel.fromMap(d.data(), d.id)).toList());
  }

  // 2. Ambil Notifikasi (Hanya untuk user yang sedang login)
  Stream<QuerySnapshot> getNotifications(String uid) {
    return _db.collection('notifications')
        .where('toUserId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 3. Fitur Toggle Favorit (Love)
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

  // 4. INI FUNGSI YANG BIKIN MERAH (Tambah Komentar & Kirim Notif)
  Future<void> addComment(String postId, String postOwnerId, Map<String, dynamic> commentData) async {
    // Simpan komentar ke sub-koleksi 'comments' di dalam dokumen post
    await _db.collection('posts').doc(postId).collection('comments').add(commentData);

    // Kirim notifikasi ke pemilik postingan (jika yang komen bukan pemiliknya sendiri)
    if (commentData['userId'] != postOwnerId) {
      await _db.collection('notifications').add({
        'toUserId': postOwnerId,
        'fromUserName': commentData['userName'],
        'postId': postId,
        'message': "mengomentari laporanmu: '${commentData['comment']}'",
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }

  // 5. Fitur Standar CRUD
  Future<void> updatePost(String id, Map<String, dynamic> data) async => await _db.collection('posts').doc(id).update(data);
  Future<void> createPost(PostModel post) async => await _db.collection('posts').add(post.toMap());
  Future<void> deletePost(String id) async => await _db.collection('posts').doc(id).delete();
}