// Mapeador de errores de login: convierte codigos de error de Firebase Auth
// en mensajes amigables para el usuario en espanol.
import 'package:firebase_auth/firebase_auth.dart';

String mapLoginError(FirebaseAuthException exception) {
  switch (exception.code) {
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Correo o contraseña incorrectos.';
    case 'user-disabled':
      return 'Esta cuenta ha sido deshabilitada.';
    case 'too-many-requests':
      return 'Demasiados intentos fallidos. Intente más tarde.';
    case 'invalid-email':
      return 'El formato del correo electrónico no es válido.';
    default:
      return 'Error al iniciar sesión: ${exception.message}';
  }
}