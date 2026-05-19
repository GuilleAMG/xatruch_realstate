import 'dart:io';
import 'package:flutter/material.dart';

/// Selector de foto de perfil con vista previa de imagen local o remota.
class ProfilePhotoSelector extends StatelessWidget {
  const ProfilePhotoSelector({
    super.key,
    this.newPhoto,
    this.photoUrl,
    required this.onTap,
    this.isSaving = false,
  });

  final File? newPhoto;
  final String? photoUrl;
  final VoidCallback onTap;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Center(
          child: GestureDetector(
            onTap: isSaving ? null : onTap,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: _getAvatarImage(),
                  child: _shouldShowPlaceholder()
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Toca para cambiar la foto',
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
        ),
      ],
    );
  }

  ImageProvider? _getAvatarImage() {
    if (newPhoto != null) return FileImage(newPhoto!);
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return NetworkImage(photoUrl!);
    }
    return null;
  }

  bool _shouldShowPlaceholder() {
    return newPhoto == null && (photoUrl == null || photoUrl!.isEmpty);
  }
}
