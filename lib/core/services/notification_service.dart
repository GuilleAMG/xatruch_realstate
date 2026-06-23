// Servicio de notificaciones push: inicialización de FCM, permisos,
// manejo de mensajes en primer plano/segundo plano y enrutamiento por notificación.
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';
import 'package:xatruch_realstate/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Se invoca cuando el usuario toca una notificación (segundo plano/terminada/reanudada).
  void Function(RemoteMessage message)? onNotificationTap;

  Future<void> initialize() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      debugPrint(
          'Push notifications are not configured for desktop platforms yet. Skipping initialization.');
      return;
    }

    // 1. Manejar mensajes en segundo plano
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Inicializar notificaciones locales
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );
    await _localNotifications.initialize(settings: initSettings);

    // 3. Crear canal de notificaciones Android (necesario para notificaciones emergentes en API 26+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Este canal se usa para notificaciones importantes.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Actualizar opciones de presentación de notificaciones en iOS para primer plano
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Escuchar mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final RemoteNotification? notification = message.notification;
      final AndroidNotification? android = message.notification?.android;

      // Verificar preferencia del usuario antes de mostrar notificación local
      final enabled = await isNotificationsEnabled();
      if (!enabled) {
        debugPrint(
            'Notifications disabled for user, skipping foreground notification');
        return;
      }

      if (notification != null && android != null && !kIsWeb) {
        await _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    // 6. Manejar app abierta desde notificación en segundo plano/terminada
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM onMessageOpenedApp: ${message.messageId}');
      if (onNotificationTap != null) {
        onNotificationTap!(message);
      }
    });

    // 7. Capturar mensaje inicial cuando la app se abre desde estado terminado
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('FCM getInitialMessage: ${initialMessage.messageId}');
      if (onNotificationTap != null) {
        onNotificationTap!(initialMessage);
      }
    }

    debugPrint('FCM & Local Notifications Initialized');
  }

  Future<bool> requestPermissions() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      return false;
    }
    try {
      // 1. Verificar/Solicitar permiso de plataforma (Android/iOS)
      final NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permission');

        // 2. Solicitar permiso explícito de POST_NOTIFICATIONS para Android 13+
        if (defaultTargetPlatform == TargetPlatform.android) {
          final status = await Permission.notification.request();
          return status.isGranted;
        }

        return true;
      } else {
        debugPrint('User declined or has not accepted notification permission');
        return false;
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  Future<bool> isPermissionGranted() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      return false;
    }
    final settings = await _fcm.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<String?> getToken() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      return null;
    }
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> deleteToken() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      return;
    }
    try {
      await _fcm.deleteToken();
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }

  /// Verifica si las notificaciones están habilitadas para el usuario actual.
  Future<bool> isNotificationsEnabled() async {
    final user = await userService.getUsuarioById(
        FirebaseAuth.instance.currentUser?.uid ?? '');
    return (user?['notificationsEnabled'] as bool?) ??
        true; // Por defecto true si no está configurado
  }

  /// Maneja el enrutamiento al tocar una notificación según los datos del mensaje.
  /// Retorna la info de ruta destino: {'index': int, 'itemId': String?, 'model': String?}
  static Map<String, dynamic> parseNotificationRoute(RemoteMessage message) {
    final data = message.data;
    final route = data['route']?.toString().toLowerCase();
    final itemId = data['itemId']?.toString();
    final model = data['model']?.toString();

    int targetIndex = 0; // Por defecto: inicio
    if (route == 'chats' || model == 'chat') {
      targetIndex = 1;
    } else if (route == 'account' || route == 'perfil' || model == 'account') {
      targetIndex = 2;
    } else if (route == 'home' ||
        route == 'properties' ||
        model == 'property') {
      targetIndex = 0;
    } else {
      debugPrint('Unknown notification route: $route, defaulting to home');
    }

    return {
      'index': targetIndex,
      'itemId': itemId,
      'model': model,
      'route': route,
    };
  }
}

// Manejador de mensajes en segundo plano a nivel superior.
// Se ejecuta en un isolate separado — Firebase debe inicializarse aquí también.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // ✅ Guard: el isolate de background no comparte estado con el isolate principal
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  debugPrint('Handling a background message: ${message.messageId}');

  try {
    if (message.notification != null) {
      final FlutterLocalNotificationsPlugin backgroundNotifications =
          FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings();

      await backgroundNotifications.initialize(
        settings: const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );

      final AndroidNotification? android = message.notification?.android;
      if (android != null) {
        final notification = message.notification!;
        await backgroundNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription: 'Este canal se usa para notificaciones importantes.',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(),
          ),
        );
      }
    }
  } catch (e) {
    debugPrint('Error handling background message: $e');
  }
}

final notificationService = NotificationService();