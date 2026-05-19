// Encabezado del plan actual: muestra el nivel de suscripcion
// y el conteo de publicaciones mensuales del usuario.
import 'package:flutter/material.dart';

/// Muestra el nivel de suscripción actual del usuario y el conteo de publicaciones mensuales
/// dentro de una tarjeta con banner de gradiente.
class CurrentPlanHeader extends StatelessWidget {
  const CurrentPlanHeader({
    super.key,
    required this.currentTier,
    required this.monthlyPosts,
  });
  final String currentTier;
  final int monthlyPosts;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final tierColor = switch (currentTier) {
      'Estudiante' => Colors.blue,
      'Residente' => Colors.green,
      'Inversionista' => Colors.orange,
      'Empresario' => Colors.purple,
      _ => colorScheme.primary,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tierColor, tierColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: tierColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tu Plan Actual',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            currentTier,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.post_add, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                'Publicaciones este mes: $monthlyPosts',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
