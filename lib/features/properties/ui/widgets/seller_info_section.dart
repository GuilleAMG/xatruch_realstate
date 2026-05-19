// Seccion de informacion del vendedor: muestra avatar, nombre
// y boton de seguir/dejar de seguir al vendedor.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/follow_service.dart';
import 'package:xatruch_realstate/core/services/chat_service.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';
import 'package:xatruch_realstate/features/chat/ui/chat_room_screen.dart';

/// Muestra el avatar del vendedor, nombre y botón de seguir/dejar de seguir
/// para usuarios que no son el vendedor.
class SellerInfoSection extends StatelessWidget {
  const SellerInfoSection({
    super.key,
    required this.sellerId,
    required this.sellerName,
  });

  final String sellerId;
  final String sellerName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: colorScheme.surfaceContainerHighest,
          radius: 20,
          child: Icon(Icons.person, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sellerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Vendedor',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (sellerId != authService.currentUser?.uid) ...[
          IconButton(
            onPressed: () async {
              try {
                final sellerData = await userService.getUsuarioById(sellerId);
                final String name = (sellerData?['nombre'] as String?) ?? sellerName;
                final String avatar = (sellerData?['photoUrl'] as String?) ??
                    'assets/icons/default_avatar.png';

                final chatId = await chatService.getOrCreateChatRoom(
                  sellerId,
                  name,
                  otherUserAvatar: avatar,
                );

                if (context.mounted) {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => ChatRoomScreen(
                        chatId: chatId,
                        otherUserName: name,
                        otherUserAvatar: avatar,
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al crear chat: $e')),
                  );
                }
              }
            },
            icon: Icon(Icons.message_outlined, color: colorScheme.primary),
            tooltip: 'Enviar mensaje',
          ),
          StreamBuilder<bool>(
            stream: followService.isFollowing(sellerId),
            builder: (context, snapshot) {
              final isFollowing = snapshot.data ?? false;
              return OutlinedButton(
                onPressed: () => followService.toggleFollow(sellerId),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      isFollowing ? colorScheme.outline : colorScheme.primary,
                  side: BorderSide(
                    color: isFollowing
                        ? colorScheme.outline
                        : colorScheme.primary,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(isFollowing ? 'Siguiendo' : 'Seguir'),
              );
            },
          ),
        ],
      ],
    );
  }
}
