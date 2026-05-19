// Modal de filtros: permite al usuario filtrar propiedades por
// departamento, tipo, rango de precio, habitaciones y servicios.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/core/constants/app_constants.dart';

/// Clase de datos que contiene todos los valores del estado de filtros.
class PropertyFilters {
  PropertyFilters({
    this.department,
    this.propertyType,
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.minBathrooms,
    this.reqElectricity = false,
    this.reqWater = false,
  });

  String? department;
  String? propertyType;
  double? minPrice;
  double? maxPrice;
  int? minBedrooms;
  int? minBathrooms;
  bool reqElectricity;
  bool reqWater;

  void clear() {
    department = null;
    propertyType = null;
    minPrice = null;
    maxPrice = null;
    minBedrooms = null;
    minBathrooms = null;
    reqElectricity = false;
    reqWater = false;
  }
}

/// Muestra el modal inferior de filtros avanzados.
/// Actualiza [filters] en su lugar, luego llama a [onFiltersChanged] para que el padre se reconstruya.
Future<void> showFilterModal(
  BuildContext context, {
  required PropertyFilters filters,
  required VoidCallback onFiltersChanged,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtros Avanzados',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() => filters.clear());
                          onFiltersChanged();
                        },
                        child: const Text('Limpiar'),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  // Departamento
                  DropdownButtonFormField<String>(
                    initialValue: filters.department,
                    decoration: const InputDecoration(labelText: 'Departamento'),
                    items: AppConstants.departments
                        .map((dep) => DropdownMenuItem(value: dep, child: Text(dep)))
                        .toList(),
                    onChanged: (val) {
                      setModalState(() => filters.department = val);
                      onFiltersChanged();
                    },
                  ),
                  const SizedBox(height: 12),
                  // Tipo de propiedad
                  DropdownButtonFormField<String>(
                    initialValue: filters.propertyType,
                    decoration: const InputDecoration(labelText: 'Tipo de Propiedad'),
                    items: AppConstants.propertyTypes
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (val) {
                      setModalState(() => filters.propertyType = val);
                      onFiltersChanged();
                    },
                  ),
                  const SizedBox(height: 12),
                  // Precio
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: filters.minPrice?.toString() ?? '',
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Precio Min (L)'),
                          onChanged: (val) {
                            setModalState(() => filters.minPrice = double.tryParse(val));
                            onFiltersChanged();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: filters.maxPrice?.toString() ?? '',
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Precio Max (L)'),
                          onChanged: (val) {
                            setModalState(() => filters.maxPrice = double.tryParse(val));
                            onFiltersChanged();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Habitaciones
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: filters.minBedrooms?.toString() ?? '',
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Cuartos (Min)'),
                          onChanged: (val) {
                            setModalState(() => filters.minBedrooms = int.tryParse(val));
                            onFiltersChanged();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: filters.minBathrooms?.toString() ?? '',
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Baños (Min)'),
                          onChanged: (val) {
                            setModalState(() => filters.minBathrooms = int.tryParse(val));
                            onFiltersChanged();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Servicios
                  CheckboxListTile(
                    title: const Text('Requiere Electricidad'),
                    value: filters.reqElectricity,
                    onChanged: (val) {
                      setModalState(() => filters.reqElectricity = val ?? false);
                      onFiltersChanged();
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Requiere Agua Potable'),
                    value: filters.reqWater,
                    onChanged: (val) {
                      setModalState(() => filters.reqWater = val ?? false);
                      onFiltersChanged();
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Aplicar Filtros'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
