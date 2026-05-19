// Tarjeta de nivel de suscripcion: muestra los detalles y beneficios
// de cada plan de suscripcion disponible.
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Muestra un nivel de suscripción individual como una tarjeta estilizada con características
/// y un botón de compra/selección.
class SubscriptionTierCard extends StatelessWidget {
  const SubscriptionTierCard({
    super.key,
    required this.tier,
    required this.config,
    required this.isCurrent,
    this.rcPackage,
    this.onPurchase,
  });

  final String tier;
  final Map<String, dynamic> config;
  final bool isCurrent;
  final Package? rcPackage;
  final VoidCallback? onPurchase;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final postsPerMonth = (config['postsPerMonth'] as int?) ?? 0;
    final price = (config['price'] as num?) ?? 0;

    final (IconData icon, Color tierColor) = _tierStyle(colorScheme);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isCurrent ? tierColor.withValues(alpha: 0.05) : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrent ? tierColor : colorScheme.outlineVariant,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: tierColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tier,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        (rcPackage != null
                                ? rcPackage!.storeProduct.priceString
                                : (price == 0 ? 'Gratis L. 0' : 'L. $price/mes')) +
                            (postsPerMonth == 0
                                ? ' - No permite publicar.'
                                : ' - $postsPerMonth publicaciones'),
                        style: TextStyle(
                          color: tierColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: tierColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Actual',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (config.containsKey('description') &&
                config['description'].toString().isNotEmpty)
              _FeatureRow(
                icon: Icons.check_circle_outline,
                label: (config['description'] as String?) ?? '',
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCurrent ? null : onPurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrent ? null : tierColor,
                  foregroundColor: isCurrent ? null : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(isCurrent ? 'Plan Actual' : 'Seleccionar Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Retorna el icono y color asociados al nombre del nivel.
  (IconData, Color) _tierStyle(ColorScheme colorScheme) {
    return switch (tier) {
      'Estudiante' => (Icons.school, Colors.blue),
      'Residente' => (Icons.home, Colors.green),
      'Inversionista' => (Icons.trending_up, Colors.orange),
      'Empresario' => (Icons.business, Colors.purple),
      _ => (Icons.star, colorScheme.primary),
    };
  }
}

/// Fila pequeña que muestra un icono de verificación y una etiqueta de característica.
class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 15),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
