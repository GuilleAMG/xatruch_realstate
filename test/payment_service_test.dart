import 'package:flutter_test/flutter_test.dart';
import 'package:xatruch_realstate/core/services/payment_service.dart';

void main() {
  group('PaymentService', () {
    test('initialize completes without throwing on unsupported platforms', () async {
      final service = PaymentService();

      await expectLater(service.initialize(), completes);
    });
  });
}
