// Boton de restaurar compras: permite al usuario recuperar
// sus compras anteriores de la tienda de aplicaciones.
import 'package:flutter/material.dart';

/// Botón de texto centrado que activa la restauración de compras.
class RestorePurchasesButton extends StatelessWidget {
  const RestorePurchasesButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: TextButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: const Icon(Icons.restore),
        label: const Text('Restaurar Compras'),
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
