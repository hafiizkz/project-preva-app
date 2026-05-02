import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/post_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/post_card.dart';
import '../post/detail_post_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FirestoreService _service = FirestoreService();
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorit Saya")),
      body: StreamBuilder<List<PostModel>>(
        stream: _service.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final favPosts = snapshot.data?.where((p) => p.favorites.contains(_uid)).toList() ?? [];

          if (favPosts.isEmpty) {
            return const Center(
              child: Text("Belum ada favorit.", style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: favPosts.length,
            itemBuilder: (context, index) {
              final post = favPosts[index];
              return PostCard(
                post: post,
                isAdmin: false, 
                isOwner: post.userId == _uid,
                onDelete: () => _service.deletePost(post.id),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPostScreen(post: post))),
              );
            },
          );
        },
      ),
    );
  }
}