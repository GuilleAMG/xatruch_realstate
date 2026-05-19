// Coordinador de sesión: orquesta la sincronización de servicios (push tokens,
// pagos, comercio) cuando el estado de autenticación cambia.
import 'package:xatruch_realstate/core/session/session_user.dart';

class SessionCoordinator {
  const SessionCoordinator({
    required this.getPushToken,
    required this.savePushToken,
    required this.bindCommerceUser,
    required this.syncCommerceInfo,
    required this.clearCommerceSession,
  });
  final Future<String?> Function() getPushToken;
  final Future<void> Function(String token) savePushToken;
  final Future<void> Function(SessionUser user) bindCommerceUser;
  final Future<void> Function() syncCommerceInfo;
  final Future<void> Function() clearCommerceSession;

  Future<void> handleAuthStateChanged(SessionUser? user) async {
    if (user == null) {
      await clearCommerceSession();
      return;
    }

    final token = await getPushToken();
    if (token != null) {
      await savePushToken(token);
    }

    await bindCommerceUser(user);
    await syncCommerceInfo();
  }
}
