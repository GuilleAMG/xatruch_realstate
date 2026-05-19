// Modelos de datos de chat: define las clases Message y Chat
// para representar mensajes y salas de conversacion.
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  const Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isMe,
    this.type = 'text',
    this.mediaUrl,
  });

  factory Message.fromMap(
    Map<String, dynamic> map,
    String docId,
    String currentUserId,
  ) {
    return Message(
      id: docId,
      senderId: (map['senderId'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isMe: map['senderId'] == currentUserId,
      type: (map['type'] as String?) ?? 'text',
      mediaUrl: map['mediaUrl'] as String?,
    );
  }

  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isMe;
  final String type; // 'text', 'image', 'video'
  final String? mediaUrl;

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
      'mediaUrl': mediaUrl,
    };
  }
}

class Chat {
  const Chat({
    required this.id,
    required this.otherUserName,
    required this.otherUserAvatar,
    this.lastMessage,
    required this.participants,
    this.pinnedBy = const [],
    this.archivedBy = const [],
    this.deletedBy = const [],
  });

  factory Chat.fromMap(
    Map<String, dynamic> map,
    String docId,
    String currentUserId,
  ) {
    final participants = List<String>.from((map['participants'] as Iterable?) ?? []);
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    // Usar una forma más segura de convertir mapas desde Firestore
    final participantNames =
        (map['participantNames'] as Map?)?.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        ) ??
        {};
    final participantAvatars =
        (map['participantAvatars'] as Map?)?.map(
          (k, v) => MapEntry(k.toString(), v.toString()),
        ) ??
        {};

    return Chat(
      id: docId,
      otherUserName: participantNames[otherUserId] ?? 'Usuario',
      otherUserAvatar:
          participantAvatars[otherUserId] ?? 'assets/icons/default_avatar.png',
      participants: participants,
      pinnedBy: List<String>.from((map['pinnedBy'] as Iterable?) ?? []),
      archivedBy: List<String>.from((map['archivedBy'] as Iterable?) ?? []),
      deletedBy: List<String>.from((map['deletedBy'] as Iterable?) ?? []),
      lastMessage: map['lastMessage'] != null
          ? Message.fromMap(
              Map<String, dynamic>.from(map['lastMessage'] as Map),
              '',
              currentUserId,
            )
          : null,
    );
  }

  final String id;
  final String otherUserName;
  final String otherUserAvatar;
  final Message? lastMessage;
  final List<String> participants;
  final List<String> pinnedBy;
  final List<String> archivedBy;
  final List<String> deletedBy;
}
