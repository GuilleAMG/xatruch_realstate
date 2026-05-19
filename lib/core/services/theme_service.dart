// Servicio de tema: gestiona el modo claro/oscuro de la aplicación,
// sincronizando la preferencia del usuario con Firestore.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';

class ThemeService extends ChangeNotifier {
  ThemeService() {
    _initTheme();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _initTheme() {
    final user = authService.currentUser;
    if (user != null) {
      _firestore.collection('usuarios').doc(user.uid).snapshots().listen((doc) {
        if (doc.exists) {
          final isDark = (doc.data()?['isDarkMode'] as bool?) ?? false;
          _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
          notifyListeners();
        }
      });
    }
  }

  Future<void> toggleTheme(bool isOn) async {
    final user = authService.currentUser;
    if (user != null) {
      _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
      await _firestore.collection('usuarios').doc(user.uid).update({
        'isDarkMode': isOn,
      });
    }
  }
}

final themeService = ThemeService();
