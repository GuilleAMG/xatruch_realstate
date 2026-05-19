import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/features/support/ui/privacy_policy_screen.dart';
import 'package:xatruch_realstate/features/support/ui/terms_and_conditions_screen.dart';

void main() {
  testWidgets('Privacy policy screen renders legal content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: PrivacyPolicyScreen()),
    );

    expect(find.text('Política de Privacidad'), findsOneWidget);
    expect(find.textContaining('Última actualización'), findsOneWidget);
    expect(find.text('1. Recopilación de Información'), findsOneWidget);
    expect(find.text('4. Compartir con Terceros'), findsOneWidget);
  });

  testWidgets('Terms screen renders legal content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: TermsAndConditionsScreen()),
    );

    expect(find.text('Términos y Condiciones'), findsOneWidget);
    expect(find.textContaining('Última actualización'), findsOneWidget);
    expect(find.text('1. Aceptación de los Términos'), findsOneWidget);
    expect(find.text('4. Terminación de la Cuenta'), findsOneWidget);
  });
}
