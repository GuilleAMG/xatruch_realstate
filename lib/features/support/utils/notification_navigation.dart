// Navegacion de notificaciones: maneja la navegacion a la pantalla
// correspondiente cuando el usuario toca una notificacion.
import 'package:xatruch_realstate/features/support/data/notification.dart';

enum NotificationDestinationType { none, chat, property }

class NotificationDestination {
  const NotificationDestination({required this.type, this.relatedId});
  final NotificationDestinationType type;
  final String? relatedId;
}

NotificationDestination resolveNotificationDestination(
  AppNotification notification,
) {
  if (notification.relatedId == null || notification.relatedId!.isEmpty) {
    return const NotificationDestination(
      type: NotificationDestinationType.none,
    );
  }

  if (notification.type == 'message') {
    return NotificationDestination(
      type: NotificationDestinationType.chat,
      relatedId: notification.relatedId,
    );
  }

  if (['favorite', 'new_post', 'property_sold'].contains(notification.type)) {
    return NotificationDestination(
      type: NotificationDestinationType.property,
      relatedId: notification.relatedId,
    );
  }

  return const NotificationDestination(type: NotificationDestinationType.none);
}
