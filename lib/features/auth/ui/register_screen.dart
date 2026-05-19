// Pantalla de registro: formulario para crear una nueva cuenta
// con nombre, correo, DNI, telefono y contrasena.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/features/auth/ui/login_screen.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';
import 'package:xatruch_realstate/core/utils/validators.dart';
import 'package:xatruch_realstate/features/auth/ui/widgets/auth_header.dart';
import 'package:xatruch_realstate/features/auth/ui/widgets/auth_text_field.dart';
import 'package:xatruch_realstate/features/auth/ui/widgets/auth_button.dart';
import 'package:xatruch_realstate/features/auth/ui/widgets/auth_footer.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dniController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dniController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final String email = _emailController.text.trim();
      final String password = _passwordController.text;

      try {
        final userCredential = await authService.registerUser(email, password);
        final String uid = userCredential.user!.uid;

        final Map<String, dynamic> userData = {
          'nombre': _nameController.text.trim(),
          'email': email,
          'dni': _dniController.text.trim(),
          'telefono': _phoneController.text.trim(),
          'uid': uid,
          'fecha_registro': DateTime.now(),
        };

        await userService.addUserProfile(uid, userData);

        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Cuenta creada exitosamente!'),
              backgroundColor: Colors.green,
            ),
          );
          await Navigator.pushReplacement<void, void>(
            context,
            MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          String errorMessage;
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'Este correo ya está registrado. Inicie sesión.';
              break;
            case 'invalid-email':
              errorMessage = 'El formato del correo electrónico no es válido.';
              break;
            case 'weak-password':
              errorMessage = 'La contraseña es muy débil. Use al menos 6 caracteres.';
              break;
            case 'operation-not-allowed':
              errorMessage = 'El registro con correo y contraseña no está habilitado.';
              break;
            default:
              errorMessage = 'Error al registrarse: ${e.message}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error inesperado: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } else {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: _autovalidateMode,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(
                  icon: Icons.person_add_rounded,
                  title: 'Crear Cuenta',
                  subtitle: 'Únete a nuestra comunidad',
                ),
                const SizedBox(height: 48),

                AuthTextField(
                  controller: _nameController,
                  labelText: 'Nombre Completo',
                  prefixIcon: Icons.person_outline,
                  textCapitalization: TextCapitalization.words,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _emailController,
                  labelText: 'Correo Electrónico',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _dniController,
                  labelText: 'DNI',
                  prefixIcon: Icons.card_membership_outlined,
                  keyboardType: TextInputType.number,
                  validator: Validators.validateDNI,
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _phoneController,
                  labelText: 'Teléfono',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _passwordController,
                  labelText: 'Contraseña',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirmar Contraseña',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text),
                ),
                const SizedBox(height: 24),

                AuthButton(
                  text: 'Registrarse',
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 16),

                AuthFooter(
                  message: "¿Ya tienes una cuenta? ",
                  actionText: 'Inicia Sesión',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
