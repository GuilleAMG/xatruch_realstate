// Servicio de datos de las notificaciones
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:xatruch_realstate/features/support/data/notification.dart';

class NotificationDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendNotification(AppNotification notification) async {
    try {
      debugPrint(
        '[NotificationDataService] Sending notification to ${notification.userId}',
      );
      await _db
          .collection('usuarios')
          .doc(notification.userId)
          .collection('notificaciones')
          .add(notification.toMap());
      debugPrint('[NotificationDataService] Notification sent successfully');
    } catch (e) {
      debugPrint('[NotificationDataService] ERROR sending notification: $e');
      rethrow;
    }
  }

  /// Retorna una lista de las notificaciones.
  Stream<List<AppNotification>> getNotifications() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('usuarios')
        .doc(user.uid)
        .collection('notificaciones')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('usuarios')
        .doc(user.uid)
        .collection('notificaciones')
        .doc(notificationId)
        .update({'isRead': true});
  }
}

final notificationDataService = NotificationDataService();