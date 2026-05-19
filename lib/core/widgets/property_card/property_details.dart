// Detalles de propiedad en tarjeta: muestra título, ubicación, precio,
// información del vendedor y botón de contacto dentro de la tarjeta.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/features/properties/data/properties.dart';
import 'package:xatruch_realstate/features/chat/ui/chat_room_screen.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/follow_service.dart';
import 'package:xatruch_realstate/core/services/chat_service.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';
import 'package:xatruch_realstate/core/utils/responsive_utils.dart';

class PropertyDetails extends StatelessWidget {
  const PropertyDetails({super.key, required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  property.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  property.location,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              FutureBuilder<Map<String, dynamic>?>(
                future: userService.getUsuarioById(property.sellerId),
                builder: (context, snapshot) {
                  final sellerData = snapshot.data;
                  final sellerAvatar = sellerData?['photoUrl'] as String?;
                  return SizedBox(
                    width: 32, // Fixed width for avatar
                    height: 24, // Fixed height
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundImage:
                              (sellerAvatar != null && sellerAvatar.isNotEmpty)
                              ? NetworkImage(sellerAvatar) as ImageProvider
                              : null,
                          child: (sellerAvatar == null || sellerAvatar.isEmpty)
                              ? Icon(
                                  Icons.person,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: Text(
                  'Vendedor: ${property.sellerName}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (property.sellerId != authService.currentUser?.uid)
                StreamBuilder<bool>(
                  stream: followService.isFollowing(property.sellerId),
                  builder: (context, snapshot) {
                    final isFollowing = snapshot.data ?? false;
                    return InkWell(
                      onTap: () =>
                          followService.toggleFollow(property.sellerId),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          isFollowing ? 'Siguiendo' : 'Seguir',
                          style: TextStyle(
                            color: isFollowing
                                ? colorScheme.outline
                                : colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildFeature(
                context,
                Icons.king_bed_outlined,
                '${property.bedrooms} Dormitorios',
              ),
              _buildFeature(
                context,
                Icons.bathtub_outlined,
                '${property.bathrooms} Baños',
              ),
              _buildFeature(
                context,
                Icons.square_foot_outlined,
                '${property.area} m2',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildServiceChip(
                context,
                Icons.electric_bolt,
                'Electricidad',
                property.hasElectricity,
                Colors.amber[700]!,
              ),
              _buildServiceChip(
                context,
                Icons.water_drop,
                'Agua',
                property.hasWater,
                Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                if (property.sellerId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Error: El vendedor no tiene un ID válido.',
                      ),
                    ),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Contactando a ${property.sellerName}...'),
                  ),
                );

                try {
                  final sellerData = await userService.getUsuarioById(
                    property.sellerId,
                  );
                  final String sellerName =
                      (sellerData?['nombre'] as String?) ?? property.sellerName;
                  final String sellerAvatar =
                      (sellerData?['photoUrl'] as String?) ??
                      'assets/icons/default_avatar.png';

                  final chatId = await chatService.getOrCreateChatRoom(
                    property.sellerId,
                    sellerName,
                    otherUserAvatar: sellerAvatar,
                  );

                  if (context.mounted) {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => ChatRoomScreen(
                          chatId: chatId,
                          otherUserName: sellerName,
                          otherUserAvatar: sellerAvatar,
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
              icon: Icon(Icons.message_outlined, size: context.scaledFontSize(18)),
              label: Text(
                context.isSmallPhone ? 'Contactar' : 'Contactar Vendedor',
                style: TextStyle(fontSize: context.scaledFontSize(14)),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: context.isSmallPhone ? 10 : 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceChip(
    BuildContext context,
    IconData icon,
    String label,
    bool available,
    Color activeColor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: available
            ? activeColor.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: available
              ? activeColor.withValues(alpha: 0.4)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: available
                ? activeColor
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: available
                  ? activeColor
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            available ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: available
                ? activeColor
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

// Let's refactor @propertyDetails to be more modular
