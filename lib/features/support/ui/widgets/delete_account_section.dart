// Seccion de eliminacion de cuenta: maneja el flujo de eliminacion
// con verificacion SMS y periodo de gracia de 24 horas.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';

/// Gestiona el flujo de eliminación de cuenta con verificación SMS y período de gracia de 24 horas.
/// Extraído de PrivacyScreen para seguir el principio de responsabilidad única.
class DeleteAccountSection extends StatefulWidget {
  const DeleteAccountSection({super.key});

  @override
  State<DeleteAccountSection> createState() => _DeleteAccountSectionState();
}

class _DeleteAccountSectionState extends State<DeleteAccountSection> {
  bool _isProcessing = false;

  Future<void> handleDeleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '¿Desea solicitar la eliminación de la cuenta?',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        content: const Text(
          'Tu cuenta se pasará a estado de eliminación y requerirá una validación por SMS.\n\nUna vez verificada, tendrás 24 HORAS para cancelar antes de que se borren todos tus datos permanentemente.\n\n¿Continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'SÍ, CONTINUAR',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    setState(() => _isProcessing = true);

    try {
      final userData = await userService.getUsuarioById(user.uid);
      final telefono = userData?['telefono'] as String?;

      if (telefono == null || telefono.trim().isEmpty) {
        throw Exception(
          'No tienes teléfono registrado. Para mayor seguridad, '
          'primero debes agregar un teléfono.',
        );
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: telefono,
        verificationCompleted: (_) {},
        verificationFailed: (error) {
          if (mounted) {
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Fallo SMS: ${error.message}')),
            );
          }
        },
        codeSent: (String vid, int? token) async {
          if (mounted) await _showDeleteSmsCodeDialog(vid, user.uid);
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showDeleteSmsCodeDialog(
    String verificationId,
    String uid, // ← uid instead of email; that's what scheduleAccountDeletion needs
  ) async {
    setState(() => _isProcessing = false);
    final codeController = TextEditingController();
    bool isVerifying = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Verificar SMS para Eliminación'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Para proteger tu cuenta, hemos enviado un código a tu número.',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Código SMS',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (isVerifying)
                  const Padding(
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: isVerifying
                    ? null
                    : () async {
                        if (codeController.text.trim().isEmpty) return;

                        setStateDialog(() => isVerifying = true);
                        try {
                          final credential = PhoneAuthProvider.credential(
                            verificationId: verificationId,
                            smsCode: codeController.text.trim(),
                          );

                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await user.reauthenticateWithCredential(credential);

                            // Pass uid positionally — matches scheduleAccountDeletion(String uid)
                            await userService.scheduleAccountDeletion(uid);
                          }

                          if (!context.mounted) return;
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '✅ Tu cuenta ha sido agendada para eliminación en 24 horas.',
                              ),
                              duration: Duration(seconds: 8),
                            ),
                          );
                        } catch (e) {
                          setStateDialog(() => isVerifying = false);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Código incorrecto o expirado.'),
                            ),
                          );
                        }
                      },
                child: const Text('CONFIRMAR ELIMINACIÓN'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(Icons.delete_forever_outlined, color: colorScheme.error),
      title: Text(
        _isProcessing ? 'Procesando...' : 'Eliminar cuenta',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.error,
        ),
      ),
      subtitle: const Text(
        'Borrar permanentemente tus datos',
        style: TextStyle(fontSize: 12),
      ),
      trailing: _isProcessing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.chevron_right, size: 20, color: colorScheme.outline),
      onTap: _isProcessing ? null : handleDeleteAccount,
    );
  }
}