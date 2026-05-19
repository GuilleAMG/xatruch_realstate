// Modelo de usuario de sesión: representa los datos básicos del usuario
// autenticado (uid, correo, nombre, teléfono) para uso interno.
class SessionUser {
  const SessionUser({
    required this.uid,
    this.email,
    this.displayName,
    this.phoneNumber,
  });
  final String uid;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
}
