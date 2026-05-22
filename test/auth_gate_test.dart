import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xatruch_realstate/features/auth/ui/widgets/auth_gate.dart';

class MockUser extends Mock implements User {}

void main() {
  testWidgets('AuthGate shows loading indicator while waiting for auth state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          authStateStream: const Stream<User?>.empty(),
          signedInBuilder: (_) => const Text('SIGNED_IN'),
          signedOutBuilder: (_) => const Text('SIGNED_OUT'),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AuthGate shows signed-out builder when no session exists', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          authStateStream: Stream<User?>.value(null),
          signedInBuilder: (_) => const Text('SIGNED_IN'),
          signedOutBuilder: (_) => const Text('SIGNED_OUT'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('SIGNED_OUT'), findsOneWidget);
    expect(find.text('SIGNED_IN'), findsNothing);
  });

  testWidgets('AuthGate shows signed-in builder when session exists', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          authStateStream: Stream<User?>.value(MockUser()),
          signedInBuilder: (_) => const Text('SIGNED_IN'),
          signedOutBuilder: (_) => const Text('SIGNED_OUT'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('SIGNED_IN'), findsOneWidget);
    expect(find.text('SIGNED_OUT'), findsNothing);
  });
}