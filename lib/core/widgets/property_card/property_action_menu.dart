// Menú de acciones de propiedad: opciones de editar, eliminar y marcar
// como vendida, visible solo para el dueño de la propiedad.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/features/properties/data/properties.dart';
import 'package:xatruch_realstate/features/properties/ui/create_property_screen.dart';
import 'package:xatruch_realstate/core/services/property_service.dart';

class PropertyActionMenu extends StatelessWidget {
  const PropertyActionMenu({
    super.key,
    required this.property,
  });

  final Property property;

  Future<void> _showMarkAsSoldDialog(BuildContext context) async {
    final buyerNameCtrl = TextEditingController();
    final buyerIdCtrl = TextEditingController();
    final soldPriceCtrl = TextEditingController(text: property.price.toString());

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marcar como Vendida'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: buyerNameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del Comprador'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: buyerIdCtrl,
                decoration: const InputDecoration(labelText: 'Email/ID del Comprador (Opcional)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: soldPriceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Precio Final de Venta'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final buyerName = buyerNameCtrl.text.trim();
      final buyerId = buyerIdCtrl.text.trim();
      final soldPrice = double.tryParse(soldPriceCtrl.text.trim()) ?? property.price;

      if (buyerName.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('El nombre del comprador es requerido.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }

      final success = await propertyService.markAsSold(
        propertyId: property.id,
        buyerName: buyerName,
        buyerId: buyerId,
        soldPrice: soldPrice,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Propiedad marcada como vendida' : 'Error al actualizar',
            ),
            backgroundColor: success ? Colors.green : Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.9),
        shape: BoxShape.circle,
      ),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 20),
        onSelected: (value) async {
          if (value == 'edit') {
            await Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (context) => CreatePropertyScreen(
                  propertyToEdit: property,
                ),
              ),
            );
          } else if (value == 'mark_sold') {
            await _showMarkAsSoldDialog(context);
          } else if (value == 'delete') {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Eliminar Propiedad'),
                content: const Text(
                  '¿Está seguro de que desea eliminar esta publicación? Esta acción no se puede deshacer.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('CANCELAR'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: const Text('ELIMINAR'),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              final success = await propertyService.deleteProperty(property.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Propiedad eliminada' : 'Error al eliminar',
                    ),
                    backgroundColor: success ? Colors.green : Theme.of(context).colorScheme.error,
                  ),
                );
              }
            }
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 18),
                SizedBox(width: 8),
                Text('Editar'),
              ],
            ),
          ),
          if (!property.isSold)
            const PopupMenuItem(
              value: 'mark_sold',
              child: Row(
                children: [
                  Icon(Icons.sell_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Marcar como Vendida'),
                ],
              ),
            ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: colorScheme.error, size: 18),
                SizedBox(width: 8),
                Text(
                  'Eliminar',
                  style: TextStyle(color: colorScheme.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
