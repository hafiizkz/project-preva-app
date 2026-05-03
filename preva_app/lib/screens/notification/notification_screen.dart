import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/post_model.dart';
import '../post/detail_post_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : Colors.blue[50],
      appBar: AppBar(
        title: const Text("Notifikasi", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // PERBAIKAN UTAMA: Hapus orderBy di sini untuk menghindari Error Composite Index Firestore
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('toUserId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          // Tambahan: Tangkap error jika ada masalah dari Firebase agar tidak diam-diam hilang
          if (snapshot.hasError) {
            return const Center(child: Text("Terjadi kesalahan sinkronisasi data."));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada notifikasi."));
          }

          // PERBAIKAN KEDUA: Kita urutkan datanya secara manual di dalam aplikasi (Dart)
          // Ini trik paling ampuh agar tidak perlu setting Index di web Firebase.
          final docs = snapshot.data!.docs.toList();
          docs.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            final Timestamp? timeA = dataA['timestamp'] as Timestamp?;
            final Timestamp? timeB = dataB['timestamp'] as Timestamp?;
            
            // Jika ada komentar baru yang timestamp-nya belum ke-generate dari server
            if (timeA == null) return -1;
            if (timeB == null) return 1;
            
            // Urutkan dari yang terbaru (Descending)
            return timeB.compareTo(timeA);
          });

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(15),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String picBase64 = data['fromUserProfilePic'] ?? "";

              return Card(
                elevation: 0,
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  onTap: () => _goToDetail(context, data['postId']),
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.lightBlue.withOpacity(0.1),
                    backgroundImage: picBase64.isNotEmpty ? MemoryImage(base64Decode(picBase64)) : null,
                    child: picBase64.isEmpty ? const Icon(Icons.person, color: Colors.lightBlue) : null,
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
                      children: [
                        TextSpan(text: data['fromUserName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: " mengomentari laporan Anda."),
                      ],
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      "\"${data['comment']}\"",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis, // Typo sebelumnya sudah diperbaiki di sini
                      style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.grey),
                    ),
                  ),
                  trailing: Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: data['isRead'] == false ? Colors.lightBlueAccent : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // FUNGSI: Mengambil data post lalu pindah ke DetailPostScreen
  void _goToDetail(BuildContext context, String postId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
      if (doc.exists) {
        final post = PostModel.fromMap(doc.data()!, doc.id);
        if (context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPostScreen(post: post)));
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Laporan ini sudah dihapus.")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error navigasi notifikasi: $e");
    }
  }
}