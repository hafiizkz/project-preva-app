import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentWidget extends StatelessWidget {
  final String userName;
  final String content;
  final DateTime timestamp;

  const CommentWidget({
    super.key,
    required this.userName,
    required this.content,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(DateFormat('HH:mm').format(timestamp), style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          Text(content),
        ],
      ),
    );
  }
}