// Controlador de inicio de sesion.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/notification_service.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';
import 'package:xatruch_realstate/features/auth/utils/login_error_mapper.dart';

class LoginController extends ChangeNotifier {
  bool _isDisposed = false;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (!_isDisposed) notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    if (!_isDisposed) notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      await authService.loginUser(email, password);

      final token = await notificationService.getToken();
      if (token != null) {
        await userService.saveFcmToken(token);
      }

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(mapLoginError(e));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Error inesperado: $e');
      return false;
    }
  }
}