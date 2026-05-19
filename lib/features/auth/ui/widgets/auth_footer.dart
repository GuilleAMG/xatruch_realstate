import 'package:flutter/material.dart';

/// Footer con un link de navegación para las pantallas de autenticación.
class AuthFooter extends StatelessWidget {
  const AuthFooter({
    super.key,
    required this.message,
    required this.actionText,
    required this.onTap,
  });

  final String message;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextButton(
      onPressed: onTap,
      child: Text.rich(
        TextSpan(
          text: message,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
          children: [
            TextSpan(
              text: actionText,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
