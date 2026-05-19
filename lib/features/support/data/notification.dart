// Modelo de datos de notificacion: define la clase AppNotification
// con sus atributos y metodos de serializacion.
import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.relatedId,
    this.isRead = false,
    this.senderName,
    this.senderPhoto,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String docId) {
    return AppNotification(
      id: docId,
      userId: (map['userId'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: (map['type'] as String?) ?? 'info',
      relatedId: map['relatedId'] as String?,
      isRead: (map['isRead'] as bool?) ?? false,
      senderName: map['senderName'] as String?,
      senderPhoto: map['senderPhoto'] as String?,
    );
  }

  final String id;
  final String userId; // Recipient ID
  final String title;
  final String body;
  final DateTime timestamp;
  final String type; // 'favorite', 'message', 'property_sold', 'new_post'
  final String? relatedId; // propertyId or chatId
  final bool isRead;
  final String? senderName;
  final String? senderPhoto;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
      'relatedId': relatedId,
      'isRead': isRead,
      'senderName': senderName,
      'senderPhoto': senderPhoto,
    };
  }
}
