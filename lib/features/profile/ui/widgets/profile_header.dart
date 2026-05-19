import 'package:flutter/material.dart';

/// Encabezado del perfil con avatar, nombre y correo.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userEmail,
    this.photoUrl,
  });

  final String userName;
  final String userEmail;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasNetworkImage = photoUrl != null && photoUrl!.isNotEmpty;

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: colorScheme.primary,
            backgroundImage: hasNetworkImage ? NetworkImage(photoUrl!) : null,
            child: !hasNetworkImage
                ? Image.asset(
                    'assets/icons/default_avatar.png',
                    color: colorScheme.onPrimary,
                    width: 60,
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
