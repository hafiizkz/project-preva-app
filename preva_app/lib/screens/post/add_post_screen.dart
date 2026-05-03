import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/post_model.dart';
import '../../services/firestore_service.dart';
import '../../services/location_service.dart';
import '../../widgets/custom_button.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _service = FirestoreService();
  final _locationService = LocationService();
  final ImagePicker _picker = ImagePicker();

  String _category = "Hardware";
  String _subCategory = "RAM";
  String _condition = "Baik"; // DEFAULT KONDISI
  String _lat = "0.0";
  String _long = "0.0";
  String _imageBase64 = ""; 
  Uint8List? _webImage;

  final List<String> _hwList = ["RAM", "SSD", "Monitor", "Mouse", "VGA"];
  final List<String> _swList = ["Microsoft Office", "Sistem Operasi", "Lisensi Lainnya"];
  final List<String> _conditions = ["Baik", "Rusak Ringan", "Rusak Berat", "Perlu Maintenance"];

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      Position position = await _locationService.getCurrentLocation();
      setState(() {
        _lat = position.latitude.toString();
        _long = position.longitude.toString();
      });
    } catch (e) {
      debugPrint("Lokasi Error: $e");
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (image != null) {
      Uint8List bytes = await image.readAsBytes();
      setState(() {
        _webImage = bytes;
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color fieldColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      appBar: AppBar(title: const Text("Buat Laporan Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // 1. UPLOAD BOX (CINEMATIC PREVIEW)
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200, width: double.infinity,
                decoration: BoxDecoration(
                  color: fieldColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.lightBlue.withOpacity(0.3)),
                ),
                child: _webImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.lightBlue),
                          const SizedBox(height: 10),
                          Text("Ketuk untuk Unggah Foto", style: TextStyle(color: Colors.lightBlue.withOpacity(0.7))),
                        ],
                      )
                    : ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.memory(_webImage!, fit: BoxFit.cover)),
              ),
            ),
            const SizedBox(height: 25),

            // 2. INPUT DATA
            _buildLabel("Judul Laporan"),
            _buildTextField(_titleController, isDark),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Kategori"),
                      _buildDropdown(_category, ["Hardware", "Software"], isDark, (val) {
                        setState(() {
                          _category = val.toString();
                          _subCategory = _category == "Hardware" ? _hwList[0] : _swList[0];
                        });
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Sub-Kategori"),
                      _buildDropdown(_subCategory, (_category == "Hardware" ? _hwList : _swList), isDark, (val) {
                        setState(() => _subCategory = val.toString());
                      }),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. KONDISI BARANG (FITUR YANG DITUNGGU)
            _buildLabel("Kondisi Barang"),
            _buildDropdown(_condition, _conditions, isDark, (val) {
              setState(() => _condition = val.toString());
            }),
            const SizedBox(height: 20),

            _buildLabel("Deskripsi Detail Masalah"),
            _buildTextField(_descController, isDark, maxLines: 4),
            const SizedBox(height: 30),

            // 4. ACTION BUTTON
            CustomButton(
              text: "KIRIM LAPORAN",
              onPressed: () async {
                if (_titleController.text.isEmpty || _imageBase64.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto dan Judul tidak boleh kosong!")));
                  return;
                }
                final user = FirebaseAuth.instance.currentUser!;
                final newPost = PostModel(
                  id: "", 
                  userId: user.uid,
                  userName: user.displayName ?? "User",
                  userRole: "karyawan",
                  title: _titleController.text,
                  category: _category,
                  subCategory: _subCategory,
                  condition: _condition, // DISIMPAN KE DATABASE
                  description: _descController.text,
                  locationName: "Area Kerja",
                  latitude: _lat, longitude: _long,
                  imageUrl: _imageBase64,
                  timestamp: DateTime.now(),
                  favorites: [],
                );
                await _service.createPost(newPost);
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 5, bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.lightBlue)),
  );

  Widget _buildTextField(TextEditingController controller, bool isDark, {int maxLines = 1}) => TextField(
    controller: controller, maxLines: maxLines,
    decoration: InputDecoration(
      filled: true, fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    ),
  );

  Widget _buildDropdown(String value, List<String> items, bool isDark, Function(Object?) onChanged) => DropdownButtonFormField(
    value: value, dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
    decoration: InputDecoration(
      filled: true, fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    ),
    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
    onChanged: onChanged,
  );
}