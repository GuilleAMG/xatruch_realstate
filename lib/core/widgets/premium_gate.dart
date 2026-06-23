// lib/core/widgets/premium_gate.dart
// Wraps any widget with an entitlement check.
// If the user is not premium, tapping shows the RC paywall.

import 'package:flutter/material.dart';
import '../services/payment_service.dart';

class PremiumGate extends StatelessWidget {
  const PremiumGate({
    super.key,
    required this.child,
    this.onUnlocked,
  });

  /// The widget to show (button, card, etc.)
  final Widget child;

  /// Optional callback fired after a successful purchase/restore.
  final VoidCallback? onUnlocked;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: paymentService.premiumStream,
      builder: (context, snapshot) {
        final isPremium = snapshot.data ?? false;

        if (isPremium) return child;

        // Non-premium: intercept tap and show paywall instead.
        return GestureDetector(
          onTap: () async {
            final unlocked = await paymentService.presentPaywallIfNeeded();
            if (unlocked) onUnlocked?.call();
          },
          child: Stack(
            children: [
              // Show the child but visually dimmed.
              Opacity(opacity: 0.5, child: child),
              // Lock badge.
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}