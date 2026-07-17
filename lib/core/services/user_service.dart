// Handles all Firestore operations related to the usuarios collection.
// On user creation, writes the default role/tier fields required by
// the Firestore security rules (isPremium, isAdmin, tier, premiumSince).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:xatruch_realstate/features/profile/data/user.dart' as user_model;

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  // ─────────────────────────────────────────────
  // DOCUMENT REFERENCE HELPERS
  // ─────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('usuarios').doc(uid);

  // ─────────────────────────────────────────────
  // CREATE USER DOCUMENT ON REGISTRATION
  // ─────────────────────────────────────────────

  Future<void> createUserDocument({
    required String uid,
    required String nombre,
    required String email,
    String? photoUrl,
    String? telefono,
    String? dni,
  }) async {
    final docRef = _userDoc(uid);
    final snapshot = await docRef.get();
    if (snapshot.exists) return;

    await docRef.set({
      'uid': uid,
      'nombre': nombre,
      'email': email,
      'photoUrl': photoUrl ?? '',
      'telefono': telefono ?? '',
      'dni': dni ?? '',
      'isPremium': false,
      'isAdmin': false,
      'tier': 'Estudiante',
      'premiumSince': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'fcmToken': '',
      // ── Preferences ─────────────────────────────
      'notificationsEnabled': true,
      'locationEnabled': false,
      // ── Account ──────────────────────────────────
      'scheduledForDeletion': false,
      'deletionScheduledAt': null,
    });
  }

  /// Alias used by register_screen.dart and profile_controller.dart.
  /// Delegates to [createUserDocument].
  Future<void> addUserProfile({
    required String uid,
    required String nombre,
    required String email,
    String? photoUrl,
    String? telefono,
    String? dni,
  }) =>
      createUserDocument(
        uid: uid,
        nombre: nombre,
        email: email,
        photoUrl: photoUrl,
        telefono: telefono,
        dni: dni,
      );

  // ─────────────────────────────────────────────
  // FCM TOKEN
  // ─────────────────────────────────────────────

  /// Saves the FCM token for the current user.
  /// Uses merge:true to safely write even if the user document
  /// hasn't been fully created yet (e.g. race condition on first login).
  Future<void> saveFcmToken(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      debugPrint('[UserService] ⚠️ saveFcmToken: No user logged in, skipping');
      return;
    }

    try {
      debugPrint('[UserService] Saving FCM token for user $uid');
      await _userDoc(uid).set({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('[UserService] ✅ FCM token saved for user $uid');
    } catch (e) {
      debugPrint('[UserService] ❌ Error saving FCM token: $e');
      rethrow; // Re-throw so caller can handle or log
    }
  }

  /// Clears the FCM token on logout so the user stops
  /// receiving push notifications on this device.
  /// Uses merge:true for the same safety reason as [saveFcmToken].
  Future<void> clearFcmToken() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      debugPrint('[UserService] ⚠️ clearFcmToken: No user logged in, skipping');
      return;
    }

    try {
      debugPrint('[UserService] Clearing FCM token for user $uid');
      await _userDoc(uid).set({
        'fcmToken': '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('[UserService] ✅ FCM token cleared for user $uid');
    } catch (e) {
      debugPrint('[UserService] ❌ Error clearing FCM token: $e');
      // Don't rethrow on logout - just log the error
    }
  }

  // ─────────────────────────────────────────────
  // READ USER DATA (COMPLETE USER MODEL)
  // ─────────────────────────────────────────────

  Future<user_model.User?> getUser(String uid) async {
    try {
      final snapshot = await _userDoc(uid).get();
      if (!snapshot.exists) return null;
      return user_model.User.fromMap(snapshot.data()!, uid);
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  Stream<user_model.User?> streamUser(String uid) {
    return _userDoc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return user_model.User.fromMap(snapshot.data()!, uid);
    });
  }

  /// Alias para obtener datos del usuario como Map (usado por legacy code).
  /// Retorna los datos crudos del documento para acceso por índice.
  Future<Map<String, dynamic>?> getUsuarioById(String uid) async {
    try {
      final snapshot = await _userDoc(uid).get();
      if (!snapshot.exists) return null;
      return snapshot.data();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // UPDATE USER (COMPLETE USER MODEL)
  // ─────────────────────────────────────────────

  Future<void> updateUser(user_model.User user) async {
    try {
      await _userDoc(user.uid).update(user.toMap());
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────
  // UPDATE PROFILE (owner-only fields)
  // ─────────────────────────────────────────────

  Future<void> updateProfile({
    required String uid,
    String? nombre,
    String? photoUrl,
    String? telefono,
    String? dni,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (nombre != null) updates['nombre'] = nombre;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (telefono != null) updates['telefono'] = telefono;
    if (dni != null) updates['dni'] = dni;

    await _userDoc(uid).update(updates);
  }

  // ─────────────────────────────────────────────
  // PREFERENCES
  // ─────────────────────────────────────────────

  /// Toggles push notification preference for the current user.
  Future<void> updateNotificationPreference({
    required String uid,
    required bool enabled,
  }) async {
    await _userDoc(uid).update({
      'notificationsEnabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Toggles location sharing preference for the current user.
  Future<void> updateLocationPreference({
    required String uid,
    required bool enabled,
  }) async {
    await _userDoc(uid).update({
      'locationEnabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─────────────────────────────────────────────
  // ACCOUNT DELETION
  // ─────────────────────────────────────────────

  /// Marks the account for deletion after a grace period.
  /// Actual deletion should be handled by a Cloud Function.
  Future<void> scheduleAccountDeletion(String uid) async {
    await _userDoc(uid).update({
      'scheduledForDeletion': true,
      'deletionScheduledAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─────────────────────────────────────────────
  // CONNECTIVITY CHECK
  // ─────────────────────────────────────────────

  /// Checks Firestore reachability by attempting a lightweight read.
  /// Returns true if connected, false otherwise.
  /// Used in main.dart to gate app startup.
  Future<bool> checkConnection() async {
    try {
      debugPrint('[UserService] Checking Firestore connection...');
      await _db.collection('usuarios').limit(1).get(
        const GetOptions(source: Source.server),
      );
      debugPrint('[UserService] ✅ Firestore connection OK');
      return true;
    } catch (e) {
      debugPrint('[UserService] ❌ Firestore connection FAILED: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // DELETE USER DOCUMENT (admin only — enforced by rules)
  // ─────────────────────────────────────────────

  Future<void> deleteUserDocument(String uid) async {
    await _userDoc(uid).delete();
  }
}

final userService = UserService();