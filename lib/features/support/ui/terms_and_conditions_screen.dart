// Pantalla de terminos y condiciones: muestra el documento legal
// de terminos de uso de la aplicacion.
import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Términos y Condiciones',
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
              title: '1. Aceptación de los Términos',
              content: 'Al acceder o utilizar la aplicación móvil Xatruch Real Estate, el usuario acepta de manera expresa y sin reservas todas las disposiciones establecidas en estos Términos y Condiciones. Si no está de acuerdo con alguno de los términos, deberá abstenerse de utilizar el servicio.',
            ),
            _buildSection(context,
              title: '2. Uso de la Plataforma',
              content: 'Xatruch Real Estate es una plataforma orientada a facilitar la publicación y búsqueda de bienes raíces. Queda estrictamente prohibido el uso de la aplicación para actividades fraudulentas, o la subida de información engañosa sobre propiedades que no le pertenecen. Los usuarios son los únicos responsables de la veracidad de los inmuebles publicados.',
            ),
            _buildSection(context,
              title: '3. Planes y Suscripciones',
              content: 'Ciertas funcionalidades, como el límite de propiedades que puede publicar, están regidas por planes de suscripción predefinidos. Al utilizar un plan, se compromete a respetar los límites de publicaciones activas permitidas. Xatruch Real Estate se reserva el derecho de modificar o suspender suscripciones que infrinjan los términos de uso.',
            ),
            _buildSection(context,
              title: '4. Terminación de la Cuenta',
              content: 'El usuario puede solicitar la eliminación de su cuenta en cualquier momento mediante la sección de Privacidad previa validación de identidad SMS. Por protección contra el fraude, se iniciará un periodo de gracia de 24 horas antes de la eliminación permanente de los datos y propiedades asociadas. Xatruch Real Estate se reserva el derecho de inhabilitar proactivamente cuentas que violen estos lineamientos.',
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
