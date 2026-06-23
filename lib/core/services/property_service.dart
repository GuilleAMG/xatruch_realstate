// Servicio de propiedades: CRUD de propiedades en Firestore, control de límites
// por suscripción, marcado como vendida y notificaciones a seguidores.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:xatruch_realstate/features/properties/data/properties.dart';
import 'package:xatruch_realstate/features/support/data/notification.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/subscription_service.dart';
import 'package:xatruch_realstate/core/services/follow_service.dart';
import 'package:xatruch_realstate/core/services/notification_data_service.dart';

class PropertyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────
  // SUBSCRIPTION LIMIT HELPERS
  // ─────────────────────────────────────────────

  Future<({int limit, int currentCount})> _getPostLimitInfo(
    String userId,
  ) async {
    final userDoc = await _db.collection('usuarios').doc(userId).get();
    final data = userDoc.data();

    final firestoreTier = (data?['tier'] as String?) ?? 'free';
    final currentCount = (data?['monthlyPostsCount'] as int?) ?? 0;

    final displayName = _firestoreTierToDisplayName(firestoreTier);
    final tierConfig = SubscriptionService.subscriptionTiers[displayName];
    final limit = (tierConfig?['postsPerMonth'] as int?) ?? 0;

    return (limit: limit, currentCount: currentCount);
  }

  String _firestoreTierToDisplayName(String firestoreTier) {
    return switch (firestoreTier) {
      'monthly'     => 'Residente',
      'three_month' => 'Inversionista',
      'six_month'   => 'Inversionista',
      'yearly'      => 'Empresario',
      _             => 'Estudiante',
    };
  }

  // ─────────────────────────────────────────────
  // PROPERTIES (Propiedades)
  // ─────────────────────────────────────────────

  /// Verifica si el usuario puede publicar una nueva propiedad.
  Future<void> checkPostLimit(String userId) async {
    // Temporarily disabled: allow all authenticated users to publish
    // regardless of their subscription tier or monthly post count.
    return;

    // ignore: dead_code
    final (:limit, :currentCount) = await _getPostLimitInfo(userId);
    if (limit != 999 && currentCount >= limit) {
      throw Exception(
        'Has alcanzado el límite de publicaciones mensuales para tu plan.',
      );
    }
  }

  /// Retorna un stream en tiempo real de todas las propiedades ordenadas por fecha,
  /// filtrando las expiradas.
  Stream<List<Property>> getProperties() {
    return _db
        .collection('propiedades')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Property.fromMap(doc.data(), doc.id))
              .where(
                (p) =>
                    !p.isSold &&
                    (p.expiresAt == null ||
                        p.expiresAt!.isAfter(DateTime.now())),
              )
              .toList(),
        );
  }

  /// Retorna las propiedades vendidas de un vendedor específico.
  Stream<List<Property>> getSoldPropertiesList(String sellerId) {
    return _db
        .collection('propiedades')
        .where('sellerId', isEqualTo: sellerId)
        .where('isSold', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) {
            final list = snapshot.docs
                .map((doc) => Property.fromMap(doc.data(), doc.id))
                .toList();
            list.sort((a, b) {
              final dateA = a.soldAt ?? DateTime(2000);
              final dateB = b.soldAt ?? DateTime(2000);
              return dateB.compareTo(dateA);
            });
            return list;
          },
        );
  }

  /// Marca una propiedad como vendida con información del comprador y precio.
  Future<bool> markAsSold({
    required String propertyId,
    required String buyerName,
    required String buyerId,
    required double soldPrice,
  }) async {
    try {
      await _db.collection('propiedades').doc(propertyId).update({
        'isSold': true,
        'buyerName': buyerName,
        'buyerId': buyerId,
        'soldPrice': soldPrice,
        'soldAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error al marcar propiedad como vendida: $e');
      return false;
    }
  }

  /// Agrega un nuevo documento de propiedad a Firestore.
  Future<String?> addProperty(Property property) async {
    try {
      final user = authService.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // Subscription limit check temporarily disabled.
      // final (:limit, :currentCount) = await _getPostLimitInfo(user.uid);
      // if (limit != 999 && currentCount >= limit) {
      //   throw Exception(
      //     'Has alcanzado el límite de publicaciones mensuales para tu plan.',
      //   );
      // }

      // Expiration: base duration on tier.
      final firestoreTier = (await _db
              .collection('usuarios')
              .doc(user.uid)
              .get())
          .data()?['tier'] as String? ??
          'free';
      final durationMonths = _expirationMonthsForTier(firestoreTier);
      final expiresAt =
          DateTime.now().add(Duration(days: 30 * durationMonths));

      final propertyData = property.toMap();
      propertyData['expiresAt'] = expiresAt.toIso8601String();
      propertyData['sellerId'] = user.uid;

      final DocumentReference docRef =
          await _db.collection('propiedades').add(propertyData);
      final propertyId = docRef.id;

      // Increment monthly post count.
      await _db.collection('usuarios').doc(user.uid).update({
        'monthlyPostsCount': FieldValue.increment(1),
      });

      // Notify followers.
      try {
        final sellerId = property.sellerId;
        if (sellerId.isNotEmpty) {
          final followers = await followService.getFollowerIds(sellerId);
          final currentUserDoc =
              await _db.collection('usuarios').doc(sellerId).get();
          final sellerName = (currentUserDoc.data()?['nombre'] as String?) ??
              'Un vendedor que sigues';

          for (final followerId in followers) {
            await notificationDataService.sendNotification(
              AppNotification(
                id: '',
                userId: followerId,
                title: 'Nueva Propiedad',
                body: '$sellerName ha publicado: ${property.title}',
                timestamp: DateTime.now(),
                type: 'new_post',
                relatedId: propertyId,
                senderName: sellerName,
                senderPhoto:
                    currentUserDoc.data()?['photoUrl'] as String?,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error al notificar seguidores: $e');
      }

      return propertyId;
    } catch (e) {
      debugPrint('Error al agregar propiedad: $e');
      rethrow;
    }
  }

  int _expirationMonthsForTier(String firestoreTier) {
    return switch (firestoreTier) {
      'monthly'     => 1,
      'three_month' => 3,
      'six_month'   => 6,
      'yearly'      => 12,
      _             => 1,
    };
  }

  /// Actualiza un documento de propiedad existente en Firestore.
  Future<bool> updateProperty(Property property) async {
    try {
      await _db
          .collection('propiedades')
          .doc(property.id)
          .update(property.toMap());
      return true;
    } catch (e) {
      debugPrint('Error updating property ${property.id}: $e');
      return false;
    }
  }

  /// Elimina un documento de propiedad por ID.
  Future<bool> deleteProperty(String id) async {
    try {
      try {
        final propertyDoc =
            await _db.collection('propiedades').doc(id).get();
        if (propertyDoc.exists) {
          final propertyTitle = (propertyDoc.data()?['title'] as String?) ??
              'una propiedad que te gusta';

          final favoritersQuery = await _db
              .collectionGroup('favoritos')
              .where(FieldPath.documentId, isEqualTo: id)
              .get();

          for (final favDoc in favoritersQuery.docs) {
            final userId = favDoc.reference.parent.parent!.id;
            await notificationDataService.sendNotification(
              AppNotification(
                id: '',
                userId: userId,
                title: 'Propiedad no disponible',
                body:
                    'La propiedad "$propertyTitle" ya no está disponible o ha sido vendida.',
                timestamp: DateTime.now(),
                type: 'property_sold',
                relatedId: id,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error al notificar a usuarios con favoritos: $e');
      }

      await _db.collection('propiedades').doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting property $id: $e');
      return false;
    }
  }
}

final propertyService = PropertyService();