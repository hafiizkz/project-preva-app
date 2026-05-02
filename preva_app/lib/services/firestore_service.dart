import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<PostModel>> getPosts() {
    return _db.collection('posts').orderBy('timestamp', descending: true).snapshots().map(
      (s) => s.docs.map((d) => PostModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> createPost(PostModel post) async {
    await _db.collection('posts').add(post.toMap());
  }

  Future<void> updatePost(String id, Map<String, dynamic> data) async {
    await _db.collection('posts').doc(id).update(data);
  }

  Future<void> deletePost(String id) async {
    await _db.collection('posts').doc(id).delete();
  }

  Stream<QuerySnapshot> getComments(String postId) {
    return _db.collection('posts').doc(postId).collection('comments').orderBy('timestamp').snapshots();
  }

  Future<void> addComment(String postId, Map<String, dynamic> data) async {
    await _db.collection('posts').doc(postId).collection('comments').add(data);
  }
}