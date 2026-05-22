// Servicio de favoritos: gestiona las propiedades marcadas como favoritas
// por cada usuario, incluyendo notificaciones al vendedor.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:xatruch_realstate/features/support/data/notification.dart';
import 'package:xatruch_realstate/core/services/notification_data_service.dart';

/// Gestiona los favoritos de propiedades por usuario.
class FavoriteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Alterna una propiedad como favorita para el usuario actual.
  /// Envía una notificación al vendedor cuando se agrega un favorito.
  Future<void> toggleFavorite(String propertyId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final favRef = _db
        .collection('usuarios')
        .doc(user.uid)
        .collection('favoritos')
        .doc(propertyId);

    final doc = await favRef.get();
    if (doc.exists) {
      await favRef.delete();
    } else {
      await favRef.set({'addedAt': DateTime.now().toIso8601String()});

      try {
        final propertyDoc = await _db
            .collection('propiedades')
            .doc(propertyId)
            .get();
        if (propertyDoc.exists) {
          final sellerId = propertyDoc.data()?['sellerId'] as String?;
          final propertyTitle =
              (propertyDoc.data()?['title'] as String?) ?? 'tu propiedad';
          if (sellerId != null && sellerId != user.uid) {
            final currentUserDoc = await _db
                .collection('usuarios')
                .doc(user.uid)
                .get();
            final currentUserName =
                (currentUserDoc.data()?['nombre'] as String?) ?? 'Alguien';

            await notificationDataService.sendNotification(
              AppNotification(
                id: '',
                userId: sellerId,
                title: '¡Nueva Favorita!',
                body: '$currentUserName marcó como favorita "$propertyTitle"',
                timestamp: DateTime.now(),
                type: 'favorite',
                relatedId: propertyId,
                senderName: currentUserName,
                senderPhoto: currentUserDoc.data()?['photoUrl'] as String?,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error al enviar notificación de favorito: $e');
      }
    }
  }

  /// Retorna un stream en tiempo real de los IDs de propiedades favoritas del usuario actual.
  Stream<Set<String>> getFavoriteIds() {
    return _auth.authStateChanges().asyncExpand((User? user) {
      if (user == null) return Stream.value(<String>{});
      return _db
          .collection('usuarios')
          .doc(user.uid)
          .collection('favoritos')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
    });
  }

  /// Retorna un stream que indica si una propiedad específica es favorita del usuario actual.
  Stream<bool> isFavorite(String propertyId) {
    return _auth.authStateChanges().asyncExpand((User? user) {
      if (user == null) return Stream.value(false);
      return _db
          .collection('usuarios')
          .doc(user.uid)
          .collection('favoritos')
          .doc(propertyId)
          .snapshots()
          .map((snapshot) => snapshot.exists);
    });
  }
}

final favoriteService = FavoriteService();
