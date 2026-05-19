// Pantalla de suscripcion: muestra los planes disponibles
// y permite al usuario cambiar su nivel de suscripcion.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/subscription_service.dart';
import 'package:xatruch_realstate/core/services/payment_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:xatruch_realstate/features/profile/ui/widgets/current_plan_header.dart';

import 'package:xatruch_realstate/features/profile/ui/widgets/restore_purchases_button.dart';
import 'package:xatruch_realstate/features/profile/ui/widgets/subscription_tier_card.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = true;
  String _currentTier = 'Estudiante';
  int _monthlyPosts = 0;
  Offerings? _offerings;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    final user = authService.currentUser;
    if (user == null) return;

    final data = await subscriptionService.getSubscriptionInfo(user.uid);
    final offerings = await paymentService.getOfferings();

    if (mounted) {
      setState(() {
        _currentTier = (data['tier'] as String?) ?? 'Estudiante';
        _monthlyPosts = (data['monthlyPostsCount'] as int?) ?? 0;
        _offerings = offerings;
        _isLoading = false;
      });
    }
  }

  Future<void> _purchasePlan(String tier, Package? rcPackage) async {
    final user = authService.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    bool success = false;
    if (rcPackage != null) {
      success = await paymentService.purchasePackage(rcPackage);
    } else {
      // Local fallback si no hay RevenueCat
      await subscriptionService.updateUserTier(user.uid, tier);
      success = true;
    }

    if (success) {
      await _loadSubscriptionData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Suscripción procesada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('El pago fue cancelado o hubo un error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);
    final success = await paymentService.restorePurchases();
    await _loadSubscriptionData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Compras restauradas exitosamente'
              : 'Error al restaurar compras'),
          backgroundColor:
              success ? Colors.green : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes de Suscripción'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CurrentPlanHeader(
                    currentTier: _currentTier,
                    monthlyPosts: _monthlyPosts,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Mejora tu alcance',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elige el plan que mejor se adapte a tus necesidades inmobiliarias.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...SubscriptionService.subscriptionTiers.entries.map((entry) {
                    Package? rcPackage;
                    if (_offerings != null && _offerings!.current != null) {
                      try {
                        rcPackage = _offerings!.current!.availablePackages
                            .firstWhere((p) =>
                                p.identifier.toLowerCase() ==
                                    entry.key.toLowerCase() ||
                                p.storeProduct.title
                                    .toLowerCase()
                                    .contains(entry.key.toLowerCase()));
                      } catch (_) {}
                    }

                    return SubscriptionTierCard(
                      tier: entry.key,
                      config: entry.value,
                      isCurrent: _currentTier == entry.key,
                      rcPackage: rcPackage,
                      onPurchase: () => _purchasePlan(entry.key, rcPackage),
                    );
                  }),
                  const SizedBox(height: 24),
                  RestorePurchasesButton(
                    isLoading: _isLoading,
                    onPressed: _restorePurchases,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
