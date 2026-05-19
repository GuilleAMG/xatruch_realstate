// Pantalla de privacidad y seguridad: opciones de autenticacion
// de dos factores y eliminacion de cuenta.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/biometric_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:xatruch_realstate/features/support/ui/privacy_policy_screen.dart';
import 'package:xatruch_realstate/features/support/ui/terms_and_conditions_screen.dart';
import 'package:xatruch_realstate/features/support/ui/widgets/two_factor_section.dart';
import 'package:xatruch_realstate/features/support/ui/widgets/delete_account_section.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _biometricsEnabled = true;
  bool _shareDataEnabled = false;
  bool _locationDiscovery = true;

  Future<void> _handleBiometricToggle(bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    if (value) {
      final canAuth = await biometricService.isBiometricAvailable();
      if (!mounted) return;
      if (!canAuth) {
        messenger.showSnackBar(
          const SnackBar(content: Text('La biometría no está disponible en este dispositivo')),
        );
        return;
      }

      final authenticated = await biometricService.authenticate();
      if (!mounted) return;
      if (authenticated) {
        setState(() => _biometricsEnabled = true);
        messenger.showSnackBar(
          const SnackBar(content: Text('Acceso biométrico activado')),
        );
      } else {
        setState(() => _biometricsEnabled = false);
      }
    } else {
      setState(() => _biometricsEnabled = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Acceso biométrico desactivado')),
      );
    }
  }

  Future<void> _handleChangePassword() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Contraseña'),
        content: Text(
          'Enviaremos un correo de recuperación a $email para que puedas restablecer tu contraseña.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              await authService.sendPasswordResetEmail(email);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Correo enviado exitosamente')),
                );
              }
            },
            child: const Text('ENVIAR CORREO'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacidad y Seguridad',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('SEGURIDAD DE LA CUENTA'),
            _buildActionCard([
              _buildListTile(
                icon: Icons.lock_outline,
                title: 'Cambiar Contraseña',
                subtitle: 'Actualiza tu clave de acceso',
                onTap: _handleChangePassword,
              ),
              const Divider(height: 1),
              const TwoFactorSection(),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.fingerprint,
                title: 'Acceso Biométrico',
                subtitle: 'Usa FaceID o huella digital',
                value: _biometricsEnabled,
                onChanged: _handleBiometricToggle,
              ),
            ]),
            _buildSectionHeader('PRIVACIDAD DE DATOS'),
            _buildActionCard([
              _buildSwitchTile(
                icon: Icons.location_on_outlined,
                title: 'Descubrimiento por Ubicación',
                subtitle: 'Mostrar propiedades cerca de ti',
                value: _locationDiscovery,
                onChanged: (v) => setState(() => _locationDiscovery = v),
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.analytics_outlined,
                title: 'Compartir Datos de Uso',
                subtitle: 'Ayúdanos a mejorar tu experiencia',
                value: _shareDataEnabled,
                onChanged: (v) => setState(() => _shareDataEnabled = v),
              ),
            ]),
            _buildSectionHeader('GESTIÓN DE INFORMACIÓN'),
            _buildActionCard([
              const DeleteAccountSection(),
            ]),
            _buildSectionHeader('LEGAL'),
            _buildActionCard([
              _buildListTile(
                icon: Icons.description_outlined,
                title: 'Política de Privacidad',
                onTap: () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyScreen()),
                  );
                },
              ),
              const Divider(height: 1),
              _buildListTile(
                icon: Icons.gavel_outlined,
                title: 'Términos y Condiciones',
                onTap: () async {
                  await Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(builder: (_) => const TermsAndConditionsScreen()),
                  );
                },
              ),
            ]),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Versión 1.0.0',
                style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildActionCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing: trailing ??
          Icon(Icons.chevron_right, size: 20, color: Theme.of(context).colorScheme.outline),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      activeThumbColor: Theme.of(context).colorScheme.primary,
      onChanged: onChanged,
    );
  }
}
