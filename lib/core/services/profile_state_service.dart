// Servicio de Perfil de Usuario
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';

class ProfileStateSnapshot {
  const ProfileStateSnapshot({
    required this.displayName,
    required this.email,
    required this.photoUrl,
  });

  final String displayName;
  final String email;
  final String photoUrl;
}

ProfileStateSnapshot resolveProfileStateSnapshot({
  required String? documentName,
  required String? documentEmail,
  required String? documentPhotoUrl,
  required String? authDisplayName,
  required String? authEmail,
}) {
  final resolvedName = (documentName?.trim().isNotEmpty ?? false)
      ? documentName!.trim()
      : (authDisplayName?.trim().isNotEmpty ?? false
            ? authDisplayName!
            : (authEmail?.split('@').first ?? 'Usuario'));

  final resolvedEmail = authEmail ?? documentEmail ?? '';
  final resolvedPhotoUrl = documentPhotoUrl ?? '';

  return ProfileStateSnapshot(
    displayName: resolvedName,
    email: resolvedEmail,
    photoUrl: resolvedPhotoUrl,
  );
}

class ProfileStateService extends ChangeNotifier {
  ProfileStateService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance {
    _listenToAuthChanges();
  }

  final FirebaseFirestore _firestore;
  StreamSubscription<firebase_auth.User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _userDocSubscription;
  String _displayName = '';
  String _email = '';
  String _photoUrl = '';
  bool _isLoading = true;

  String get displayName => _displayName;
  String get email => _email;
  String get photoUrl => _photoUrl;
  bool get isLoading => _isLoading;

  void _listenToAuthChanges() {
    _authSubscription = authService.authStateChanges.listen((user) {
      if (user == null) {
        unawaited(_clearState());
        return;
      }

      unawaited(refresh());
    });
  }

  Future<void> refresh() async {
    final user = authService.currentUser;
    if (user == null) {
      await _clearState();
      return;
    }

    _isLoading = true;
    notifyListeners();

    await _userDocSubscription?.cancel();

    try {
      _userDocSubscription = _firestore
          .collection('usuarios')
          .doc(user.uid)
          .snapshots()
          .listen(
            (snapshot) {
              final data = snapshot.data();
              final resolved = resolveProfileStateSnapshot(
                documentName: data?['nombre'] as String?,
                documentEmail: data?['email'] as String?,
                documentPhotoUrl: data?['photoUrl'] as String?,
                authDisplayName: user.displayName,
                authEmail: user.email,
              );

              _displayName = resolved.displayName;
              _email = resolved.email;
              _photoUrl = resolved.photoUrl;
              _isLoading = false;
              notifyListeners();
            },
            onError: (_) {
              _displayName = user.displayName?.trim().isNotEmpty == true
                  ? user.displayName!
                  : (user.email?.split('@').first ?? 'Usuario');
              _email = user.email ?? '';
              _photoUrl = '';
              _isLoading = false;
              notifyListeners();
            },
          );
    } catch (_) {
      _displayName = user.displayName?.trim().isNotEmpty == true
          ? user.displayName!
          : (user.email?.split('@').first ?? 'Usuario');
      _email = user.email ?? '';
      _photoUrl = '';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAfterProfileUpdate() async {
    await refresh();
  }

  Future<void> _clearState() async {
    await _userDocSubscription?.cancel();
    _userDocSubscription = null;
    _displayName = '';
    _email = '';
    _photoUrl = '';
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _userDocSubscription?.cancel();
    super.dispose();
  }
}

final profileStateService = ProfileStateService();