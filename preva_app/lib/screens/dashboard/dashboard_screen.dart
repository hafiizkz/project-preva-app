import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../widgets/post_card.dart';
import '../../services/firestore_service.dart';
import '../notification/notification_screen.dart'; 
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

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  
  // === VARIABEL FILTER BARU ===
  String _selectedCategory = "Semua";
  final List<String> _categories = ["Semua", "Hardware", "Software"];

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
        title: Image.asset(
          'lib/img/logo2.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.lightBlueAccent),
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
                Text(_name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                Text(
                  _role.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.lightBlueAccent),
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
      body: Column(
        children: [
          // === SEARCH BAR + FILTER BUTTON ===
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Cari laporan...",
                      prefixIcon: const Icon(Icons.search, color: Colors.lightBlueAccent),
                      filled: true,
                      fillColor: isDark ? Colors.white10 : Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // TOMBOL FILTER KATEGORI
                Container(
                  decoration: BoxDecoration(
                    color: _selectedCategory == "Semua" 
                        ? (isDark ? Colors.white10 : Colors.white)
                        : Colors.lightBlueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.filter_list_rounded, 
                      color: _selectedCategory == "Semua" ? Colors.grey : Colors.lightBlueAccent
                    ),
                    onSelected: (String value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return _categories.map((String cat) {
                        return PopupMenuItem<String>(
                          value: cat,
                          child: Text(cat, style: TextStyle(
                            color: _selectedCategory == cat ? Colors.lightBlueAccent : null,
                            fontWeight: _selectedCategory == cat ? FontWeight.bold : null,
                          )),
                        );
                      }).toList();
                    },
                  ),
                ),
              ],
            ),
          ),

          // LIST POSTINGAN
          Expanded(
            child: StreamBuilder<List<PostModel>>(
              stream: _service.getPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Belum ada laporan."));

                // === LOGIKA FILTERING GANDA: Search + Kategori ===
                final filteredPosts = snapshot.data!.where((post) {
                  final matchesSearch = post.title.toLowerCase().contains(_searchQuery);
                  final matchesCategory = _selectedCategory == "Semua" || post.category == _selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredPosts.isEmpty) {
                  return const Center(child: Text("Laporan tidak ditemukan."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filteredPosts.length,
                  itemBuilder: (context, index) {
                    final post = filteredPosts[index];
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPostScreen())),
        backgroundColor: Colors.lightBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}