// Servicio de pagos: integra RevenueCat para compras in-app, sincronización
// de suscripciones y restauración de compras previas.
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:xatruch_realstate/core/services/subscription_service.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/session/session_user.dart';
import 'package:flutter/services.dart';

class PaymentService {
  static const String _appleApiKey = 'test_ATKjprKakewmiiiebmklWzOuIJH';
  static const String _googleApiKey = 'test_ATKjprKakewmiiiebmklWzOuIJH';
  bool _isConfigured = false;

  Future<void> init() async {
    if (kIsWeb) {
      return; // Las compras In-App nativas solo funcionan en iOS/Android
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return; // Skip on desktop as RevenueCat isn't officially supported natively here
    }

    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration? configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_googleApiKey);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_appleApiKey);
    }

    if (configuration != null) {
      await Purchases.configure(configuration);
      _isConfigured = true;
      _listenToCustomerInfoChanges();

      // Intentar loguear el usuario si ya tenemos sesión de Firebase
      final user = authService.currentUser;
      if (user != null) {
        await bindToAuthUser(user);
      }
    }
  }

  Future<void> bindToAuthUser(User user) async {
    await bindToSessionUser(
      SessionUser(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        phoneNumber: user.phoneNumber,
      ),
    );
  }

  Future<void> bindToSessionUser(SessionUser user) async {
    if (kIsWeb || !_isConfigured) return;
    await Purchases.logIn(user.uid);

    if (user.email != null && user.email!.isNotEmpty) {
      await Purchases.setEmail(user.email!);
    }
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      await Purchases.setDisplayName(user.displayName!);
    }
    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
      await Purchases.setPhoneNumber(user.phoneNumber!);
    }
  }

  Future<void> clearCommerceSession() async {
    if (kIsWeb || !_isConfigured) return;
    try {
      if (await Purchases.isAnonymous) {
        debugPrint(
          'PaymentService: User is already anonymous, skipping logOut.',
        );
        return;
      }
      await Purchases.logOut();
    } catch (e) {
      debugPrint('PaymentService: Error during RevenueCat logOut: $e');
    }
  }

  void _listenToCustomerInfoChanges() {
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      await syncUserTier(customerInfo);
    });
  }

  Future<void> syncCustomerInfo() async {
    if (kIsWeb || !_isConfigured) return;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      await syncUserTier(customerInfo);
    } catch (e) {
      debugPrint('Error sincronizando información con RevenueCat: $e');
    }
  }

  Future<void> syncUserTier(CustomerInfo customerInfo) async {
    final user = authService.currentUser;
    if (user == null) return;

    final activeEntitlements = customerInfo.entitlements.active;

    // Si no hay suscripciones activas en RevenueCat, no sobrescribir el tier local.
    // Esto permite probar con los tiers manuales sin que RevenueCat los resetee.
    if (activeEntitlements.isEmpty) {
      return;
    }

    // Tier interno calculado según los entitlements activos de RevenueCat
    String newTier = 'Estudiante';

    if (activeEntitlements.containsKey('company')) {
      newTier = 'Empresario';
    } else if (activeEntitlements.containsKey('investor')) {
      newTier = 'Inversionista';
    } else if (activeEntitlements.containsKey('resident')) {
      newTier = 'Residente';
    } else if (activeEntitlements.containsKey('student')) {
      newTier = 'Estudiante';
    }

    final data = await subscriptionService.getSubscriptionInfo(user.uid);
    final currentTier = data['tier'];

    // En produccion se puede manejar downgrade si expiro, aquí solo actualizamos si hay diferencia.
    if (currentTier != newTier) {
      await subscriptionService.updateUserTier(user.uid, newTier);
    }
  }

  Future<Offerings?> getOfferings() async {
    if (kIsWeb || !_isConfigured) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('Error obteniendo planes de RevenueCat: $e');
      return null;
    }
  }

  Future<bool> purchasePackage(Package package) async {
    if (kIsWeb || !_isConfigured) return false;
    try {
      final purchaseParams = PurchaseParams.package(package);
      await Purchases.purchase(purchaseParams);
      await syncCustomerInfo();
      return true;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('Error al comprar paquete: $e');
      }
      return false;
    } catch (e) {
      debugPrint('Error inesperado al comprar: $e');
      return false;
    }
  }

  /// Restaurar manualmente compras anteriores (ej. si el usuario cambió de teléfono).
  /// Solo debe activarse por interacción directa del usuario, como un toque en un botón.
  Future<bool> restorePurchases() async {
    if (kIsWeb || !_isConfigured) return false;
    try {
      final customerInfo = await Purchases.restorePurchases();
      await syncUserTier(customerInfo);
      return true;
    } on PlatformException catch (e) {
      debugPrint('Error al restaurar compras: $e');
      return false;
    }
  }
}

final paymentService = PaymentService();
