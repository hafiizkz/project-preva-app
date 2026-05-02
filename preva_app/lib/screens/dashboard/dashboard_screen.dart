import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../widgets/post_card.dart';
import '../../services/firestore_service.dart';
import '../notification/notification_screen.dart'; // Import layar baru
import '../post/add_post_screen.dart';
import '../post/detail_post_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _service = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _name = "Memuat...";
  String _role = "User";
  String _profilePicBase64 = "";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).get();
      if (doc.exists && mounted) {
        UserModel user = UserModel.fromMap(doc.data()!);
        setState(() {
          _name = user.name;
          _role = user.role;
          _profilePicBase64 = user.profilePic;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Preva App", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // TOMBOL NOTIFIKASI
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
            },
          ),
          const SizedBox(width: 5),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(
                  _role.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isDark ? Colors.lightBlueAccent : Colors.blue.shade900),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: isDark ? Colors.white12 : Colors.white24,
              child: _profilePicBase64.isNotEmpty
                  ? ClipOval(child: Image.memory(base64Decode(_profilePicBase64), fit: BoxFit.cover, width: 36, height: 36))
                  : const Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<PostModel>>(
        stream: _service.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Belum ada laporan."));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final post = snapshot.data![index];
              return PostCard(
                post: post,
                isAdmin: _role == "admin", 
                isOwner: post.userId == _auth.currentUser!.uid,
                onDelete: () => _service.deletePost(post.id),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPostScreen(post: post))),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPostScreen())),
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}