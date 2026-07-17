// Pantalla de notificaciones: muestra el historial de notificaciones
// del usuario con navegacion al contenido relacionado.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xatruch_realstate/core/services/notification_data_service.dart';
import 'package:xatruch_realstate/core/services/property_service.dart';
import 'package:xatruch_realstate/features/support/data/notification.dart';
import 'package:xatruch_realstate/features/support/utils/notification_navigation.dart';
import 'package:xatruch_realstate/features/properties/ui/property_detail_screen.dart';
import 'package:xatruch_realstate/features/chat/ui/chat_room_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: notificationDataService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationItem(notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes notificaciones aún...',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Te avisaremos cuando suceda algo importante.',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    return Container(
      color: notification.isRead
          ? Colors.transparent
          : const Color(0xFF3F888F).withValues(alpha: 0.05),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: _buildNotificationIcon(notification),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.body,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              _formatDate(notification.timestamp),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.outline, fontSize: 12),
            ),
          ],
        ),
        onTap: () async => await _handleNotificationTap(notification),
      ),
    );
  }

  Widget _buildNotificationIcon(AppNotification notification) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Theme.of(context).colorScheme.primary,
      backgroundImage: (notification.senderPhoto != null &&
              notification.senderPhoto!.isNotEmpty)
          ? NetworkImage(notification.senderPhoto!) as ImageProvider
          : null,
      child: (notification.senderPhoto == null ||
              notification.senderPhoto!.isEmpty)
          ? Image.asset(
              'assets/icons/default_avatar.png',
              color: Theme.of(context).colorScheme.onPrimary,
              width: 25,
            )
          : null,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} d';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  Future<void> _handleNotificationTap(AppNotification notification) async {
    if (!notification.isRead) {
      await notificationDataService.markNotificationAsRead(notification.id);
    }

    final destination = resolveNotificationDestination(notification);
    if (destination.type == NotificationDestinationType.none ||
        destination.relatedId == null) {
      return;
    }

    final relatedId = destination.relatedId!;

    try {
      if (destination.type == NotificationDestinationType.chat) {
        if (mounted) {
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (context) => ChatRoomScreen(
                chatId: relatedId,
                otherUserName: notification.senderName ?? 'Usuario',
                otherUserAvatar: notification.senderPhoto ??
                    'assets/icons/default_avatar.png',
              ),
            ),
          );
        }
      } else if (destination.type == NotificationDestinationType.property) {
        final propsStream = propertyService.getProperties();
        final properties = await propsStream.first;
        final property = properties.firstWhere(
          (p) => p.id == relatedId,
          orElse: () => throw Exception('Propiedad no encontrada'),
        );

        if (mounted) {
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (context) => PropertyDetailScreen(property: property),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al abrir: $e')));
      }
    }
  }
}
