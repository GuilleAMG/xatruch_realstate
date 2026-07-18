// Botón de favoritos.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/core/services/favorite_service.dart';
class PropertyFavoriteButton extends StatelessWidget {
  const PropertyFavoriteButton({super.key, required this.propertyId});
  final String propertyId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StreamBuilder<bool>(
      stream: favoriteService.isFavorite(propertyId),
      builder: (context, snapshot) {
        final isFav = snapshot.data ?? false;
        return GestureDetector(
          onTap: () => favoriteService.toggleFavorite(propertyId),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              size: 20,
              color: isFav ? Colors.red : colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}