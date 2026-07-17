import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xatruch_realstate/features/profile/ui/subscription_screen.dart';

void main() {
  testWidgets('subscription screen shows a paywall action', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SubscriptionScreen()),
    );

    await tester.pumpAndSettle();

    expect(find.text('Abrir paywall de prueba'), findsOneWidget);
  });
}
