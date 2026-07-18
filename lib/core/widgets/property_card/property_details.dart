// Detalles de tarjeta de propiedad.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/features/properties/data/properties.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/follow_service.dart';
import 'package:xatruch_realstate/core/services/profile_state_service.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';

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
              ListenableBuilder(
                listenable: profileStateService,
                builder: (context, _) {
                  final isCurrentUserSeller = property.sellerId.isNotEmpty &&
                      property.sellerId == authService.currentUser?.uid;

                  if (isCurrentUserSeller) {
                    final sellerAvatar = profileStateService.photoUrl;
                    final sellerName = profileStateService.displayName.isNotEmpty
                        ? profileStateService.displayName
                        : property.sellerName;

                    return Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: (sellerAvatar.isNotEmpty)
                                ? NetworkImage(sellerAvatar) as ImageProvider
                                : null,
                            child: sellerAvatar.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Vendedor: $sellerName',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return FutureBuilder<Map<String, dynamic>?>(
                    future: userService.getUsuarioById(property.sellerId),
                    builder: (context, snapshot) {
                      final sellerData = snapshot.data;
                      final sellerAvatar = sellerData?['photoUrl'] as String?;
                      final sellerName = (sellerData?['nombre'] as String?) ?? property.sellerName;
                      return Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: (sellerAvatar != null && sellerAvatar.isNotEmpty)
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
                            Expanded(
                              child: Text(
                                'Vendedor: $sellerName',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
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
                '${property.bedrooms} Habitaciones',
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
