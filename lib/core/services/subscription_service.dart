// subscription_service.dart
// Syncs RevenueCat subscription state into the Firestore usuarios document.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('usuarios').doc(uid);

  // ─────────────────────────────────────────────
  // READ
  // ─────────────────────────────────────────────

  Future<Map<String, dynamic>> getSubscriptionInfo(String uid) async {
    final snapshot = await _userDoc(uid).get();
    final data = snapshot.data();
    if (data == null) return {'tier': 'free', 'isPremium': false};

    return {
      'tier': data['tier'] ?? 'free',
      'isPremium': data['isPremium'] ?? false,
      'premiumSince': data['premiumSince'],
    };
  }

  // ─────────────────────────────────────────────
  // WRITE
  // ─────────────────────────────────────────────

  Future<void> updateUserTier(String uid, String newTier) async {
    // Guard 1: verify the caller is authenticated
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('[SubscriptionService] Usuario no autenticado al actualizar tier');
    }

    // Guard 2: verify the caller owns this document
    if (currentUser.uid != uid) {
      throw Exception(
        '[SubscriptionService] UID mismatch: '
        'currentUser=${currentUser.uid}, requested=$uid',
      );
    }

    final snapshot = await _userDoc(uid).get();
    if (!snapshot.exists) {
      throw Exception('[SubscriptionService] Usuario no encontrado: $uid');
    }

    final isPremium = newTier != 'free';

    final updates = <String, dynamic>{
      'tier': newTier,
      'isPremium': isPremium,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (isPremium) {
      final current = await getSubscriptionInfo(uid);
      final alreadyPremium = current['isPremium'] == true;
      if (!alreadyPremium) {
        updates['premiumSince'] = FieldValue.serverTimestamp();
      }
    } else {
      updates['premiumSince'] = null;
    }

    // Use update() instead of set(..., merge: true) since we verified
    // the document exists above. This ensures Firestore evaluates the
    // operation as an UPDATE (not a CREATE), satisfying security rules.
    await _userDoc(uid).update(updates);
  }

  // ─────────────────────────────────────────────
  // ENTITLEMENT KEY → TIER STRING
  // ─────────────────────────────────────────────

  static String resolveTierFromEntitlements(
    Map<String, dynamic> activeEntitlements,
  ) {
    if (activeEntitlements.containsKey('yearly')) return 'yearly';
    if (activeEntitlements.containsKey('six_month')) return 'six_month';
    if (activeEntitlements.containsKey('three_month')) return 'three_month';
    if (activeEntitlements.containsKey('monthly')) return 'monthly';
    return 'free';
  }

  // ─────────────────────────────────────────────
  // TIER DISPLAY CONFIG (used by subscription_screen.dart
  // and property_service.dart)
  // ─────────────────────────────────────────────

  /// Keyed by display name to match _tierStyle() in SubscriptionTierCard.
  /// postsPerMonth: 999 = unlimited (Empresario).
  static const Map<String, Map<String, dynamic>> subscriptionTiers = {
    'Estudiante': {
      'price': 0,
      'postsPerMonth': 0,
      'description': 'Acceso básico para explorar propiedades.',
    },
    'Residente': {
      'price': 110,
      'postsPerMonth': 10,
      'description': 'Ideal para agentes que están comenzando.',
    },
    'Inversionista': {
      'price': 320,
      'postsPerMonth': 25,
      'description': 'Para agentes activos con mayor volumen.',
    },
    'Empresario': {
      'price': 670,
      'postsPerMonth': 50,
      'description': 'Para agencias con alta demanda de publicaciones.',
    },
  };
}

final subscriptionService = SubscriptionService();