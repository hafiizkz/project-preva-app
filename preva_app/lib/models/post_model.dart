import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id, userId, userName, userRole, title, category, subCategory, condition, description, locationName, latitude, longitude, imageUrl;
  final DateTime timestamp;
  final List<String> favorites;

  PostModel({
    required this.id, required this.userId, required this.userName, required this.userRole, 
    required this.title, required this.category, required this.subCategory, 
    required this.condition, required this.description, required this.locationName, 
    required this.latitude, required this.longitude, required this.imageUrl,
    required this.timestamp, required this.favorites
  });

  Map<String, dynamic> toMap() => {
    "userId": userId, "userName": userName, "userRole": userRole, "title": title, 
    "category": category, "subCategory": subCategory, "condition": condition, 
    "description": description, "locationName": locationName, "latitude": latitude, 
    "longitude": longitude, "imageUrl": imageUrl, "timestamp": timestamp, "favorites": favorites
  };

  factory PostModel.fromMap(Map<String, dynamic> map, String id) => PostModel(
    id: id, 
    userId: map['userId'] ?? '', 
    userName: map['userName'] ?? '', 
    userRole: map['userRole'] ?? '',
    title: map['title'] ?? '', 
    category: map['category'] ?? '', 
    subCategory: map['subCategory'] ?? '',
    condition: map['condition'] ?? '', 
    description: map['description'] ?? '', 
    locationName: map['locationName'] ?? '',
    latitude: map['latitude'] ?? '0', 
    longitude: map['longitude'] ?? '0', 
    imageUrl: map['imageUrl'] ?? '',
    timestamp: (map['timestamp'] as Timestamp).toDate(), 
    favorites: List<String>.from(map['favorites'] ?? [])
  );
}