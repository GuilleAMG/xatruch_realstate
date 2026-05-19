// Servicio de chat: gestiona salas de conversación, envío de mensajes,
// notificaciones de chat y operaciones de gestión (fijar, archivar, eliminar).
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:xatruch_realstate/features/chat/data/messages.dart';
import 'package:xatruch_realstate/features/support/data/notification.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/notification_data_service.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────
  //  Mensajería
  // ─────────────────────────────────────────────

  /// Obtiene o crea una sala de chat entre el usuario actual y [otherUserId].
  Future<String> getOrCreateChatRoom(
    String otherUserId,
    String otherUserName,
    {
      String? otherUserAvatar,
    }
  ) async {
    final currentUser = authService.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    // ID determinístico simple para chats 1 a 1
    final List<String> participants = [currentUser.uid, otherUserId];
    participants.sort();
    final chatId = participants.join('_');

    final chatRef = _db.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      // Obtener detalles del usuario actual para el documento del chat
      final currentUserDoc = await _db
          .collection('usuarios')
          .doc(currentUser.uid)
          .get();
      final currentUserName = (currentUserDoc.data()?['nombre'] as String?) ?? 'Usuario';
      final currentUserAvatar =
          (currentUserDoc.data()?['photoUrl'] as String?) ??
          'assets/icons/default_avatar.png';

      String resolvedOtherAvatar = otherUserAvatar ?? 'assets/icons/default_avatar.png';

      if (otherUserAvatar == null) {
        final otherUserDoc = await _db.collection('usuarios').doc(otherUserId).get();
        resolvedOtherAvatar = (otherUserDoc.data()?['photoUrl'] as String?) ?? 'assets/icons/default_avatar.png';
      }

      await chatRef.set({
        'participants': participants,
        'participantNames': {
          currentUser.uid: currentUserName,
          otherUserId: otherUserName,
        },
        'participantAvatars': {
          currentUser.uid: currentUserAvatar,
          otherUserId: resolvedOtherAvatar,
        },
        'lastMessage': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }

  Future<void> syncUserAvatar(String userId, String avatarUrl) async {
    final querySnapshot = await _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .get();

    final WriteBatch batch = _db.batch();
    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {
        'participantAvatars.$userId': avatarUrl,
      });
    }

    if (querySnapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  /// Envía un mensaje en una sala de chat específica.
  Future<void> sendMessage(
    String chatId,
    String content, {
    String type = 'text',
    String? mediaUrl,
  }) async {
    final user = authService.currentUser;
    if (user == null) return;

    final messageData = {
      'senderId': user.uid,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
      'mediaUrl': mediaUrl,
    };

    final batch = _db.batch();

    // Agregar mensaje a la subcolección
    final messageRef = _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();
    batch.set(messageRef, messageData);

    // Actualizar el último mensaje en el documento del chat
    batch.update(_db.collection('chats').doc(chatId), {
      'lastMessage': messageData,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    // Enviar notificación al destinatario
    try {
      final chatDoc = await _db.collection('chats').doc(chatId).get();
      if (chatDoc.exists) {
        final participants = List<String>.from(
          (chatDoc.data()?['participants'] as Iterable?) ?? [],
        );
        final otherUserId = participants.firstWhere(
          (id) => id != user.uid,
          orElse: () => '',
        );

        if (otherUserId.isNotEmpty) {
          final currentUserDoc = await _db
              .collection('usuarios')
              .doc(user.uid)
              .get();
          final currentUserName = (currentUserDoc.data()?['nombre'] as String?) ?? 'Usuario';

          await notificationDataService.sendNotification(
            AppNotification(
              id: '',
              userId: otherUserId,
              title: 'Nuevo Mensaje',
              body: '$currentUserName: $content',
              timestamp: DateTime.now(),
              type: 'message',
              relatedId: chatId,
              senderName: currentUserName,
              senderPhoto: currentUserDoc.data()?['photoUrl'] as String?,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error al enviar notificación de mensaje: $e');
    }
  }

  /// Retorna un stream de mensajes para una sala de chat.
  Stream<List<Message>> getMessages(String chatId) {
    final user = authService.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Message.fromMap(doc.data(), doc.id, user.uid))
              .toList(),
        );
  }

  // ─────────────────────────────────────────────
  //  Gestión de Chats
  // ─────────────────────────────────────────────

  Future<void> pinChat(String chatId, bool isPinned) async {
    final user = authService.currentUser;
    if (user == null) return;
    
    if (isPinned) {
      await _db.collection('chats').doc(chatId).update({
        'pinnedBy': FieldValue.arrayUnion([user.uid])
      });
    } else {
      await _db.collection('chats').doc(chatId).update({
        'pinnedBy': FieldValue.arrayRemove([user.uid])
      });
    }
  }

  Future<void> archiveChat(String chatId, bool isArchived) async {
    final user = authService.currentUser;
    if (user == null) return;
    
    if (isArchived) {
      await _db.collection('chats').doc(chatId).update({
        'archivedBy': FieldValue.arrayUnion([user.uid]),
        'pinnedBy': FieldValue.arrayRemove([user.uid]), // Desfijar si se archiva
      });
    } else {
      await _db.collection('chats').doc(chatId).update({
        'archivedBy': FieldValue.arrayRemove([user.uid])
      });
    }
  }

  Future<void> deleteChat(String chatId) async {
    final user = authService.currentUser;
    if (user == null) return;
    
    await _db.collection('chats').doc(chatId).update({
      'deletedBy': FieldValue.arrayUnion([user.uid])
    });
  }

  /// Retorna un stream de salas de chat del usuario actual.
  Stream<List<Chat>> getChatRooms() {
    final user = authService.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('chats')
        .where('participants', arrayContains: user.uid)
        .snapshots()
        .map((snapshot) {
          final chats = snapshot.docs
              .map((doc) => Chat.fromMap(doc.data(), doc.id, user.uid))
              .where((chat) => !chat.deletedBy.contains(user.uid))
              .toList();

          // Ordenamiento del lado del cliente como respaldo más resistente
          chats.sort((a, b) {
            final aTime = a.lastMessage?.timestamp ?? DateTime(2000);
            final bTime = b.lastMessage?.timestamp ?? DateTime(2000);
            return bTime.compareTo(aTime);
          });

          return chats;
        });
  }
}

final chatService = ChatService();
