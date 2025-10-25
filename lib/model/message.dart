import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  // convert message to map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }

  // convert map to message
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderId: map['senderId'],
      senderEmail: map['senderEmail'],
      receiverId: map['receiverId'],
      message: map['message'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'],
    );
  }
}
