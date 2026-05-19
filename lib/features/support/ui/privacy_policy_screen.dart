// Pantalla de politica de privacidad: muestra el documento legal
// de privacidad de la aplicacion.
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Política de Privacidad',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Última actualización: 20 de marzo de 2026',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(context,
              title: '1. Recopilación de Información',
              content: 'Xatruch Real Estate recopila información personal que nos proporcionas directamente al registrarte en nuestra plataforma, tales como nombre, correo electrónico y número de teléfono. Asimismo, para mejorar la experiencia de búsqueda de propiedades, podríamos solicitar acceso a tu ubicación en tiempo real.',
            ),
            _buildSection(context,
              title: '2. Uso de la Información',
              content: 'Utilizamos tus datos para: Facilitar la compra, venta o alquiler de inmuebles. Contactarte en caso de actualizaciones sobre propiedades de interés. Proporcionar soporte técnico y asistencia al usuario. Implementar y administrar sistemas de seguridad y autenticación (MFA/2FA).',
            ),
            _buildSection(context,
              title: '3. Seguridad y Retención',
              content: 'Toda tu información es transferida mediante protocolos de encriptación seguros. Puedes solicitar la eliminación definitiva de tu cuenta y todos tus registros en la sección de Privacidad. Al solicitar la eliminación, iniciaremos un periodo de retención de 24 horas antes de erradicar los datos de nuestros servidores, para fines de protección de seguridad.',
            ),
            _buildSection(context,
              title: '4. Compartir con Terceros',
              content: 'No vendemos ni compartimos tu información personal con terceros para fines comerciales o de marketing sin tu consentimiento explícito. Solo compartimos datos cuando es ordenado por la ley aplicable.',
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                '© 2026 Xatruch Real Estate. Todos los derechos reservados.',
                style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
