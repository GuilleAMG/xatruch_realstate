// Controlador de configuracion: gestiona las preferencias del usuario
// como notificaciones, tema oscuro y ubicacion.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/notification_service.dart';
import 'package:xatruch_realstate/core/services/theme_service.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';

class SettingsController extends ChangeNotifier {
  SettingsController({
    String? Function()? getCurrentUserId,
    Future<Map<String, dynamic>?> Function(String uid)? getUserData,
    Future<bool> Function()? isPermissionGranted,
    Future<bool> Function()? requestNotificationPermission,
    Future<void> Function(bool value)? updateNotificationPreference,
    Future<void> Function(bool value)? updateLocationPreference,
    Future<void> Function(bool value)? toggleTheme,
  })  : _getCurrentUserId =
            getCurrentUserId ?? (() => authService.currentUser?.uid),
        _getUserData =
            getUserData ?? ((uid) => userService.getUsuarioById(uid)),
        _isPermissionGranted =
            isPermissionGranted ?? (() => notificationService.isPermissionGranted()),
        _requestNotificationPermission =
            requestNotificationPermission ?? (() => notificationService.requestPermissions()),
        _updateNotificationPreference =
            updateNotificationPreference ??
            // Capture uid at call time — not at construction time.
            ((value) {
              final uid = authService.currentUser?.uid;
              if (uid == null) return Future.value();
              return userService.updateNotificationPreference(
                uid: uid,
                enabled: value,
              );
            }),
        _updateLocationPreference =
            updateLocationPreference ??
            ((value) {
              final uid = authService.currentUser?.uid;
              if (uid == null) return Future.value();
              return userService.updateLocationPreference(
                uid: uid,
                enabled: value,
              );
            }),
        _toggleTheme =
            toggleTheme ?? ((value) => themeService.toggleTheme(value));

  final String? Function() _getCurrentUserId;
  final Future<Map<String, dynamic>?> Function(String uid) _getUserData;
  final Future<bool> Function() _isPermissionGranted;
  final Future<bool> Function() _requestNotificationPermission;
  final Future<void> Function(bool value) _updateNotificationPreference;
  final Future<void> Function(bool value) _updateLocationPreference;
  final Future<void> Function(bool value) _toggleTheme;

  bool notificationsEnabled = false;
  bool darkModeEnabled = false;
  bool locationEnabled = true;

  Future<void> load() async {
    final userId = _getCurrentUserId();
    if (userId == null) return;

    final userData = await _getUserData(userId);
    final notificationPref = userData?['notificationsEnabled'] as bool?;
    final darkPref = userData?['isDarkMode'] as bool?;
    final locationPref = userData?['locationEnabled'] as bool?;
    final permissionGranted = await _isPermissionGranted();

    notificationsEnabled = (notificationPref ?? false) && permissionGranted;
    darkModeEnabled = darkPref ?? false;
    locationEnabled = locationPref ?? true;

    await _toggleTheme(darkModeEnabled);
    notifyListeners();
  }

  Future<bool> handleNotificationToggle(bool value) async {
    if (value) {
      final granted = await _requestNotificationPermission();
      if (!granted) return false;
    }

    await _updateNotificationPreference(value);
    notificationsEnabled = value;
    notifyListeners();
    return true;
  }

  Future<void> handleDarkModeToggle(bool value) async {
    await _toggleTheme(value);
    darkModeEnabled = value;
    notifyListeners();
  }

  Future<void> handleLocationToggle(bool value) async {
    await _updateLocationPreference(value);
    locationEnabled = value;
    notifyListeners();
  }
}