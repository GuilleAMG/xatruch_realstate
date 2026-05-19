import 'package:flutter_test/flutter_test.dart';
import 'package:xatruch_realstate/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('validateEmail rejects empty and malformed email', () {
      expect(Validators.validateEmail(''), 'Por favor, ingrese su correo electrónico');
      expect(
        Validators.validateEmail('correo-invalido'),
        'Por favor, ingrese un correo electrónico válido',
      );
      expect(Validators.validateEmail('user@example.com'), isNull);
    });

    test('validatePassword enforces minimum length', () {
      expect(Validators.validatePassword(''), 'Por favor, ingrese su contraseña');
      expect(
        Validators.validatePassword('12345'),
        'La contraseña debe tener al menos 6 caracteres',
      );
      expect(Validators.validatePassword('123456'), isNull);
    });

    test('validateName requires first and last name', () {
      expect(Validators.validateName(''), 'Por favor, ingrese su nombre');
      expect(
        Validators.validateName('Juan'),
        'Por favor, ingrese su nombre y apellido',
      );
      expect(Validators.validateName('Juan Perez'), isNull);
    });

    test('validateDNI enforces numeric 13-digit format', () {
      expect(Validators.validateDNI(''), 'Por favor, ingrese su número de DNI');
      expect(Validators.validateDNI('123'), 'El DNI debe tener 13 dígitos');
      expect(Validators.validateDNI('123456789012a'), 'El DNI solo debe contener números');
      expect(Validators.validateDNI('1234-5678-90123'), isNull);
    });

    test('validatePhone enforces minimum digits', () {
      expect(Validators.validatePhone(''), 'Por favor, ingrese su número de teléfono');
      expect(Validators.validatePhone('1234567'), 'El teléfono debe tener al menos 8 dígitos');
      expect(Validators.validatePhone('+504 9999-9999'), isNull);
    });

    test('validateConfirmPassword requires exact match', () {
      expect(
        Validators.validateConfirmPassword('', 'secret123'),
        'Por favor, confirme su contraseña',
      );
      expect(
        Validators.validateConfirmPassword('secret321', 'secret123'),
        'Las contraseñas no coinciden',
      );
      expect(Validators.validateConfirmPassword('secret123', 'secret123'), isNull);
    });
  });
}
