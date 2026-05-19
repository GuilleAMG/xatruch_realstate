import 'package:flutter_test/flutter_test.dart';
import 'package:xatruch_realstate/features/profile/controllers/settings_controller.dart';

void main() {
  group('SettingsController', () {
    test('loads persisted preferences and applies permission gating', () async {
      final toggledTheme = <bool>[];

      final controller = SettingsController(
        getCurrentUserId: () => 'user-1',
        getUserData: (_) async => {
          'notificationsEnabled': true,
          'isDarkMode': true,
          'locationEnabled': false,
        },
        isPermissionGranted: () async => false,
        toggleTheme: (value) async => toggledTheme.add(value),
      );

      await controller.load();

      expect(controller.notificationsEnabled, isFalse);
      expect(controller.darkModeEnabled, isTrue);
      expect(controller.locationEnabled, isFalse);
      expect(toggledTheme, [true]);
    });

    test('enabling notifications requires granted permission', () async {
      final updated = <bool>[];

      final controller = SettingsController(
        getCurrentUserId: () => 'user-1',
        requestNotificationPermission: () async => false,
        updateNotificationPreference: (value) async => updated.add(value),
      );

      final result = await controller.handleNotificationToggle(true);

      expect(result, isFalse);
      expect(controller.notificationsEnabled, isFalse);
      expect(updated, isEmpty);
    });

    test('notification, theme, and location toggles persist state', () async {
      final notificationUpdates = <bool>[];
      final themeUpdates = <bool>[];
      final locationUpdates = <bool>[];

      final controller = SettingsController(
        getCurrentUserId: () => 'user-1',
        requestNotificationPermission: () async => true,
        updateNotificationPreference: (value) async => notificationUpdates.add(value),
        toggleTheme: (value) async => themeUpdates.add(value),
        updateLocationPreference: (value) async => locationUpdates.add(value),
      );

      final notificationResult = await controller.handleNotificationToggle(true);
      await controller.handleDarkModeToggle(true);
      await controller.handleLocationToggle(false);

      expect(notificationResult, isTrue);
      expect(controller.notificationsEnabled, isTrue);
      expect(controller.darkModeEnabled, isTrue);
      expect(controller.locationEnabled, isFalse);
      expect(notificationUpdates, [true]);
      expect(themeUpdates, [true]);
      expect(locationUpdates, [false]);
    });
  });
}