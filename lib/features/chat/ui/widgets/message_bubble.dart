// Widget de burbuja de mensaje
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/features/chat/data/messages.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/profile_state_service.dart';
import 'package:xatruch_realstate/core/widgets/video_player_widget.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.otherUserAvatar,
  });

  final Message message;
  final String otherUserAvatar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isMe = message.isMe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _buildAvatar(otherUserAvatar),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              decoration: BoxDecoration(
                color: isMe
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(context, isMe, colorScheme),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isMe
                          ? Colors.white.withValues(alpha: 0.7)
                          : colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[const SizedBox(width: 8), _buildCurrentUserAvatar()],
        ],
      ),
    );
  }

  Widget _buildMessageContent(
    BuildContext context,
    bool isMe,
    ColorScheme colorScheme,
  ) {
    if (message.type == 'text') {
      return Text(
        message.content,
        style: TextStyle(
          color: isMe ? colorScheme.onPrimary : colorScheme.onSurface,
          fontSize: 16,
        ),
      );
    } else if (message.type == 'image' && message.mediaUrl != null) {
      return GestureDetector(
        onTap: () async =>
            await _showFullScreenMedia(context, message.mediaUrl!, 'image'),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            message.mediaUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      );
    } else if (message.type == 'video' && message.mediaUrl != null) {
      return GestureDetector(
        onTap: () async =>
            await _showFullScreenMedia(context, message.mediaUrl!, 'video'),
        child: Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _showFullScreenMedia(
    BuildContext context,
    String url,
    String type,
  ) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: type == 'image'
                ? Image.network(url)
                : VideoPlayerWidget(url: url),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String avatarUrl) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFF3F888F),
      backgroundImage: (avatarUrl.isNotEmpty && !avatarUrl.startsWith('assets'))
          ? NetworkImage(avatarUrl) as ImageProvider
          : null,
      child: (avatarUrl.isEmpty || avatarUrl.startsWith('assets'))
          ? Image.asset(
              'assets/icons/default_avatar.png',
              color: Colors.white,
              width: 20,
            )
          : null,
    );
  }

  Widget _buildCurrentUserAvatar() {
    final photoUrl = profileStateService.photoUrl.isNotEmpty
        ? profileStateService.photoUrl
        : authService.currentUser?.photoURL;
    return CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFF3F888F),
      backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
          ? NetworkImage(photoUrl) as ImageProvider
          : null,
      child: (photoUrl == null || photoUrl.isEmpty)
          ? Image.asset(
              'assets/icons/default_avatar.png',
              color: Colors.white,
              width: 20,
            )
          : null,
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}