// Servicio de autenticación biométrica: verifica disponibilidad de biometría,
// autentica al usuario y lista los tipos biométricos disponibles en el dispositivo.
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<bool> authenticate() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Autentícate para habilitar el acceso seguro',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Permite respaldo con PIN/Patrón en emulador
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Error de autenticación biométrica: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('Error al obtener biometría disponible: $e');
      return <BiometricType>[];
    }
  }
}

final biometricService = BiometricService();
