// Central RevenueCat SDK wrapper.
// Handles: initialization, offerings, purchases, restore, entitlement checking.
// Works alongside subscription_service.dart (Firestore sync)

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import 'auth_service.dart';
import 'package:xatruch_realstate/core/services/subscription_service.dart';
import 'package:xatruch_realstate/core/session/session_user.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

class _RC {
  static const String apiKeyAndroid = 'test_YAzKFOjtPqPWvPJStLuEgFawovL';
  static const String apiKeyIos = 'test_YAzKFOjtPqPWvPJStLuEgFawovL';
  static const String entitlementPremium = 'Xatruch Realstate Premium';
}

// ─── Service ─────────────────────────────────────────────────────────────────

class PaymentService {
  bool _initialized = false;

  bool get _isRevenueCatSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  // ── Initialization ────────────────────────────────────────────────────────

  /// Public alias used by main.dart.
  Future<void> init() => initialize();

  Future<void> initialize() async {
    if (_initialized) return;

    if (!_isRevenueCatSupported) {
      _initialized = true;
      debugPrint(
        '[PaymentService] Skipping RevenueCat initialization on unsupported platform',
      );
      return;
    }

    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);

      final configuration = PurchasesConfiguration(
        Platform.isIOS ? _RC.apiKeyIos : _RC.apiKeyAndroid,
      );

      await Purchases.configure(configuration);

      // Identify with Firebase UID if already logged in.
      final uid = authService.currentUser?.uid;
      if (uid != null) {
        await _identifyUser(uid);
      }

