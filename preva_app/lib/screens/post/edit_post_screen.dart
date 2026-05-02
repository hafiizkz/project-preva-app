import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_button.dart';

class EditPostScreen extends StatefulWidget {
  final PostModel post;
  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _service = FirestoreService();
  late TextEditingController _titleController;
  late TextEditingController _descController;

  late String _category;
  late String _subCategory;
  late String _condition;

  final List<String> _hwList = ["RAM", "SSD", "Monitor", "Mouse", "VGA"];
  final List<String> _swList = ["Microsoft Office", "Sistem Operasi", "Lisensi Lainnya"];

  @override
  void initState() {
    super.initState();
    // Inisialisasi data lama ke dalam controller/variabel
    _titleController = TextEditingController(text: widget.post.title);
    _descController = TextEditingController(text: widget.post.description);
    _category = widget.post.category;
    _subCategory = widget.post.subCategory;
    _condition = widget.post.condition;
  }

  void _handleUpdate() async {
    // Menyiapkan data yang akan diupdate
    final updatedData = {
      'title': _titleController.text,
      'category': _category,
      'subCategory': _subCategory,
      'condition': _condition,
      'description': _descController.text,
      'timestamp': DateTime.now(), // Update waktu edit
    };

    await _service.updatePost(widget.post.id, updatedData);
    if (mounted) {
      Navigator.pop(context); // Kembali setelah sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Laporan berhasil diperbarui"), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Edit Laporan"),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Judul Laporan", filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 15),
            
            // Dropdown Kategori
            DropdownButtonFormField(
              value: _category,
              decoration: const InputDecoration(labelText: "Kategori Utama", filled: true, fillColor: Colors.white),
              items: ["Hardware", "Software"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) {
                setState(() {
                  _category = val.toString();
                  _subCategory = _category == "Hardware" ? _hwList[0] : _swList[0];
                });
              },
            ),
            const SizedBox(height: 15),

            // Dropdown Sub-Kategori
            DropdownButtonFormField(
              value: _subCategory,
              decoration: const InputDecoration(labelText: "Sub Kategori", filled: true, fillColor: Colors.white),
              items: (_category == "Hardware" ? _hwList : _swList).map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _subCategory = val.toString()),
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField(
              value: _condition,
              decoration: const InputDecoration(labelText: "Kondisi", filled: true, fillColor: Colors.white),
              items: ["Rusak", "Butuh Pembersihan", "Baik"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _condition = val.toString()),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Deskripsi Perubahan", filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 30),
            
            CustomButton(
              text: "SIMPAN PERUBAHAN",
              onPressed: _handleUpdate,
            ),
          ],
        ),
      ),
    );
  }
}