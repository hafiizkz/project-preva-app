import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/post_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/comment_widget.dart';

class DetailPostScreen extends StatelessWidget {
  final PostModel post;
  DetailPostScreen({super.key, required this.post});

  final _commentController = TextEditingController();
  final _service = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Laporan"), backgroundColor: Colors.lightBlue),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(post.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                // PERBAIKAN: Gunakan subCategory & description
                Text("${post.category} > ${post.subCategory}", style: const TextStyle(color: Colors.lightBlue)),
                const Divider(),
                Text(post.description), 
                const SizedBox(height: 20),
                const Text("Komentar", style: TextStyle(fontWeight: FontWeight.bold)),
                StreamBuilder<QuerySnapshot>(
                  stream: _service.getComments(post.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator();
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, i) {
                        var data = snapshot.data!.docs[i];
                        return CommentWidget(
                          userName: data['userName'] ?? "User",
                          content: data['content'] ?? "",
                          timestamp: (data['timestamp'] as Timestamp).toDate(),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(child: TextField(controller: _commentController, decoration: const InputDecoration(hintText: "Tulis komentar..."))),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.lightBlue),
            onPressed: () {
              _service.addComment(post.id, {
                'userId': FirebaseAuth.instance.currentUser!.uid,
                'userName': "Hafiiz",
                'content': _commentController.text,
                'timestamp': DateTime.now(),
              });
              _commentController.clear();
            },
          ),
        ],
      ),
    );
  }
}