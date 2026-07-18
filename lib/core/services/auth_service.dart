// Servicio de autenticación
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:xatruch_realstate/core/services/notification_service.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Emite los cambios de autenticación de Firebase.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Emite true si hay un usuario logueado, false si no.
  Stream<bool> get isSignedIn =>
      _auth.authStateChanges().map((user) => user != null);

  /// Registra un nuevo usuario con Firebase Auth.
  Future<UserCredential> registerUser(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      debugPrint('Auth Registration Error: $e');
      rethrow;
    }
  }

  /// Inicia sesión de un usuario existente.
  Future<UserCredential> loginUser(String email, String password) async {
    try {
      debugPrint('Auth: Attempting login for $email...');

      final result = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              debugPrint('Auth: Login timed out after 60 seconds');
              throw FirebaseAuthException(
                code: 'timeout',
                message:
                    'La conexión ha expirado. Por favor, intente de nuevo.',
              );
            },
          );

      debugPrint('Auth: Login successful for ${result.user?.email}');
      return result;
    } on FirebaseAuthException catch (e) {
      debugPrint('Auth: Firebase Auth Error (${e.code}): ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Auth: Unexpected Login Error: $e');
      rethrow;
    }
  }

  /// Retorna el usuario autenticado, o null si no hay sesión activa.
  User? get currentUser => _auth.currentUser;

  /// Cierra la sesión.
  Future<void> signOut() async {
    try {
      await notificationService.deleteToken();
      await userService.clearFcmToken();
    } catch (e) {
      debugPrint('Auth: Error clearing FCM token on signOut: $e');
    }
    await _auth.signOut();
  }

  /// Envía correo de restablecimiento de contraseña.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      debugPrint('Auth Password Reset Error: $e');
      rethrow;
    }
  }

  /// Verifica si el usuario actual tiene factores MFA registrados
  Future<bool> isMfaEnrolled() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      return false;
    }
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      final factors = await user.multiFactor.getEnrolledFactors();
      return factors.isNotEmpty;
    } catch (e) {
      debugPrint('Error en isMfaEnrolled: $e');
      return false;
    }
  }

  /// Inicia una sesión MFA.
  Future<MultiFactorSession> getMfaSession() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      throw UnimplementedError('MFA is not supported on desktop platforms');
    }
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-signed-in',
        message: 'Usuario no autenticado.',
      );
    }
    return await user.multiFactor.getSession();
  }

  /// Finaliza la inscripción MFA.
  Future<void> enrollMfa(
    MultiFactorAssertion assertion, {
    String displayName = 'Mi Teléfono',
  }) async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      throw UnimplementedError('MFA is not supported on desktop platforms');
    }
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-signed-in',
        message: 'Usuario no autenticado.',
      );
    }
    await user.multiFactor.enroll(assertion, displayName: displayName);
  }

  /// Elimina el primer factor MFA registrado.
  Future<void> unenrollMfa() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      return;
    }
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'not-signed-in',
          message: 'Usuario no autenticado.',
        );
      }
      final factors = await user.multiFactor.getEnrolledFactors();
      if (factors.isNotEmpty) {
        await user.multiFactor.unenroll(factorUid: factors.first.uid);
      }
    } catch (e) {
      debugPrint('Error en unenrollMfa: $e');
    }
  }
}

final authService = AuthService();