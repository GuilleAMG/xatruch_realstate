import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';
import 'package:xatruch_realstate/core/services/storage_service.dart';
import 'package:xatruch_realstate/core/services/chat_service.dart';

/// Controlador para gestionar la lógica de la pantalla de perfil.
class ProfileController extends ChangeNotifier {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dniController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;
  String? photoUrl;
  File? newPhoto;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dniController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    final user = authService.currentUser;
    if (user == null) return;

    final data = await userService.getUsuarioById(user.uid);

    nameController.text = (data?['nombre'] as String?) ?? '';
    emailController.text = (data?['email'] as String?) ?? user.email ?? '';
    phoneController.text = (data?['telefono'] as String?) ?? '';
    dniController.text = (data?['dni'] as String?) ?? '';
    photoUrl = data?['photoUrl'] as String?;
    isLoading = false;
    notifyListeners();
  }

  void setNewPhoto(File? photo) {
    newPhoto = photo;
    notifyListeners();
  }

  void removePhoto() {
    newPhoto = null;
    photoUrl = '';
    notifyListeners();
  }

  Future<bool> saveProfile() async {
    final user = authService.currentUser;
    if (user == null) return false;

    isSaving = true;
    notifyListeners();

    try {
      await user.reload();
      //final refreshedUser = FirebaseAuth.instance.currentUser;
      String? uploadedPhotoUrl = photoUrl;

      if (newPhoto != null) {
        uploadedPhotoUrl = await storageService.uploadFile(
          newPhoto!,
          'usuarios/${user.uid}/profile.jpg',
        );
      }

      // updateProfile is the correct method here — the user document
      // already exists (created during registration via addUserProfile).
      // addUserProfile / createUserDocument should only be called once,
      // at registration time.
      await userService.updateProfile(
        uid: user.uid,
        nombre: nameController.text.trim(),
        photoUrl: uploadedPhotoUrl ?? '',
        telefono: phoneController.text.trim(),
        dni: dniController.text.trim(),
      );

      final finalAvatar = (uploadedPhotoUrl?.isNotEmpty ?? false)
          ? uploadedPhotoUrl!
          : 'assets/icons/default_avatar.png';

      await chatService.syncUserAvatar(user.uid, finalAvatar);

      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      isSaving = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Inicia el proceso de cambio de correo (envía verificación).
  Future<void> startEmailUpdate(String newEmail) async {
    final user = authService.currentUser;
    if (user == null) return;
    await user.verifyBeforeUpdateEmail(newEmail);
  }

  /// Inicia el proceso de verificación de teléfono vía SMS.
  Future<String> sendPhoneVerification(String phone) async {
    final completer = Completer<String>();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (_) {},
      verificationFailed: (e) => completer.completeError(e),
      codeSent: (id, _) => completer.complete(id),
      codeAutoRetrievalTimeout: (id) =>
          !completer.isCompleted ? completer.complete(id) : null,
    );

    return completer.future;
  }

  /// Verifica el código SMS y actualiza el teléfono.
  Future<void> verifySmsCode(String verificationId, String smsCode) async {
    final user = authService.currentUser;
    if (user == null) return;

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    await user.updatePhoneNumber(credential);
    phoneController.text = user.phoneNumber ?? phoneController.text;
    notifyListeners();
  }
}