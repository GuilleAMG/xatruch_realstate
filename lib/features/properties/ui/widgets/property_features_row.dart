// Fila de caracteristicas: muestra los atributos principales de la
// propiedad (habitaciones, banos, area) en chips horizontales.
import 'package:flutter/material.dart';

/// Fila horizontal de chips de características de propiedad (habitaciones, baños, área).
class PropertyFeaturesRow extends StatelessWidget {
  const PropertyFeaturesRow({
    super.key,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
  });
  final int bedrooms;
  final int bathrooms;
  final double area;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _SmallFeature(
          icon: Icons.king_bed_outlined,
          text: '$bedrooms Dorms',
          colorScheme: colorScheme,
        ),
        _SmallFeature(
          icon: Icons.bathtub_outlined,
          text: '$bathrooms Baños',
          colorScheme: colorScheme,
        ),
        _SmallFeature(
          icon: Icons.square_foot_outlined,
          text: '${area.toStringAsFixed(0)} m2',
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _SmallFeature extends StatelessWidget {
  const _SmallFeature({
    required this.icon,
    required this.text,
    required this.colorScheme,
  });
  final IconData icon;
  final String text;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: colorScheme.onSurface)),
      ],
    );
  }
}
