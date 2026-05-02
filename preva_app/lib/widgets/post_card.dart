import 'package:flutter/material.dart';
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final bool isAdmin, isOwner;
  final VoidCallback onDelete, onTap;

  const PostCard({super.key, required this.post, required this.isAdmin, required this.isOwner, required this.onDelete, required this.onTap});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      // Card akan otomatis berubah warna di Dark Mode jika tidak di-set manual
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: Icon(post.category == "Hardware" ? Icons.settings_suggest : Icons.terminal, color: Colors.lightBlue),
        title: Text(
          post.title, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            // Tulisan otomatis menyesuaikan tema jika tidak di-set warna manual
            color: isDark ? Colors.white : Colors.black87 
          )
        ),
        subtitle: Text("${post.subCategory} • ${post.condition}"),
        trailing: (isAdmin || isOwner) 
          ? IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: onDelete) 
          : const Icon(Icons.chevron_right, size: 18),
      ),
    );
  }
}