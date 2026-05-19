// Indicador de progreso de subida: muestra el avance de la
// carga de multimedia con barra lineal y porcentaje.
import 'package:flutter/material.dart';

/// Muestra el progreso de subida de multimedia de propiedad como un indicador lineal
/// y un texto de porcentaje.
class UploadProgressIndicator extends StatelessWidget {
  const UploadProgressIndicator({super.key, required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Text(
          progress < 1.0
              ? 'Subiendo archivos... ${(progress * 100).toInt()}%'
              : 'Guardando propiedad...',
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
