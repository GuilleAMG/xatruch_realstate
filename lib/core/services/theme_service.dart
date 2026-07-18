// Servicio de tema oscuro y claro.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';

class ThemeService extends ChangeNotifier {
  ThemeService({
    SharedPreferences? sharedPreferences,
    FirebaseFirestore? firestore,
  }) : _sharedPreferences = sharedPreferences,
       _firestore = firestore ?? FirebaseFirestore.instance {
    unawaited(_initTheme());
    authService.authStateChanges.listen((user) {
      if (user != null) {
        unawaited(_syncThemeFromFirestore(user.uid));
      } else {
        unawaited(_restoreThemeFromPreferences());
      }
    });
  }

  static const String _themePreferenceKey = 'theme_mode_dark';

  final SharedPreferences? _sharedPreferences;
  final FirebaseFirestore _firestore;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _initTheme() async {
    await _restoreThemeFromPreferences();

    final user = authService.currentUser;
    if (user != null) {
      await _syncThemeFromFirestore(user.uid);
    }
  }

  Future<void> _restoreThemeFromPreferences() async {
    final prefs = await _getPreferences();
    final isDarkMode = prefs.getBool(_themePreferenceKey);
    _themeMode = isDarkMode == true ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> _syncThemeFromFirestore(String uid) async {
    try {
      final snapshot = await _firestore.collection('usuarios').doc(uid).get();
      final isDark = snapshot.data()?['isDarkMode'] as bool?;
      if (isDark != null) {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
        await _persistThemePreference(isDark);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> toggleTheme(bool isOn) async {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    await _persistThemePreference(isOn);
    notifyListeners();

    final user = authService.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('usuarios').doc(user.uid).set({
          'isDarkMode': isOn,
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  Future<void> _persistThemePreference(bool isDarkMode) async {
    final prefs = await _getPreferences();
    await prefs.setBool(_themePreferenceKey, isDarkMode);
  }

  Future<SharedPreferences> _getPreferences() async {
    return _sharedPreferences ?? await SharedPreferences.getInstance();
  }
}

final themeService = ThemeService();