      // Listen for subscription changes and sync them to Firestore.
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      _initialized = true;
      debugPrint('[PaymentService] Initialized');
    } catch (e) {
      _initialized = true;
      debugPrint('[PaymentService] Initialization skipped due to error: $e');
    }
  }

  // ── Session Coordinator Interface ─────────────────────────────────────────
  // These three methods are called exclusively by SessionCoordinator
  // in main.dart. Do NOT also call loginUser() from auth_service —
  // the coordinator already handles the full lifecycle.

  /// Called by SessionCoordinator on login.
  /// Logs the user into RevenueCat using their Firebase UID.
  Future<void> bindToSessionUser(SessionUser user) async {
    if (!_isRevenueCatSupported) return;
    await _identifyUser(user.uid);
  }

  /// Forces a fresh CustomerInfo fetch and syncs it to Firestore.
  /// Called immediately after login to ensure Firestore reflects
  /// the current subscription state without waiting for a webhook.
  Future<void> syncCustomerInfo() async {
    if (!_isRevenueCatSupported) return;

    try {
      final info = await Purchases.getCustomerInfo();
      await _onCustomerInfoUpdated(info);
    } catch (e) {
      debugPrint('[PaymentService] syncCustomerInfo error: $e');
    }
  }

  /// Called by SessionCoordinator on logout.
  /// Logs the user out of RevenueCat.
  Future<void> clearCommerceSession() async {
    await logoutUser();
  }

  // ── User Identity ─────────────────────────────────────────────────────────

  Future<void> loginUser(String uid) async {
    await _identifyUser(uid);
  }

  Future<void> logoutUser() async {
    if (!_isRevenueCatSupported) return;

    try {
      await Purchases.logOut();
      debugPrint('[PaymentService] User logged out of RevenueCat');
    } catch (e) {
      debugPrint('[PaymentService] logoutUser error: $e');
    }
  }

  Future<void> _identifyUser(String uid) async {
    if (!_isRevenueCatSupported) return;

    try {
      final result = await Purchases.logIn(uid);
      debugPrint(
        '[PaymentService] Identified user: ${result.customerInfo.originalAppUserId}',
      );
    } catch (e) {
      debugPrint('[PaymentService] _identifyUser error: $e');
    }
  }

  // ── Entitlement Checking ──────────────────────────────────────────────────

  Future<bool> hasPremium() async {
    if (!_isRevenueCatSupported) return false;

    try {
      final info = await Purchases.getCustomerInfo();
      return _isPremium(info);
    } catch (e) {
      debugPrint('[PaymentService] hasPremium error: $e');
      return false;
    }
  }

  Stream<bool> get premiumStream async* {
    yield await hasPremium();
    await for (final info in _customerInfoController.stream) {
      yield _isPremium(info);
    }
  }

  bool _isPremium(CustomerInfo info) {
    return info.entitlements.active.containsKey(_RC.entitlementPremium);
  }

  // ── Offerings ─────────────────────────────────────────────────────────────

  Future<Offerings?> getOfferings() async {
    if (!_isRevenueCatSupported) return null;

    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('[PaymentService] getOfferings error: $e');
      return null;
    }
  }

  Future<List<Package>> getAvailablePackages() async {
    if (!_isRevenueCatSupported) return [];

    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } catch (e) {
      debugPrint('[PaymentService] getAvailablePackages error: $e');
      return [];
    }
  }

  // ── Purchases ─────────────────────────────────────────────────────────────

  /// Purchase a specific package.
  /// Returns true on success, false on cancellation or error.
  Future<bool> purchasePackage(Package package) async {
    if (!_isRevenueCatSupported) return false;

    try {
      // ignore: deprecated_member_use
      final result = await Purchases.purchasePackage(package);
      return _isPremium(result.customerInfo);
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('[PaymentService] Purchase cancelled by user');
        return false;
      }
      debugPrint('[PaymentService] purchasePackage error: $e');
      return false;
    } catch (e) {
      debugPrint('[PaymentService] purchasePackage unexpected error: $e');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    if (!_isRevenueCatSupported) return false;

    try {
      final info = await Purchases.restorePurchases();
      return _isPremium(info);
    } catch (e) {
      debugPrint('[PaymentService] restorePurchases error: $e');
      return false;
    }
  }

  // ── Paywall Presentation ──────────────────────────────────────────────────

  Future<bool> presentPaywallIfNeeded() async {
    if (!_isRevenueCatSupported) return false;

    try {
      final result = await RevenueCatUI.presentPaywallIfNeeded(
        _RC.entitlementPremium,
      );
      return result == PaywallResult.purchased ||
          result == PaywallResult.restored;
    } catch (e) {
      debugPrint('[PaymentService] presentPaywallIfNeeded error: $e');
      return false;
    }
  }

  Future<PaywallResult> presentPaywall() async {
    if (!_isRevenueCatSupported) return PaywallResult.error;

    try {
      return await RevenueCatUI.presentPaywall();
    } catch (e) {
      debugPrint('[PaymentService] presentPaywall error: $e');
      return PaywallResult.error;
    }
  }

  // ── Customer Center ───────────────────────────────────────────────────────

  Future<void> presentCustomerCenter() async {
    if (!_isRevenueCatSupported) return;

    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      debugPrint('[PaymentService] presentCustomerCenter error: $e');
    }
  }

  // ── Customer Info ─────────────────────────────────────────────────────────

  Future<CustomerInfo?> getCustomerInfo() async {
    if (!_isRevenueCatSupported) return null;

    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('[PaymentService] getCustomerInfo error: $e');
      return null;
    }
  }

  // ── Internal: Firestore Sync ──────────────────────────────────────────────

  final _customerInfoController = StreamController<CustomerInfo>.broadcast();

  Future<void> _onCustomerInfoUpdated(CustomerInfo info) async {
    _customerInfoController.add(info);

    final uid = authService.currentUser?.uid;
    if (uid == null) return;

    // Extract just the entitlement keys — EntitlementInfo has no toJson().
    final activeEntitlements = Map<String, dynamic>.fromEntries(
      info.entitlements.active.keys.map((key) => MapEntry(key, true)),
    );

    final newTier = SubscriptionService.resolveTierFromEntitlements(
      activeEntitlements,
    );

    try {
      await subscriptionService.updateUserTier(uid, newTier);
      debugPrint('[PaymentService] Synced tier → $newTier');
    } catch (e) {
      debugPrint('[PaymentService] Firestore sync error: $e');
    }
  }

  void dispose() {
    _customerInfoController.close();
  }
}

final paymentService = PaymentService();
