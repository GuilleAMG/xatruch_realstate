import 'package:flutter_test/flutter_test.dart';
import 'package:xatruch_realstate/core/session/session_coordinator.dart';
import 'package:xatruch_realstate/core/session/session_user.dart';

void main() {
  group('SessionCoordinator', () {
    test('binds token and commerce state when a user session is restored', () async {
      final events = <String>[];

      final coordinator = SessionCoordinator(
        getPushToken: () async => 'token-123',
        savePushToken: (token) async => events.add('save:$token'),
        bindCommerceUser: (user) async => events.add('bind:${user.uid}'),
        syncCommerceInfo: () async => events.add('sync'),
        clearCommerceSession: () async => events.add('clear'),
      );

      await coordinator.handleAuthStateChanged(
        const SessionUser(uid: 'user-1', email: 'test@example.com'),
      );

      expect(events, ['save:token-123', 'bind:user-1', 'sync']);
    });

    test('skips token save when token is unavailable', () async {
      final events = <String>[];

      final coordinator = SessionCoordinator(
        getPushToken: () async => null,
        savePushToken: (token) async => events.add('save:$token'),
        bindCommerceUser: (user) async => events.add('bind:${user.uid}'),
        syncCommerceInfo: () async => events.add('sync'),
        clearCommerceSession: () async => events.add('clear'),
      );

      await coordinator.handleAuthStateChanged(
        const SessionUser(uid: 'user-2'),
      );

      expect(events, ['bind:user-2', 'sync']);
    });

    test('clears commerce state on sign out', () async {
      final events = <String>[];

      final coordinator = SessionCoordinator(
        getPushToken: () async => 'ignored',
        savePushToken: (token) async => events.add('save:$token'),
        bindCommerceUser: (user) async => events.add('bind:${user.uid}'),
        syncCommerceInfo: () async => events.add('sync'),
        clearCommerceSession: () async => events.add('clear'),
      );

      await coordinator.handleAuthStateChanged(null);

      expect(events, ['clear']);
    });
  });
}