import 'package:flutter/material.dart';
import 'package:xatruch_realstate/features/chat/data/messages.dart';
import 'package:xatruch_realstate/features/chat/ui/chat_room_screen.dart';
import 'package:xatruch_realstate/core/services/chat_service.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';

/// Un elemento individual en la lista de chats.
class ChatTile extends StatelessWidget {
  const ChatTile({
    super.key,
    required this.chat,
    required this.currentUserId,
  });

  final Chat chat;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final otherUserId = chat.participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _ChatAvatar(
          otherUserId: otherUserId,
          defaultAvatar: chat.otherUserAvatar,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  if (chat.pinnedBy.contains(currentUserId))
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Icon(Icons.push_pin, size: 16, color: colorScheme.primary),
                    ),
                  Expanded(
                    child: Text(
                      chat.otherUserName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              chat.lastMessage != null
                  ? _formatTime(chat.lastMessage!.timestamp)
                  : '',
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              if (chat.lastMessage?.isMe ?? false)
                const Icon(Icons.done_all, size: 16, color: Color(0xFF3F888F)),
              if (chat.lastMessage?.isMe ?? false) const SizedBox(width: 4),
              Expanded(
                child: Text(
                  chat.lastMessage?.content ?? 'Inicia una conversación',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: (chat.lastMessage?.isMe ?? true)
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                    fontWeight: (chat.lastMessage?.isMe ?? true)
                        ? FontWeight.normal
                        : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        trailing: _ChatTileMenu(chat: chat, currentUserId: currentUserId),
        onTap: () async {
          await Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (context) => ChatRoomScreen(
                chatId: chat.id,
                otherUserName: chat.otherUserName,
                otherUserAvatar: chat.otherUserAvatar,
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} m';
    } else {
      return 'Ahora';
    }
  }
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({
    required this.otherUserId,
    required this.defaultAvatar,
  });

  final String otherUserId;
  final String defaultAvatar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        FutureBuilder<Map<String, dynamic>?>(
          future: otherUserId.isNotEmpty ? userService.getUsuarioById(otherUserId) : Future.value(null),
          builder: (context, snapshot) {
            final userData = snapshot.data;
            final currentAvatar = userData?['photoUrl'] as String?;
            final avatarToUse = (currentAvatar != null && currentAvatar.isNotEmpty) ? currentAvatar : defaultAvatar;
            
            final hasNetworkImage = avatarToUse.isNotEmpty && !avatarToUse.startsWith('assets');

            return CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF3F888F),
              backgroundImage: hasNetworkImage ? NetworkImage(avatarToUse) : null,
              child: !hasNetworkImage
                  ? Image.asset(
                      'assets/icons/default_avatar.png',
                      color: Colors.white,
                      width: 35,
                    )
                  : null,
            );
          },
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatTileMenu extends StatelessWidget {
  const _ChatTileMenu({
    required this.chat,
    required this.currentUserId,
  });

  final Chat chat;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
      onSelected: (value) async {
        if (value == 'pin') {
          final isPinned = chat.pinnedBy.contains(currentUserId);
          await chatService.pinChat(chat.id, !isPinned);
        } else if (value == 'archive') {
          final isArchived = chat.archivedBy.contains(currentUserId);
          await chatService.archiveChat(chat.id, !isArchived);
        } else if (value == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Eliminar chat'),
              content: const Text('¿Estás seguro de que quieres eliminar este chat? Esta acción no se puede deshacer.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: colorScheme.error),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          );
          
          if (confirm == true) {
            await chatService.deleteChat(chat.id);
          }
        }
      },
      itemBuilder: (BuildContext context) {
        final isPinned = chat.pinnedBy.contains(currentUserId);
        final isArchived = chat.archivedBy.contains(currentUserId);
        
        return [
          PopupMenuItem<String>(
            value: 'pin',
            child: Row(
              children: [
                Icon(isPinned ? Icons.push_pin_outlined : Icons.push_pin, size: 20),
                const SizedBox(width: 8),
                Text(isPinned ? 'Desfijar' : 'Fijar'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'archive',
            child: Row(
              children: [
                Icon(isArchived ? Icons.unarchive : Icons.archive, size: 20),
                const SizedBox(width: 8),
                Text(isArchived ? 'Desarchivar' : 'Archivar'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 20, color: colorScheme.error),
                const SizedBox(width: 8),
                Text('Eliminar', style: TextStyle(color: colorScheme.error)),
              ],
            ),
          ),
        ];
      },
    );
  }
}
