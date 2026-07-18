// Modelo de usuario de sesión.
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
