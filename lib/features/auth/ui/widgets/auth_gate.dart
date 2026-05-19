import 'package:flutter/material.dart';

/// Un widget que escucha un stream de estado de autenticación y alterna
/// entre los constructores [signedInBuilder] y [signedOutBuilder].
class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.signedInStream,
    required this.signedInBuilder,
    required this.signedOutBuilder,
  });

  /// Stream que emite true si el usuario está autenticado, false en caso contrario.
  final Stream<bool> signedInStream;

  /// Constructor para el estado autenticado.
  final WidgetBuilder signedInBuilder;

  /// Constructor para el estado no autenticado.
  final WidgetBuilder signedOutBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: signedInStream,
      builder: (context, snapshot) {
        // Mientras espera el estado inicial, muestra un indicador de carga.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final bool isSignedIn = snapshot.data ?? false;

        if (isSignedIn) {
          return signedInBuilder(context);
        } else {
          return signedOutBuilder(context);
        }
      },
    );
  }
}
