import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/post_model.dart';
import '../../services/firestore_service.dart';

class DetailPostScreen extends StatefulWidget {
  final PostModel post;
  const DetailPostScreen({super.key, required this.post});

  @override
  State<DetailPostScreen> createState() => _DetailPostScreenState();
}

class _DetailPostScreenState extends State<DetailPostScreen> {
  final FirestoreService _service = FirestoreService();
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  // Membuka Google Maps menggunakan koordinat dari Database
  Future<void> _launchMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${widget.post.latitude},${widget.post.longitude}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal membuka Maps")));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isFavorited = widget.post.favorites.contains(_uid);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header Sinematik dengan Sliver
          SliverAppBar(
            expandedHeight: 380.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.post.imageUrl.isNotEmpty
                  ? Image.memory(base64Decode(widget.post.imageUrl), fit: BoxFit.cover)
                  : Container(color: Colors.grey[900]),
            ),
            actions: [
              // Tombol Love/Favorit
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black38,
                  child: IconButton(
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: isFavorited ? Colors.redAccent : Colors.white,
                    ),
                    onPressed: () async {
                      await _service.toggleFavorite(widget.post.id, _uid);
                      setState(() {}); // Refresh UI lokal
                    },
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul & Badge Kondisi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(widget.post.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                      _buildConditionBadge(widget.post.condition),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text("Oleh: ${widget.post.userName}", style: const TextStyle(color: Colors.grey)),
                  
                  const Divider(height: 40),

                  // Informasi Kategori & Jenis (Grid Style)
                  Row(
                    children: [
                      _buildInfoTile(Icons.category_outlined, "Kategori", widget.post.category),
                      _buildInfoTile(Icons.settings_input_component, "Jenis", widget.post.subCategory),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Deskripsi
                  const Text("Deskripsi Kerusakan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(widget.post.description, style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.blueGrey)),

                  const SizedBox(height: 30),

                  // Bagian Lokasi & Maps
                  const Text("Lokasi Perangkat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [if(!isDark) BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.redAccent),
                            const SizedBox(width: 10),
                            Text("Koordinat: ${widget.post.latitude}, ${widget.post.longitude}", 
                                 style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _launchMaps,
                            icon: const Icon(Icons.map_outlined),
                            label: const Text("LIHAT DI GOOGLE MAPS", style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionBadge(String condition) {
    Color color = condition == "Rusak" ? Colors.redAccent : Colors.greenAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(condition, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: Colors.lightBlue, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}