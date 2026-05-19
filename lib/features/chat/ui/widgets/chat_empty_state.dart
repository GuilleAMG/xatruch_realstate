import 'package:flutter/material.dart';

/// Estado vacío para la lista de chats o resultados de búsqueda.
class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.isSearch,
  });

  final bool isSearch;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearch ? Icons.search_off : Icons.chat_bubble_outline,
            size: 80,
            color: colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            isSearch ? 'No se encontraron resultados' : 'No tienes chats aún',
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
