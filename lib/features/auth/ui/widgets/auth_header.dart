import 'package:flutter/material.dart';
import 'package:xatruch_realstate/core/utils/responsive_utils.dart';

/// Header reusable para las pantallas de autenticación.
/// Incluye un icono o imagen, un título y un subtítulo.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    this.icon,
    this.imagePath,
    required this.title,
    required this.subtitle,
    this.iconSize = 80,
  });

  final IconData? icon;
  final String? imagePath;
  final String title;
  final String subtitle;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        if (imagePath != null)
          Image.asset(
            imagePath!,
            color: colorScheme.primary,
            height: 100,
          )
        else if (icon != null)
          Icon(
            icon,
            size: iconSize,
            color: colorScheme.primary,
          ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.scaledFontSize(28),
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.scaledFontSize(16),
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
