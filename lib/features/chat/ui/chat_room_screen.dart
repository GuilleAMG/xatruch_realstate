// Pantalla de chat.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xatruch_realstate/core/widgets/report_dialog.dart';
import 'package:xatruch_realstate/features/chat/data/messages.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';
import 'package:xatruch_realstate/core/services/chat_service.dart';
import 'package:xatruch_realstate/core/services/storage_service.dart';
import 'package:xatruch_realstate/features/chat/ui/widgets/chat_input.dart';
import 'package:xatruch_realstate/features/chat/ui/widgets/message_list.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    required this.otherUserAvatar,
  });
  final String chatId;
  final String otherUserName;
  final String otherUserAvatar;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _currentOtherUserAvatar;

  @override
  void initState() {
    super.initState();
    _loadOtherUserAvatar();
  }

  Future<void> _loadOtherUserAvatar() async {
    final currentUserId = authService.currentUser!.uid;
    final participants = widget.chatId.split('_');
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    if (otherUserId.isNotEmpty) {
      final userData = await userService.getUsuarioById(otherUserId);
      if (mounted) {
        setState(() {
          _currentOtherUserAvatar = userData?['photoUrl'] as String?;
        });
      }
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    try {
      await chatService.sendMessage(widget.chatId, text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al enviar mensaje: $e')));
    }
  }

  Future<void> _sendMedia() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    if (!mounted) return;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Imagen'),
              onTap: () => Navigator.pop(context, 'image'),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video'),
              onTap: () => Navigator.pop(context, 'video'),
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;

    XFile? file;
    if (choice == 'image') {
      file = await _picker.pickImage(source: source);
    } else {
      file = await _picker.pickVideo(source: source);
    }

    if (file == null) return;

    if (!mounted) return;
    setState(() => _isUploading = true);

    try {
      final url = await storageService.uploadChatMedia(
        File(file.path),
        widget.chatId,
      );
      await chatService.sendMessage(
        widget.chatId,
        choice == 'image' ? 'Imagen' : 'Video',
        type: choice,
        mediaUrl: url,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al subir media: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _ChatAppBarTitle(
          avatarUrl: _currentOtherUserAvatar ?? widget.otherUserAvatar,
          name: widget.otherUserName,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.report_problem_outlined),
            tooltip: 'Reportar Usuario',
            onPressed: () {
              final otherUserId = widget.chatId
                  .replaceAll(authService.currentUser!.uid, '')
                  .replaceAll('_', '');
              ReportDialog.show(
                context,
                reportedId: widget.chatId,
                reportedUserId: otherUserId,
                reportType: 'user',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isUploading)
            const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3F888F)),
            ),
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return MessageList(
                  messages: snapshot.data ?? [],
                  otherUserAvatar:
                      _currentOtherUserAvatar ?? widget.otherUserAvatar,
                );
              },
            ),
          ),
          ChatInput(
            controller: _messageController,
            isUploading: _isUploading,
            onSend: _sendMessage,
            onMediaTap: _sendMedia,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class _ChatAppBarTitle extends StatelessWidget {
  const _ChatAppBarTitle({required this.avatarUrl, required this.name});

  final String avatarUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage =
        avatarUrl.isNotEmpty && !avatarUrl.startsWith('assets');

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFF3F888F),
          backgroundImage: hasNetworkImage ? NetworkImage(avatarUrl) : null,
          child: !hasNetworkImage
              ? Image.asset(
                  'assets/icons/default_avatar.png',
                  color: Colors.white,
                  width: 20,
                )
              : null,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            name,
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}