// Validadores de formularios.
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese su correo electrónico';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, ingrese un correo electrónico válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese su contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, ingrese su nombre';
    }
    if (value.trim().split(' ').length < 2) {
      return 'Por favor, ingrese su nombre y apellido';
    }
    return null;
  }

  /// Valida un DNI (formato de identidad hondureña, usualmente 13 dígitos).
  static String? validateDNI(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese su número de DNI';
    }
    final cleanDNI = value.replaceAll(RegExp(r'[-\s]'), '');
    if (cleanDNI.length != 13) {
      return 'El DNI debe tener 13 dígitos';
    }
    if (!RegExp(r'^\d+$').hasMatch(cleanDNI)) {
      return 'El DNI solo debe contener números';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese su número de teléfono';
    }
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length < 8) {
      return 'El teléfono debe tener al menos 8 dígitos';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme su contraseña';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Valida que un campo no esté vacío.
  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio';
    return null;
  }

  static String? validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio';
    if (double.tryParse(value.trim()) == null) return 'Ingrese un número válido';
    return null;
  }

  static String? validateInt(String? value) {
    if (value == null || value.trim().isEmpty) return 'Este campo es obligatorio';
    if (int.tryParse(value.trim()) == null) return 'Ingrese un número entero';
    return null;
  }
}
