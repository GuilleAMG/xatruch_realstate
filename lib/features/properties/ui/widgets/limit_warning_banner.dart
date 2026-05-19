// Banner de advertencia de limite: muestra un aviso cuando el
// usuario ha alcanzado su limite de publicaciones mensuales.
import 'package:flutter/material.dart';

/// Muestra un banner de advertencia cuando el usuario ha alcanzado su límite de publicaciones.
class LimitWarningBanner extends StatelessWidget {
  const LimitWarningBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
