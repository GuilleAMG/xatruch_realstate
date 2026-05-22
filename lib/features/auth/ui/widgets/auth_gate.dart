import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    this.authStateStream,
    required this.signedInBuilder,
    required this.signedOutBuilder,
  });

  /// Inyectable para tests. En producción se usa FirebaseAuth.instance.
  final Stream<User?>? authStateStream;

  final WidgetBuilder signedInBuilder;
  final WidgetBuilder signedOutBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authStateStream ?? FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool isSignedIn = snapshot.data != null;

        if (isSignedIn) {
          return signedInBuilder(context);
        } else {
          return signedOutBuilder(context);
        }
      },
    );
  }
}