// Campos del formulario de propiedad: renderiza los campos de texto,
// dropdowns y toggles para crear o editar una propiedad.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/core/constants/app_constants.dart';

/// Renderiza todos los campos de texto del formulario, dropdowns y toggles
/// para el formulario de creación/edición de propiedad.
class PropertyFormFields extends StatelessWidget {
  const PropertyFormFields({
    super.key,
    required this.titleController,
    required this.locationController,
    required this.municipalityController,
    required this.priceController,
    required this.descriptionController,
    required this.bedroomsController,
    required this.bathroomsController,
    required this.areaController,
    required this.selectedDepartment,
    required this.selectedPropertyType,
    required this.hasElectricity,
    required this.hasWater,
    required this.onDepartmentChanged,
    required this.onPropertyTypeChanged,
    required this.onMunicipalityChanged,
    required this.onElectricityChanged,
    required this.onWaterChanged,
    required this.requiredValidator,
    required this.numberValidator,
    required this.intValidator,
  });
  final TextEditingController titleController;
  final TextEditingController locationController;
  final TextEditingController municipalityController;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final TextEditingController bedroomsController;
  final TextEditingController bathroomsController;
  final TextEditingController areaController;

  final String? selectedDepartment;
  final String? selectedPropertyType;
  final bool hasElectricity;
  final bool hasWater;

  final ValueChanged<String?> onDepartmentChanged;
  final ValueChanged<String?> onPropertyTypeChanged;
  final ValueChanged<String?> onMunicipalityChanged;
  final ValueChanged<bool> onElectricityChanged;
  final ValueChanged<bool> onWaterChanged;

  final String? Function(String?) requiredValidator;
  final String? Function(String?) numberValidator;
  final String? Function(String?) intValidator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
          context,
          controller: titleController,
          label: 'Título de la Propiedad',
          icon: Icons.title,
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedPropertyType,
          decoration: InputDecoration(
            labelText: 'Tipo de Propiedad',
            prefixIcon: Icon(
              Icons.home_work_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
          ),
          menuMaxHeight: 200,
          items: AppConstants.propertyTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: onPropertyTypeChanged,
          validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedDepartment,
          decoration: InputDecoration(
            labelText: 'Departamento',
            prefixIcon: Icon(
              Icons.map_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
          ),
          menuMaxHeight: 200,
          items: AppConstants.departments.map((dep) {
            return DropdownMenuItem(value: dep, child: Text(dep));
          }).toList(),
          onChanged: onDepartmentChanged,
          validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedDepartment != null && selectedDepartment!.isNotEmpty
              ? municipalityController.text.isNotEmpty
                  ? municipalityController.text
                  : null
              : null,
          decoration: InputDecoration(
            labelText: 'Municipio o Ciudad',
            prefixIcon: Icon(Icons.location_city_outlined, color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            hintText: selectedDepartment != null && selectedDepartment!.isNotEmpty
                ? 'Selecciona un municipio'
                : 'Primero elige un departamento',
          ),
          menuMaxHeight: 220,
          items: (selectedDepartment != null && selectedDepartment!.isNotEmpty
                  ? (AppConstants.municipalitiesByDepartment[selectedDepartment] ?? [])
                  : <String>[])
              .map((municipality) => DropdownMenuItem(value: municipality, child: Text(municipality)))
              .toList(),
          onChanged: selectedDepartment != null && selectedDepartment!.isNotEmpty
              ? (value) {
                  municipalityController.text = value ?? '';
                  onMunicipalityChanged(value);
                }
              : null,
          validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          context,
          controller: locationController,
          label: 'Dirección Exacta',
          icon: Icons.location_on_outlined,
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          context,
          controller: priceController,
          label: 'Precio (Lempiras)',
          icon: Icons.attach_money,
          keyboardType: TextInputType.number,
          validator: numberValidator,
          prefixText: 'L ',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          context,
          controller: descriptionController,
          label: 'Descripción',
          icon: Icons.description_outlined,
          maxLines: 3,
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context,
                controller: bedroomsController,
                label: 'Habitaciones',
                icon: Icons.king_bed_outlined,
                keyboardType: TextInputType.number,
                validator: intValidator,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                context,
                controller: bathroomsController,
                label: 'Baños',
                icon: Icons.bathtub_outlined,
                keyboardType: TextInputType.number,
                validator: intValidator,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          context,
          controller: areaController,
          label: 'm² de terreno / m² de construcción',
          icon: Icons.square_foot_outlined,
          keyboardType: TextInputType.number,
          validator: numberValidator,
        ),
        const SizedBox(height: 24),

        // Servicios Públicos
        Text(
          'Servicios Públicos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Electricidad'),
                subtitle: const Text('Servicio eléctrico disponible'),
                secondary: Icon(
                  Icons.electric_bolt,
                  color: hasElectricity ? Colors.amber[700] : Colors.grey,
                ),
                value: hasElectricity,
                activeTrackColor: colorScheme.primary,
                onChanged: onElectricityChanged,
              ),
              Divider(height: 1, color: colorScheme.outlineVariant),
              SwitchListTile(
                title: const Text('Agua Potable'),
                subtitle: const Text('Servicio de agua disponible'),
                secondary: Icon(
                  Icons.water_drop,
                  color: hasWater ? Colors.blue : colorScheme.outline,
                ),
                value: hasWater,
                activeTrackColor: colorScheme.primary,
                onChanged: onWaterChanged,
              ),
            ],
          ),
        ),
      ],
    ),
  );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? prefixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        prefixText: prefixText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      validator: validator,
    );
  }
}
