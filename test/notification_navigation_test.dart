import 'package:flutter_test/flutter_test.dart';
import 'package:xatruch_realstate/features/support/data/notification.dart';
import 'package:xatruch_realstate/features/support/utils/notification_navigation.dart';

void main() {
  group('resolveNotificationDestination', () {
    AppNotification buildNotification({
      required String type,
      String? relatedId,
    }) {
      return AppNotification(
        id: 'n1',
        userId: 'u1',
        title: 'title',
        body: 'body',
        timestamp: DateTime(2026, 4, 11),
        type: type,
        relatedId: relatedId,
      );
    }

    test('returns chat destination for message notifications', () {
      final destination = resolveNotificationDestination(
        buildNotification(type: 'message', relatedId: 'chat-1'),
      );

      expect(destination.type, NotificationDestinationType.chat);
      expect(destination.relatedId, 'chat-1');
    });

    test('returns property destination for property-related notifications', () {
      for (final type in ['favorite', 'new_post', 'property_sold']) {
        final destination = resolveNotificationDestination(
          buildNotification(type: type, relatedId: 'prop-1'),
        );

        expect(destination.type, NotificationDestinationType.property);
        expect(destination.relatedId, 'prop-1');
      }
    });

    test('returns none for unsupported or incomplete notifications', () {
      final missingId = resolveNotificationDestination(
        buildNotification(type: 'message'),
      );
      final unsupported = resolveNotificationDestination(
        buildNotification(type: 'unknown', relatedId: 'x'),
      );

      expect(missingId.type, NotificationDestinationType.none);
      expect(unsupported.type, NotificationDestinationType.none);
    });
  });
}
