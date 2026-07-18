import 'package:flutter/material.dart';
import 'package:xatruch_realstate/features/chat/data/messages.dart';
import 'package:xatruch_realstate/features/chat/ui/widgets/message_bubble.dart';
import 'package:xatruch_realstate/core/widgets/report_dialog.dart';

/// Lista de mensajes que maneja el scroll y la interacción de reportes.
class MessageList extends StatelessWidget {
  const MessageList({
    super.key,
    required this.messages,
    required this.otherUserAvatar,
  });

  final List<Message> messages;
  final String otherUserAvatar;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(child: Text('No hay mensajes aún. ¡Di hola!'));
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return GestureDetector(
          onLongPress: () {
            ReportDialog.show(
              context,
              reportedId: message.id,
              reportedUserId: message.senderId,
              reportType: 'message',
            );
          },
          child: MessageBubble(
            message: message,
            otherUserAvatar: otherUserAvatar,
          ),
        );
      },
    );
  }
}