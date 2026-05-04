import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; 
import '../../models/post_model.dart';
import '../../services/auth_service.dart';

class DetailPostScreen extends StatefulWidget {
  final PostModel post;
  const DetailPostScreen({super.key, required this.post});

  @override
  State<DetailPostScreen> createState() => _DetailPostScreenState();
}

class _DetailPostScreenState extends State<DetailPostScreen> {
  final AuthService _authService = AuthService();
  final _auth = FirebaseAuth.instance;
  final _commentController = TextEditingController();
  late bool _isFavorited;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.post.favorites.contains(_auth.currentUser!.uid);
  }

  Future<void> _launchMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${widget.post.latitude},${widget.post.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;
    
    final user = _auth.currentUser!;
    final userDoc = await _authService.getUserData(user.uid);
    final userData = userDoc.data();

    final String userName = userData?['name'] ?? "User";
    final String userProfilePic = userData?['profilePic'] ?? "";
    final String commentText = _commentController.text.trim();

    final commentData = {
      'userId': user.uid,
      'userName': userName,
      'userProfilePic': userProfilePic,
      'comment': commentText,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('comments')
        .add(commentData);

    if (widget.post.userId != user.uid) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'toUserId': widget.post.userId,
        'fromUserId': user.uid,
        'fromUserName': userName,
        'fromUserProfilePic': userProfilePic,
        'comment': commentText,
        'postId': widget.post.id,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }

    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String formattedDate = DateFormat('dd MMM yyyy').format(widget.post.timestamp);
    String formattedTime = DateFormat('HH:mm').format(widget.post.timestamp);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                stretch: true,
                backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: widget.post.imageUrl.isNotEmpty
                      ? Image.memory(base64Decode(widget.post.imageUrl), fit: BoxFit.cover)
                      : Container(color: Colors.grey[300]),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: const BackButton(color: Colors.white),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black26,
                      child: IconButton(
                        icon: Icon(_isFavorited ? Icons.favorite : Icons.favorite_border,
                                   color: _isFavorited ? Colors.redAccent : Colors.white),
                        onPressed: () async {
                          setState(() => _isFavorited = !_isFavorited);
                          await FirebaseFirestore.instance.collection('posts').doc(widget.post.id).update({
                            'favorites': _isFavorited 
                                ? FieldValue.arrayUnion([_auth.currentUser!.uid])
                                : FieldValue.arrayRemove([_auth.currentUser!.uid])
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF020617) : Colors.blue[50]?.withOpacity(0.5),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- INFO PENGUNGGAH ---
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.lightBlueAccent.withOpacity(0.2),
                              backgroundImage: widget.post.userProfilePic.isNotEmpty 
                                  ? MemoryImage(base64Decode(widget.post.userProfilePic)) 
                                  : null,
                              child: widget.post.userProfilePic.isEmpty 
                                  ? const Icon(Icons.person, color: Colors.lightBlueAccent) 
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.post.userName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        "$formattedDate  •  $formattedTime",
                                        style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        // --- DIVIDER BARU (PEMBATAS PROFIL KE JUDUL) ---
                        const Divider(height: 40, thickness: 1),

                        // BARIS 1: JUDUL & BADGE KONDISI
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.post.title,
                                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _buildConditionBadge(widget.post.condition),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // BARIS 2: KATEGORI & SUB KATEGORI
                        Row(
                          children: [
                            Text(
                              widget.post.category.toUpperCase(),
                              style: const TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                            ),
                            const Text("  •  ", style: TextStyle(color: Colors.grey)),
                            Text(
                              widget.post.subCategory,
                              style: const TextStyle(color: Color.fromARGB(255, 0, 163, 22), fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                        
                        const Divider(height: 50, thickness: 1),

                        const Text("Deskripsi Kerusakan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(
                          widget.post.description,
                          style: TextStyle(fontSize: 15, height: 1.6, color: isDark ? Colors.white70 : Colors.black87),
                        ),

                        const SizedBox(height: 35),
                        _buildLocationCard(isDark),
                        const SizedBox(height: 40),

                        // DISKUSI HEADER
                        const Row(
                          children: [
                            Icon(Icons.forum_rounded, color: Colors.lightBlueAccent, size: 24),
                            SizedBox(width: 10),
                            Text("Diskusi Tim", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        _buildCommentList(widget.post.id, isDark),
                        const SizedBox(height: 130),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          _buildStickyInput(isDark),
        ],
      ),
    );
  }

  // ... Widget helper lainnya tetap sama (_buildConditionBadge, _buildLocationCard, _buildCommentList, _buildStickyInput)
  
  Widget _buildConditionBadge(String condition) {
    bool isBad = condition.toLowerCase().contains("rusak");
    Color color = isBad ? Colors.redAccent : Colors.teal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        condition.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
      ),
    );
  }

  Widget _buildLocationCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Titik Lokasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text("${widget.post.latitude}, ${widget.post.longitude}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _launchMaps,
              icon: const Icon(Icons.map_rounded, color: Colors.white, size: 20),
              label: const Text("BUKA DI GOOGLE MAPS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentList(String postId, bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').orderBy('timestamp', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final docs = snapshot.data!.docs;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: docs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 15),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final commentId = docs[index].id;
            final bool isMyComment = data['userId'] == _auth.currentUser!.uid;
            final String picBase64 = data['userProfilePic'] ?? "";

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.lightBlueAccent.withOpacity(0.2),
                    backgroundImage: picBase64.isNotEmpty ? MemoryImage(base64Decode(picBase64)) : null,
                    child: picBase64.isEmpty ? const Icon(Icons.person, color: Colors.lightBlueAccent, size: 18) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['userName'] ?? "User", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.lightBlueAccent)),
                        const SizedBox(height: 4),
                        Text(data['comment'] ?? "", style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87)),
                      ],
                    ),
                  ),
                  if (isMyComment)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                      onPressed: () => _confirmDeleteComment(postId, commentId),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteComment(String postId, String commentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Komentar?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').doc(commentId).delete();
              if (mounted) Navigator.pop(context);
            }, 
            child: const Text("Hapus", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  Widget _buildStickyInput(bool isDark) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: MediaQuery.of(context).padding.bottom + 10, top: 15),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A).withOpacity(0.95) : Colors.white.withOpacity(0.95),
          border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Berikan saran...",
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendComment,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Colors.lightBlueAccent, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}