import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User({
    required this.uid,
    required this.email,
    this.nombre = '',
    this.phoneNumber = '',
    this.photoUrl = '',
    this.tier = 'Estudiante',
    this.isPremium = false,
    this.premiumSince,
    this.status = 'active',
    this.isUserMode = true,
    this.notificationsEnabled = true,
    this.locationEnabled = false,
    this.isAdmin = false,
    this.fcmToken = '',
    this.scheduledForDeletion = false,
    this.deletionScheduledAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromMap(Map<String, dynamic> map, String uid) {
    return User(
      uid: uid,
      email: (map['email'] as String?) ?? '',
      nombre: (map['nombre'] as String?) ?? '',
      phoneNumber: (map['phoneNumber'] as String?) ?? '',
      photoUrl: (map['photoUrl'] as String?) ?? '',
      tier: (map['tier'] as String?) ?? 'Estudiante',
      isPremium: (map['isPremium'] as bool?) ?? false,
      premiumSince: map['premiumSince'] != null
          ? (map['premiumSince'] as Timestamp).toDate()
          : null,
      status: (map['status'] as String?) ?? 'active',
      isUserMode: (map['isUserMode'] as bool?) ?? true,
      notificationsEnabled: (map['notificationsEnabled'] as bool?) ?? true,
      locationEnabled: (map['locationEnabled'] as bool?) ?? false,
      isAdmin: (map['isAdmin'] as bool?) ?? false,
      fcmToken: (map['fcmToken'] as String?) ?? '',
      scheduledForDeletion: (map['scheduledForDeletion'] as bool?) ?? false,
      deletionScheduledAt: map['deletionScheduledAt'] != null
          ? (map['deletionScheduledAt'] as Timestamp).toDate()
          : null,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  final String uid;
  final String email;
  final String nombre;
  final String phoneNumber;
  final String photoUrl;
  final String tier;
  final bool isPremium;
  final DateTime? premiumSince;
  final String status;
  final bool isUserMode;
  final bool notificationsEnabled;
  final bool locationEnabled;
  final bool isAdmin;
  final String fcmToken;
  final bool scheduledForDeletion;
  final DateTime? deletionScheduledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nombre': nombre,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'tier': tier,
      'isPremium': isPremium,
      'premiumSince': premiumSince != null
          ? Timestamp.fromDate(premiumSince!)
          : null,
      'status': status,
      'isUserMode': isUserMode,
      'notificationsEnabled': notificationsEnabled,
      'locationEnabled': locationEnabled,
      'isAdmin': isAdmin,
      'fcmToken': fcmToken,
      'scheduledForDeletion': scheduledForDeletion,
      'deletionScheduledAt': deletionScheduledAt != null
          ? Timestamp.fromDate(deletionScheduledAt!)
          : null,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  User copyWith({
    String? uid,
    String? email,
    String? nombre,
    String? phoneNumber,
    String? photoUrl,
    String? tier,
    bool? isPremium,
    DateTime? premiumSince,
    String? status,
    bool? isUserMode,
    bool? notificationsEnabled,
    bool? locationEnabled,
    bool? isAdmin,
    String? fcmToken,
    bool? scheduledForDeletion,
    DateTime? deletionScheduledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      tier: tier ?? this.tier,
      isPremium: isPremium ?? this.isPremium,
      premiumSince: premiumSince ?? this.premiumSince,
      status: status ?? this.status,
      isUserMode: isUserMode ?? this.isUserMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      isAdmin: isAdmin ?? this.isAdmin,
      fcmToken: fcmToken ?? this.fcmToken,
      scheduledForDeletion: scheduledForDeletion ?? this.scheduledForDeletion,
      deletionScheduledAt: deletionScheduledAt ?? this.deletionScheduledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
