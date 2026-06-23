// Punto de entrada de la aplicación: configura Firebase, RevenueCat,
// y el sistema de navegación global.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/notification_service.dart';
import 'package:xatruch_realstate/core/services/payment_service.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';
import 'package:xatruch_realstate/core/session/session_coordinator.dart';
import 'package:xatruch_realstate/core/session/session_user.dart';
import 'package:xatruch_realstate/core/ui/main_wrapper.dart';
import 'package:xatruch_realstate/core/theme/app_theme.dart';
import 'package:xatruch_realstate/features/auth/ui/login_screen.dart';
import 'package:xatruch_realstate/features/auth/ui/widgets/auth_gate.dart';
import 'package:xatruch_realstate/firebase_options.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

final sessionCoordinator = SessionCoordinator(
  getPushToken: () => notificationService.getToken(),
  savePushToken: (token) => userService.saveFcmToken(token),
  bindCommerceUser: (user) => paymentService.bindToSessionUser(user),
  syncCommerceInfo: () => paymentService.syncCustomerInfo(),
  clearCommerceSession: () => paymentService.clearCommerceSession(),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Guard para evitar FirebaseException [core/duplicate-app]
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode
        ? AndroidDebugProvider()
        : AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode
        ? AppleDebugProvider()
        : AppleDeviceCheckProvider(),
    providerWeb: ReCaptchaV3Provider('YOUR_RECAPTCHA_SITE_KEY'),
  );

  // Configurar Crashlytics para captura global de errores solo en plataformas soportadas
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await notificationService.initialize();
  await paymentService.init();

  // Escuchar cambios de autenticación para orquestar servicios (push tokens, RevenueCat)
  authService.authStateChanges.listen((user) {
    if (user != null) {
      sessionCoordinator.handleAuthStateChanged(
        SessionUser(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          phoneNumber: user.phoneNumber,
        ),
      );
    } else {
      sessionCoordinator.handleAuthStateChanged(null);
    }
  });

  // Configurar el callback de navegación al tocar una notificación
  notificationService.onNotificationTap = (RemoteMessage message) async {
    final enabled = await notificationService.isNotificationsEnabled();
    if (!enabled) return; 

    final routeInfo = NotificationService.parseNotificationRoute(message);
    final targetIndex = routeInfo['index'] as int;
    final itemId = routeInfo['itemId'] as String?;
    final model = routeInfo['model'] as String?;

    if (appNavigatorKey.currentState != null) {
      await appNavigatorKey.currentState!.pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(
          builder: (_) => MainWrapper(initialIndex: targetIndex),
        ),
        (route) => false,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = appNavigatorKey.currentContext;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                itemId != null
                    ? 'Notificación abierta: ${model ?? 'elemento'} $itemId'
                    : 'Notificación abierta: ${routeInfo['route'] ?? 'inicio'}',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    }
  };

  runApp(const MainApp());

  // Verificar conexión con Firestore en segundo plano.
  unawaited(() async {
    final bool isConnected = await userService.checkConnection();
    if (isConnected) {
      debugPrint('Successfully connected to Firestore');
    } else {
      debugPrint('Failed to connect to Firestore');
    }
  }());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xatruch Realstate',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: AuthGate(
        signedInBuilder: (_) => const MainWrapper(),
        signedOutBuilder: (_) => const LoginScreen(),
      ),
    );
  }
}