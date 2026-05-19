// Pantalla de soporte: enlaces a ayuda, contacto por WhatsApp,
// politica de privacidad y terminos y condiciones.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {

  final List<Map<String, String>> _faqs = [
    {
      'question': '¿Cómo puedo agendar una cita?',
      'answer':
          'Puedes contactar directamente al agente encargado de la propiedad a través del chat interno de la aplicación o usando el botón de contacto en el perfil de la propiedad.',
    },
    {
      'question': '¿Es seguro realizar pagos por la app?',
      'answer':
          'Xatruch Inmobiliaria utiliza pasarelas de pago seguras y encriptadas. No almacenamos tus datos bancarios directamente en nuestros servidores.',
    },
    {
      'question': '¿Cómo publicar mi propia propiedad?',
      'answer':
          'Ve a la sección de "Publicar" en el menú principal, completa los detalles, sube tus fotos y videos, y nuestro equipo revisará la publicación en menos de 24 horas.',
    },
  ];

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No se pudo abrir: $url')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayuda y Soporte',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSupportHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Preguntas Frecuentes'),
                  const SizedBox(height: 12),
                  _buildFAQList(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Contacta con Nosotros'),
                  const SizedBox(height: 16),
                  _buildContactOptions(),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.help_center_outlined, size: 64, color: Theme.of(context).colorScheme.onPrimary),
          const SizedBox(height: 16),
          Text(
            '¿En qué podemos ayudarte?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Estamos aquí para resolver tus dudas rápidamente',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildFAQList() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _faqs.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(
              _faqs[index]['question']!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            expandedAlignment: Alignment.topLeft,
            iconColor: Theme.of(context).colorScheme.primary,
            children: [
              Text(
                _faqs[index]['answer']!,
                style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContactOptions() {
    return Column(
      children: [
        _buildContactCard(
          icon: Icons.chat_bubble_outline,
          title: 'WhatsApp Business',
          subtitle: '+504 9999-9999', // <-- Reemplaza con tu número real
          color: const Color(0xFF25D366),
          onTap: () => _launchUrl('https://wa.me/50499999999'), // <-- Reemplaza con tu número real
        ),
        const SizedBox(height: 12),
        _buildContactCard(
          icon: Icons.email_outlined,
          title: 'Correo Electrónico',
          subtitle: 'soporte@xatruch.hn',
          color: Theme.of(context).colorScheme.primary,
          onTap: () => _launchUrl('mailto:soporte@xatruch.hn'),
        ),

      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Theme.of(context).colorScheme.outline),
          ],
        ),
      ),
    );
  }
}
