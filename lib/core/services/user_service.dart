// Servicio de usuarios: operaciones CRUD de perfiles, preferencias del usuario,
// gestión de tokens FCM y programación de eliminación de cuenta.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Gestiona las operaciones CRUD de perfiles de usuario y preferencias.
class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─────────────────────────────────────────────
  //  Conexión
  // ─────────────────────────────────────────────

  /// Verifica la conexión a Firestore intentando obtener metadatos de un documento.
  Future<bool> checkConnection() async {
    try {
      await _db
          .collection('usuarios')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      debugPrint('Firestore Connection Error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  //  Usuarios (Users) — CRUD
  // ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getUsuarios() async {
    try {
      final List<Map<String, dynamic>> usuarios = [];
      final QuerySnapshot usuariosQuery = await _db
          .collection('usuarios')
          .get();

      for (var result in usuariosQuery.docs) {
        usuarios.add(result.data() as Map<String, dynamic>);
      }
      return usuarios;
    } catch (e) {
      debugPrint('Error al obtener usuarios: $e');
      return [];
    }
  }

  /// Obtiene un documento de usuario individual por ID.
  Future<Map<String, dynamic>?> getUsuarioById(String id) async {
    try {
      final DocumentSnapshot doc = await _db
          .collection('usuarios')
          .doc(id)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user $id: $e');
      return null;
    }
  }

  /// Crea o actualiza un perfil de usuario vinculado a un UID específico.
  Future<void> addUserProfile(String uid, Map<String, dynamic> userData) async {
    await _db
        .collection('usuarios')
        .doc(uid)
        .set(userData, SetOptions(merge: true));
  }

  /// Agrega un nuevo documento de usuario.
  Future<String?> addUsuario(Map<String, dynamic> userData) async {
    try {
      final DocumentReference docRef = await _db
          .collection('usuarios')
          .add(userData);
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding user: $e');
      return null;
    }
  }

  /// Actualiza un documento de usuario existente.
  Future<bool> updateUsuario(String id, Map<String, dynamic> userData) async {
    try {
      await _db.collection('usuarios').doc(id).update(userData);
      return true;
    } catch (e) {
      debugPrint('Error updating user $id: $e');
      return false;
    }
  }

  /// Elimina un documento de usuario.
  Future<bool> deleteUsuario(String id) async {
    try {
      await _db.collection('usuarios').doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting user $id: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  //  Preferencias de Usuario
  // ─────────────────────────────────────────────

  /// Actualiza la preferencia de notificaciones del usuario actual.
  Future<void> updateNotificationPreference(bool enabled) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('usuarios').doc(user.uid).update({
      'notificationsEnabled': enabled,
    });
  }

  /// Guarda el token FCM del usuario actual en Firestore
  Future<void> saveFcmToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db.collection('usuarios').doc(user.uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  Future<void> clearFcmToken() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db.collection('usuarios').doc(user.uid).set({
        'fcmToken': FieldValue.delete(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error clearing FCM token: $e');
    }
  }

  /// Actualiza la preferencia de tema del usuario actual.
  Future<void> updateThemePreference(bool isDarkMode) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('usuarios').doc(user.uid).update({
      'isDarkMode': isDarkMode,
    });
  }

  /// Actualiza la preferencia de descubrimiento por ubicación del usuario actual.
  Future<void> updateLocationPreference(bool enabled) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('usuarios').doc(user.uid).set({
      'locationEnabled': enabled,
    }, SetOptions(merge: true));
  }

  // ─────────────────────────────────────────────
  //  Gestión de Cuenta
  // ─────────────────────────────────────────────

  /// Programa la eliminación de la cuenta del usuario en 24 horas y cierra su sesión.
  Future<void> scheduleAccountDeletion({required String email}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado.');

    final scheduledDate = DateTime.now().add(const Duration(hours: 24));

    await _db.collection('usuarios').doc(user.uid).update({
      'deletionRequestedAt': DateTime.now().toIso8601String(),
      'scheduledDeletionAt': scheduledDate.toIso8601String(),
      'status': 'pending_deletion',
    });

    // Encolar el correo de advertencia al usuario
    await _db.collection('mail').add({
      'to': [email],
      'message': {
        'subject': 'Aviso de Eliminación de Cuenta - Xatruch Real Estate',
        'html':
            '<p>Has solicitado la eliminación de tu cuenta en Xatruch.</p> <p>Tu perfil y todas tus propiedades serán borradas permanentemente el <b>${scheduledDate.toLocal().toString()}</b>.</p> <p>Si no fuiste tú, por favor contacta a soporte inmediatamente antes de que expire el tiempo (24 horas).</p>',
      },
    });

    await _auth.signOut();
  }
}

final userService = UserService();
