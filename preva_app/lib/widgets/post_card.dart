import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:share_plus/share_plus.dart'; 
import '../models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final bool isAdmin, isOwner, isFavoritePage;
  final VoidCallback onDelete, onTap;

  const PostCard({
    super.key, 
    required this.post, 
    required this.isAdmin, 
    required this.isOwner, 
    required this.onDelete, 
    required this.onTap,
    this.isFavoritePage = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Format Tanggal & Waktu
    String formattedDate = DateFormat('dd MMM yyyy').format(post.timestamp);
    String formattedTime = DateFormat('HH:mm').format(post.timestamp);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        
        // --- FOTO LAPORAN ---
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: post.imageUrl.isNotEmpty
                ? Image.memory(
                    base64Decode(post.imageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                  )
                : const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
        ),
        
        title: Text(
          post.title, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87 
          )
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            
            // --- INFO PENGUNGGAH (Username & Foto Profil) ---
            Row(
              children: [
                CircleAvatar(
                  radius: 9,
                  backgroundColor: Colors.lightBlue.withOpacity(0.2),
                  child: ClipOval(
                    child: post.userProfilePic != null && post.userProfilePic!.isNotEmpty
                        ? Image.memory(
                            base64Decode(post.userProfilePic!),
                            width: 18,
                            height: 18,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.person, size: 12, color: Colors.lightBlue),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  post.userName ?? "Anonim",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.lightBlue[700],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Text(
              "${post.subCategory} • ${post.condition}",
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54
              ),
            ),
            
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_month_outlined, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  "$formattedDate  •  $formattedTime",
                  style: TextStyle(
                    fontSize: 11, 
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ],
        ),
        
        trailing: Row(
          mainAxisSize: MainAxisSize.min, 
          children: [
            IconButton(
              icon: const Icon(Icons.share_outlined, color: Colors.lightBlue, size: 22),
              onPressed: () {
                final String gmapsUrl = 'https://www.google.com/maps/search/?api=1&query=${post.latitude},${post.longitude}';
                final String shareText = '''
*LAPORAN MAINTENANCE PREVA* 🛠️
Oleh: ${post.userName}

📌 *Judul:* ${post.title}
🏷️ *Kategori:* ${post.category} (${post.subCategory})
⚠️ *Kondisi:* ${post.condition.toUpperCase()}
📝 *Deskripsi:* ${post.description}

📍 *Link Lokasi:*
$gmapsUrl
''';
                Share.share(shareText);
              },
            ),
            
            if (isFavoritePage)
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.redAccent, size: 22),
                onPressed: onDelete,
              )
            else if (isAdmin || isOwner)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                onPressed: onDelete,
              )
            else
              const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}