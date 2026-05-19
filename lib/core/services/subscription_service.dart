// Servicio de suscripciones: gestiona los niveles de suscripción,
// límites de publicaciones mensuales y actualización de planes.
import 'package:cloud_firestore/cloud_firestore.dart';

/// Gestiona los niveles de suscripción, límites de publicaciones y cambios de plan.
class SubscriptionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const Map<String, Map<String, dynamic>> subscriptionTiers = {
    'Estudiante': {
      'postsPerMonth': 0,
      'durationMonths': 1,
      'price': 0,
      'description': 'Permite ver las publicaciones de los demas y contactar a los vendedores.',
    },
    'Residente': {
      'postsPerMonth': 5,
      'durationMonths': 1,
      'price': 106,
      'description': 'Ideal para quienes buscan realizar alguna venta esporadica.',
    },
    'Inversionista': {
      'postsPerMonth': 15,
      'durationMonths': 1,
      'price': 319,
      'description': 'Portafolio inicial para aquellos que buscan dedicarse a los bienes raices.',
    },
    'Empresario': {
      'postsPerMonth': 50,
      'durationMonths': 1,
      'price': 665,
      'description': 'Pensado para agencias o empresas inmobiliarias que buscan expandirse y modernizarse.',
    },
  };

  /// Recupera la información de suscripción para el UID dado.
  /// Reinicia automáticamente el conteo de publicaciones mensuales cuando comienza un nuevo mes.
  Future<Map<String, dynamic>> getSubscriptionInfo(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();
    final data = doc.data() ?? {};

    final currentTier = (data['tier'] as String?) ?? 'Estudiante';
    final monthlyPosts = (data['monthlyPostsCount'] as int?) ?? 0;
    final lastPostReset = data['lastPostReset'] != null
        ? DateTime.parse(data['lastPostReset'] as String)
        : DateTime.now();

    // Reiniciar conteo si es un nuevo mes
    if (DateTime.now().month != lastPostReset.month ||
        DateTime.now().year != lastPostReset.year) {
      await _db.collection('usuarios').doc(uid).update({
        'monthlyPostsCount': 0,
        'lastPostReset': DateTime.now().toIso8601String(),
      });
      return {
        'tier': currentTier,
        'monthlyPostsCount': 0,
        'config': subscriptionTiers[currentTier],
      };
    }

    return {
      'tier': currentTier,
      'monthlyPostsCount': monthlyPosts,
      'config': subscriptionTiers[currentTier],
    };
  }

  /// Actualiza el nivel de suscripción del usuario.
  Future<void> updateUserTier(String uid, String tier) async {
    if (!subscriptionTiers.containsKey(tier)) return;
    await _db.collection('usuarios').doc(uid).update({
      'tier': tier,
      'subscriptionStartDate': DateTime.now().toIso8601String(),
    });
  }
}

final subscriptionService = SubscriptionService();
