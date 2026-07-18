// Servicio de seguimiento.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FollowService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> toggleFollow(String targetUserId) async {
    final user = _auth.currentUser;
    if (user == null || user.uid == targetUserId) return;

    final followRef = _db
        .collection('usuarios')
        .doc(user.uid)
        .collection('siguiendo')
        .doc(targetUserId);

    final doc = await followRef.get();
    if (doc.exists) {
      await followRef.delete();
    } else {
      await followRef.set({'followedAt': DateTime.now().toIso8601String()});
    }
  }

  Stream<bool> isFollowing(String targetUserId) {
    return _auth.authStateChanges().asyncExpand((User? user) {
      if (user == null) return Stream.value(false);
      return _db
          .collection('usuarios')
          .doc(user.uid)
          .collection('siguiendo')
          .doc(targetUserId)
          .snapshots()
          .map((snapshot) => snapshot.exists);
    });
  }

  Future<List<String>> getFollowerIds(String userId) async {
    try {
      final query = await _db
          .collectionGroup('siguiendo')
          .where(FieldPath.documentId, isEqualTo: userId)
          .get();

      return query.docs.map((doc) => doc.reference.parent.parent!.id).toList();
    } catch (e) {
      debugPrint('Error al obtener IDs de seguidores: $e');
      return [];
    }
  }
}

final followService = FollowService();