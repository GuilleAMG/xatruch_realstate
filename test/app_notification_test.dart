import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xatruch_realstate/features/support/data/notification.dart';

void main() {
  group('AppNotification', () {
    test('fromMap maps Firestore data correctly', () {
      final notification = AppNotification.fromMap({
        'userId': 'user-1',
        'title': 'Nuevo Mensaje',
        'body': 'Hola',
        'timestamp': Timestamp.fromDate(DateTime(2026, 4, 11, 10, 0)),
        'type': 'message',
        'relatedId': 'chat-1',
        'isRead': true,
        'senderName': 'Ana',
        'senderPhoto': 'https://example.com/a.png',
      }, 'notif-1');

      expect(notification.id, 'notif-1');
      expect(notification.userId, 'user-1');
      expect(notification.type, 'message');
      expect(notification.relatedId, 'chat-1');
      expect(notification.isRead, isTrue);
      expect(notification.senderName, 'Ana');
    });

    test('toMap includes unread default and server timestamp field', () {
      final notification = AppNotification(
        id: 'notif-2',
        userId: 'user-2',
        title: 'Nueva Propiedad',
        body: 'Se publicó una propiedad',
        timestamp: DateTime(2026, 4, 11),
        type: 'new_post',
      );

      final map = notification.toMap();

      expect(map['userId'], 'user-2');
      expect(map['title'], 'Nueva Propiedad');
      expect(map['type'], 'new_post');
      expect(map['isRead'], isFalse);
      expect(map['timestamp'], isA<FieldValue>());
    });
  });
}