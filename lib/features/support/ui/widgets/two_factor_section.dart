// Seccion de autenticacion de dos factores: gestiona el flujo de
// habilitar/deshabilitar 2FA via SMS.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';

/// Gestiona el flujo de autenticación de dos factores (habilitar/deshabilitar vía SMS).
/// Extraído de PrivacyScreen para seguir el principio de responsabilidad única.
class TwoFactorSection extends StatefulWidget {
  const TwoFactorSection({super.key});

  @override
  State<TwoFactorSection> createState() => _TwoFactorSectionState();
}

class _TwoFactorSectionState extends State<TwoFactorSection> {
  bool _is2FAEnabled = false;
  bool _isLoading2FA = false;

  @override
  void initState() {
    super.initState();
    _check2FA();
  }

  Future<void> _check2FA() async {
    final status = await authService.isMfaEnrolled();
    if (mounted) setState(() => _is2FAEnabled = status);
  }

  Future<void> _handle2FAToggle(bool value) async {
    if (_isLoading2FA) return;

    if (!value) {
      setState(() => _isLoading2FA = true);
      try {
        await authService.unenrollMfa();
        if (mounted) {
          setState(() => _is2FAEnabled = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Autenticación de dos factores desactivada')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al desactivar: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading2FA = false);
      }
      return;
    }

    setState(() => _isLoading2FA = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No autenticado');

      final userData = await userService.getUsuarioById(user.uid);
      final telefono = userData?['telefono'] as String?;

      if (telefono == null || telefono.trim().isEmpty) {
        throw Exception('No tienes un número de teléfono registrado. Actualiza tu perfil primero.');
      }

      final session = await authService.getMfaSession();

      await FirebaseAuth.instance.verifyPhoneNumber(
        multiFactorSession: session,
        phoneNumber: telefono,
        verificationCompleted: (_) {},
        verificationFailed: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al enviar SMS: ${error.message}')),
            );
            setState(() => _isLoading2FA = false);
          }
        },
        codeSent: (String vid, int? resendToken) async {
          if (mounted) await _showSmsCodeDialog(vid);
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading2FA = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  Future<void> _showSmsCodeDialog(String verificationId) async {
    setState(() => _isLoading2FA = false);
    final codeController = TextEditingController();
    bool isVerifying = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Verificar SMS'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Ingresa el código de 6 dígitos que enviamos a tu número registrado.'),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Código SMS',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (isVerifying) const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isVerifying ? null : () => Navigator.pop(context),
                child: const Text('CANCELAR'),
              ),
              ElevatedButton(
                onPressed: isVerifying ? null : () async {
                  if (codeController.text.trim().isEmpty) return;

                  setStateDialog(() => isVerifying = true);

                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  try {
                    final credential = PhoneAuthProvider.credential(
                      verificationId: verificationId,
                      smsCode: codeController.text.trim(),
                    );

                    final assertion = PhoneMultiFactorGenerator.getAssertion(credential);
                    await authService.enrollMfa(assertion);

                    if (!mounted) return;
                    navigator.pop();
                    setState(() => _is2FAEnabled = true);
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Autenticación de dos factores activada con éxito')),
                    );
                  } catch (e) {
                    setStateDialog(() => isVerifying = false);
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Código incorrecto o expirado')),
                    );
                  }
                },
                child: const Text('VERIFICAR'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Indica si 2FA está actualmente cargando (usado por el padre).
  bool get isLoading => _isLoading2FA;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(Icons.vibration, color: Theme.of(context).colorScheme.primary),
      title: Text(
        'Autenticación de dos factores',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        _isLoading2FA
            ? 'Procesando...'
            : 'Recibirás un SMS al iniciar sesión en un nuevo dispositivo.',
        style: const TextStyle(fontSize: 12),
      ),
      value: _is2FAEnabled,
      activeThumbColor: Theme.of(context).colorScheme.primary,
      onChanged: _isLoading2FA ? (_) {} : _handle2FAToggle,
    );
  }
}
