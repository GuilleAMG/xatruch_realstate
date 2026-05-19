// Pantalla de historial de ventas: muestra las propiedades vendidas
// por el usuario con detalles de comprador y precio.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/property_service.dart';
import 'package:xatruch_realstate/features/properties/data/properties.dart';

class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    final currencyFormatter = NumberFormat.currency(symbol: 'L ', decimalDigits: 2);
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial de Ventas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Property>>(
        stream: propertyService.getSoldPropertiesList(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar historial: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final properties = snapshot.data ?? [];

          if (properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes propiedades vendidas',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              final soldPrice = property.soldPrice ?? property.price;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Información de propiedad
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              image: property.imageUrls.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(property.imageUrls.first),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: property.imageUrls.isEmpty
                                ? const Icon(Icons.home, size: 40)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  property.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.secondary),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        property.location,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Reporte de venta
                      const Text(
                        'Reporte de Venta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      _buildReportRow(
                        context,
                        icon: Icons.person,
                        label: 'Comprador:',
                        value: property.buyerName.isNotEmpty ? property.buyerName : 'N/A',
                      ),
                      if (property.buyerId.isNotEmpty)
                        _buildReportRow(
                          context,
                          icon: Icons.email,
                          label: 'Contacto:',
                          value: property.buyerId,
                        ),
                      _buildReportRow(
                        context,
                        icon: Icons.attach_money,
                        label: 'Precio Original:',
                        value: currencyFormatter.format(property.price),
                      ),
                      _buildReportRow(
                        context,
                        icon: Icons.sell,
                        label: 'Precio de Venta:',
                        value: currencyFormatter.format(soldPrice),
                        valueStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      if (property.soldAt != null)
                        _buildReportRow(
                          context,
                          icon: Icons.calendar_today,
                          label: 'Fecha de Venta:',
                          value: dateFormatter.format(property.soldAt!),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildReportRow(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w400),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
