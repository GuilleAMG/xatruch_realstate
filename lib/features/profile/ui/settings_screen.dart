// Pantalla de configuracion: permite al usuario personalizar
// notificaciones, tema visual y preferencias de ubicacion.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/features/profile/controllers/settings_controller.dart';
import 'package:xatruch_realstate/features/support/ui/privacy_policy_screen.dart';
import 'package:xatruch_realstate/features/support/ui/terms_and_conditions_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.controller});

  final SettingsController? controller;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SettingsController();
    _controller.load();
  }

  Future<void> _sendPasswordResetEmail() async {
    final user = authService.currentUser;
    final email = user?.email;
    if (email == null || email.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró un correo asociado a la cuenta.')),
        );
      }
      return;
    }

    try {
      await authService.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enlace de recuperación enviado a $email')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo enviar el correo de recuperación.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleNotificationToggle(bool value) async {
    final updated = await _controller.handleNotificationToggle(value);
    if (!updated && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permiso de notificaciones denegado. Por favor, actívalo en ajustes del sistema.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Configuración'),
        ),
        body: ListView(
          children: [
            const SizedBox(height: 16),
            _buildSectionHeader('General'),
            SwitchListTile(
              title: const Text('Notificaciones'),
              subtitle: const Text(
                'Recibe actualizaciones sobre nuevas propiedades',
              ),
              value: _controller.notificationsEnabled,
              onChanged: _handleNotificationToggle,
            ),
            SwitchListTile(
              title: const Text('Modo Oscuro'),
              subtitle: const Text('Habilita el modo oscuro'),
              value: _controller.darkModeEnabled,
              onChanged: _controller.handleDarkModeToggle,
            ),
            SwitchListTile(
              title: const Text('Ubicación'),
              subtitle: const Text('Muestra propiedades cercanas'),
              value: _controller.locationEnabled,
              onChanged: _controller.handleLocationToggle,
            ),
            const Divider(),
            _buildSectionHeader('Cuenta'),
            ListTile(
              title: const Text('Contraseña'),
              leading: const Icon(Icons.lock_outline),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _sendPasswordResetEmail,
            ),
            ListTile(
              title: const Text('Política de Privacidad'),
              leading: const Icon(Icons.privacy_tip_outlined),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Términos de Servicio'),
              leading: const Icon(Icons.description_outlined),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const TermsAndConditionsScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            _buildSectionHeader('Información de la App'),
            const ListTile(title: Text('Version'), trailing: Text('1.0.0')),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
