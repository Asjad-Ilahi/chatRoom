import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String message;
  final String receiverId;
  final Timestamp timestamp;
  final String senderEmail;
  final String senderId;
  final String? repliedMessage; // New field for the replied message

  Message({
    required this.message,
    required this.receiverId,
    required this.timestamp,
    required this.senderEmail,
    required this.senderId,
    this.repliedMessage, // Initialize the new field
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'receiverId': receiverId,
      'timestamp': timestamp,
      'senderEmail': senderEmail,
      'senderId': senderId,
      'repliedMessage': repliedMessage,
    };
  }
}
