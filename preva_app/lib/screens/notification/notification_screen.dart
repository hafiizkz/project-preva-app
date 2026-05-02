import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi Komentar")),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getNotifications(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada notifikasi baru."));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.lightBlue,
                    child: Icon(Icons.comment, color: Colors.white, size: 20),
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      children: [
                        TextSpan(text: data['fromUserName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: " ${data['message']}"),
                      ],
                    ),
                  ),
                  subtitle: Text(
                    data['timestamp'] != null 
                        ? (data['timestamp'] as Timestamp).toDate().toString().substring(0, 16) 
                        : "Baru saja",
                    style: const TextStyle(fontSize: 11),
                  ),
                  onTap: () {
                    // Logic untuk navigasi ke post terkait bisa ditambahkan di sini
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}