// Servicio de propiedades.
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

  // ─────── Limites por Suscripción ─────────────────────────────────────────────

  /// Obtiene el límite de publicaciones mensuales del usuario y cuántas
  /// lleva publicadas este mes, para decidir si puede seguir publicando.
  Future<({int limit, int currentCount})> _getPostLimitInfo(
    String userId,
  ) async {
    final userDoc = await _db.collection('usuarios').doc(userId).get();
    final data = userDoc.data();

    // Nombre de plan tal como está guardado en Firestore; 'Estudiante'
    // (plan gratis) si el documento no existe o el campo no fue seteado.
    final tier = (data?['tier'] as String?) ?? 'Estudiante';
    final currentCount = (data?['monthlyPostsCount'] as int?) ?? 0;

    final tierConfig = SubscriptionService.subscriptionTiers[tier];
    // 0 publicaciones permitidas si el plan no está configurado.
    final limit = (tierConfig?['postsPerMonth'] as int?) ?? 0;

    return (limit: limit, currentCount: currentCount);
  }

  /// Determina cuántos meses debe durar visible una publicación
  /// según el tier del vendedor (no confundir con el límite mensual
  /// de publicaciones — esto controla expiresAt, no monthlyPostsCount).
  int _expirationMonthsForTier(String tier) {
    return switch (tier) {
      'Residente' => 3,
      'Inversionista' => 6,
      'Empresario' => 12,
      _ => 1, // 'Estudiante' u otro valor no reconocido
    };
  }

  // ───── Propiedades ─────────────────────────────────────────────

  /// Verificación de límite standalone — actualmente deshabilitada:
  /// el `return` temprano hace que el resto del método sea código
  /// muerto (por eso el `// ignore: dead_code`). No se usa desde
  /// `addProperty`, que tiene su propia verificación inline más abajo.
  Future<void> checkPostLimit(String userId) async {
    return;

    // ignore: dead_code
    final (:limit, :currentCount) = await _getPostLimitInfo(userId);
    if (limit != 999 && currentCount >= limit) {
      throw Exception(
        'Has alcanzado el límite de publicaciones mensuales para tu plan.',
      );
    }
  }

  /// Retorna una lista de todas las propiedades.
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

  /// Retorna la lista de propiedades vendidas.
  Stream<List<Property>> getSoldPropertiesList(String sellerId) {
    return _db
        .collection('propiedades')
        .where('sellerId', isEqualTo: sellerId)
        .where('isSold', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Property.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) {
            final dateA = a.soldAt ?? DateTime(2000);
            final dateB = b.soldAt ?? DateTime(2000);
            return dateB.compareTo(dateA);
          });
          return list;
        });
  }

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

      final userDoc = await _db.collection('usuarios').doc(user.uid).get();
      final userData = userDoc.data();
      final tier = (userData?['tier'] as String?) ?? 'Estudiante';
      final currentCount = (userData?['monthlyPostsCount'] as int?) ?? 0;

      // Verificación de límite de suscripción — ACTIVA.
      // Si el usuario ya alcanzó su cupo mensual de publicaciones
      // (según su tier), se bloquea la creación con una excepción.
      // limit == 999 se trata como "ilimitado" y nunca bloquea.
      final tierConfig = SubscriptionService.subscriptionTiers[tier];
      final limit = (tierConfig?['postsPerMonth'] as int?) ?? 0;
      if (limit != 999 && currentCount >= limit) {
        throw Exception(
          'Has alcanzado el límite de publicaciones mensuales para tu plan.',
        );
      }

      final durationMonths = _expirationMonthsForTier(tier);
      final now = DateTime.now();
      final expiresAt = DateTime(now.year, now.month + durationMonths, now.day);

      final propertyData = property.toMap();
      propertyData['expiresAt'] = expiresAt.toIso8601String();
      propertyData['sellerId'] = user.uid;

      final DocumentReference docRef = await _db
          .collection('propiedades')
          .add(propertyData);
      final propertyId = docRef.id;

      await _db.collection('usuarios').doc(user.uid).update({
        'monthlyPostsCount': FieldValue.increment(1),
      });

      try {
        final sellerId = property.sellerId;
        if (sellerId.isNotEmpty) {
          final followers = await followService.getFollowerIds(sellerId);
          final sellerName =
              (userData?['nombre'] as String?) ?? 'Un vendedor que sigues';

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
                senderPhoto: userData?['photoUrl'] as String?,
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

  /// Actualiza una propiedad existente.
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
        final propertyDoc = await _db.collection('propiedades').doc(id).get();
        if (propertyDoc.exists) {
          final propertyTitle =
              (propertyDoc.data()?['title'] as String?) ??
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