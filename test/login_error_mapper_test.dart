import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xatruch_realstate/features/auth/utils/login_error_mapper.dart';

void main() {
  group('mapLoginError', () {
    test('maps invalid credential style errors to friendly message', () {
      expect(
        mapLoginError(FirebaseAuthException(code: 'invalid-credential')),
        'Correo o contraseña incorrectos.',
      );
      expect(
        mapLoginError(FirebaseAuthException(code: 'wrong-password')),
        'Correo o contraseña incorrectos.',
      );
      expect(
        mapLoginError(FirebaseAuthException(code: 'user-not-found')),
        'Correo o contraseña incorrectos.',
      );
    });

    test('maps disabled and throttled users correctly', () {
      expect(
        mapLoginError(FirebaseAuthException(code: 'user-disabled')),
        'Esta cuenta ha sido deshabilitada.',
      );
      expect(
        mapLoginError(FirebaseAuthException(code: 'too-many-requests')),
        'Demasiados intentos fallidos. Intente más tarde.',
      );
    });

    test('falls back to firebase message for unknown errors', () {
      expect(
        mapLoginError(
          FirebaseAuthException(code: 'custom-error', message: 'detalle'),
        ),
        'Error al iniciar sesión: detalle',
      );
    });
  });
}