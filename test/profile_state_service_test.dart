import 'package:flutter_test/flutter_test.dart';
import 'package:xatruch_realstate/core/services/profile_state_service.dart';

void main() {
  group('resolveProfileStateSnapshot', () {
    test('uses Firestore values when available', () {
      final snapshot = resolveProfileStateSnapshot(
        documentName: 'Ana López',
        documentEmail: 'ana@correo.com',
        documentPhotoUrl: 'https://example.com/photo.jpg',
        authDisplayName: 'Ana Auth',
        authEmail: 'ana.auth@correo.com',
      );

      expect(snapshot.displayName, 'Ana López');
      expect(snapshot.email, 'ana.auth@correo.com');
      expect(snapshot.photoUrl, 'https://example.com/photo.jpg');
    });

    test('falls back to auth display name when Firestore name is empty', () {
      final snapshot = resolveProfileStateSnapshot(
        documentName: '',
        documentEmail: '',
        documentPhotoUrl: '',
        authDisplayName: 'Carlos',
        authEmail: 'carlos@correo.com',
      );

      expect(snapshot.displayName, 'Carlos');
      expect(snapshot.email, 'carlos@correo.com');
      expect(snapshot.photoUrl, '');
    });
  });
}
