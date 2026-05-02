class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'admin' atau 'karyawan'
  final String profilePic;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.profilePic = "",
  });

  // Konversi ke Map untuk simpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'profilePic': profilePic,
    };
  }

  // Konversi dari Firestore ke Objek Dart
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'karyawan',
      profilePic: map['profilePic'] ?? "",
    );
  }
}