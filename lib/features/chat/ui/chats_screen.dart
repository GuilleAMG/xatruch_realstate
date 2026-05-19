// Pantalla de lista de chats: muestra todas las conversaciones
// del usuario con opciones de fijar, archivar y eliminar.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/features/chat/data/messages.dart';
import 'package:xatruch_realstate/core/services/chat_service.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/features/chat/ui/widgets/chat_tile.dart';
import 'package:xatruch_realstate/features/chat/ui/widgets/chat_search_bar.dart';
import 'package:xatruch_realstate/features/chat/ui/widgets/chat_empty_state.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showArchived = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_showArchived ? 'Mensajes Archivados' : 'Mensajes'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_showArchived ? Icons.archive : Icons.archive_outlined),
            tooltip: _showArchived ? 'Ver activos' : 'Ver archivados',
            onPressed: () => setState(() => _showArchived = !_showArchived),
          ),
        ],
      ),
      body: Column(
        children: [
          ChatSearchBar(
            controller: _searchController,
            showClearButton: _searchQuery.isNotEmpty,
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
          Expanded(
            child: StreamBuilder<List<Chat>>(
              stream: chatService.getChatRooms(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return _buildErrorState(snapshot.error.toString(), colorScheme);
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                final currentUserId = authService.currentUser!.uid;
                final chats = _processChats(snapshot.data ?? [], currentUserId);

                if (chats.isEmpty) return ChatEmptyState(isSearch: _searchQuery.isNotEmpty);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: chats.length,
                  itemBuilder: (context, index) => ChatTile(
                    chat: chats[index],
                    currentUserId: currentUserId,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Chat> _processChats(List<Chat> allChats, String currentUserId) {
    var chats = allChats.where((chat) {
      final isArchived = chat.archivedBy.contains(currentUserId);
      return _showArchived ? isArchived : !isArchived;
    }).toList();

    chats.sort((a, b) {
      final aPinned = a.pinnedBy.contains(currentUserId);
      final bPinned = b.pinnedBy.contains(currentUserId);
      
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      
      final aTime = a.lastMessage?.timestamp ?? DateTime(2000);
      final bTime = b.lastMessage?.timestamp ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });

    if (_searchQuery.isNotEmpty) {
      chats = chats.where((chat) => chat.otherUserName.toLowerCase().contains(_searchQuery)).toList();
    }

    return chats;
  }

  Widget _buildErrorState(String error, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            const Text('Error al cargar conversaciones', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
