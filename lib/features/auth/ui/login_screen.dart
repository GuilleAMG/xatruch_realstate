// Pantalla de inicio de sesion: interfaz para que el usuario ingrese
// sus credenciales y acceda a la aplicacion.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/features/auth/ui/recovery_screen.dart';
import 'package:xatruch_realstate/features/auth/ui/register_screen.dart';
import 'package:xatruch_realstate/core/utils/validators.dart';
import 'package:xatruch_realstate/features/auth/controllers/login_controller.dart';
import 'package:xatruch_realstate/features/auth/ui/widgets/auth_header.dart';
import 'package:xatruch_realstate/features/auth/ui/widgets/auth_text_field.dart';
import 'package:xatruch_realstate/features/auth/ui/widgets/auth_button.dart';
import 'package:xatruch_realstate/features/auth/ui/widgets/auth_footer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginController = LoginController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _loginController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text;

      final bool success = await _loginController.login(email, password);

      if (!success && mounted) {
        if (_loginController.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_loginController.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: ListenableBuilder(
        listenable: _loginController,
        builder: (context, _) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeader(
                      imagePath: 'assets/icons/login_icon.png',
                      title: 'XATRUCH\nBIENES RAÍCES',
                      subtitle: 'Inicia sesión en tu cuenta.',
                    ),
                    const SizedBox(height: 48),

                    AuthTextField(
                      controller: _emailController,
                      labelText: 'Correo electrónico',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    AuthTextField(
                      controller: _passwordController,
                      labelText: 'Contraseña',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 24),

                    AuthButton(
                      text: 'Iniciar sesión',
                      isLoading: _loginController.isLoading,
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () async {
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const RecoveryScreen(),
                          ),
                        );
                      },
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),

                    AuthFooter(
                      message: '¿No tienes una cuenta? ',
                      actionText: 'Registrarse',
                      onTap: () async {
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
