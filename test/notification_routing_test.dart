import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:xatruch_realstate/core/services/notification_service.dart';

void main() {
  group('NotificationService Routing', () {
    test('parseNotificationRoute - home route', () {
      final message = RemoteMessage(data: {'route': 'home'});
      final result = NotificationService.parseNotificationRoute(message);
      expect(result['index'], 0);
      expect(result['route'], 'home');
    });

    test('parseNotificationRoute - chats route', () {
      final message = RemoteMessage(data: {'route': 'chats'});
      final result = NotificationService.parseNotificationRoute(message);
      expect(result['index'], 1);
      expect(result['route'], 'chats');
    });

    test('parseNotificationRoute - account route', () {
      final message = RemoteMessage(data: {'route': 'account'});
      final result = NotificationService.parseNotificationRoute(message);
      expect(result['index'], 2);
      expect(result['route'], 'account');
    });

    test('parseNotificationRoute - unknown route defaults to home', () {
      final message = RemoteMessage(data: {'route': 'unknown'});
      final result = NotificationService.parseNotificationRoute(message);
      expect(result['index'], 0);
      expect(result['route'], 'unknown');
    });

    test('parseNotificationRoute - with itemId and model', () {
      final message = RemoteMessage(data: {'route': 'chats', 'itemId': '123', 'model': 'chat'});
      final result = NotificationService.parseNotificationRoute(message);
      expect(result['index'], 1);
      expect(result['itemId'], '123');
      expect(result['model'], 'chat');
    });
  });
}