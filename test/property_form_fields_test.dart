import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xatruch_realstate/features/properties/ui/widgets/property_form_fields.dart';

void main() {
  group('PropertyFormFields', () {
    testWidgets('municipality dropdown stays disabled until a department is selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyFormFields(
              titleController: TextEditingController(),
              locationController: TextEditingController(),
              municipalityController: TextEditingController(),
              priceController: TextEditingController(),
              descriptionController: TextEditingController(),
              bedroomsController: TextEditingController(),
              bathroomsController: TextEditingController(),
              areaController: TextEditingController(),
              selectedDepartment: null,
              selectedPropertyType: null,
              hasElectricity: false,
              hasWater: false,
              onDepartmentChanged: (_) {},
              onPropertyTypeChanged: (_) {},
              onMunicipalityChanged: (_) {},
              onElectricityChanged: (_) {},
              onWaterChanged: (_) {},
              requiredValidator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              numberValidator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              intValidator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
            ),
          ),
        ),
      );

      final municipalityField = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>).at(2),
      );
      expect(municipalityField.onChanged, isNull);
    });

    testWidgets('municipality dropdown enables once a department is selected', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyFormFields(
              titleController: TextEditingController(),
              locationController: TextEditingController(),
              municipalityController: TextEditingController(),
              priceController: TextEditingController(),
              descriptionController: TextEditingController(),
              bedroomsController: TextEditingController(),
              bathroomsController: TextEditingController(),
              areaController: TextEditingController(),
              selectedDepartment: 'Francisco Morazán',
              selectedPropertyType: null,
              hasElectricity: false,
              hasWater: false,
              onDepartmentChanged: (_) {},
              onPropertyTypeChanged: (_) {},
              onMunicipalityChanged: (_) {},
              onElectricityChanged: (_) {},
              onWaterChanged: (_) {},
              requiredValidator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              numberValidator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              intValidator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
            ),
          ),
        ),
      );

      final municipalityField = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>).at(2),
      );
      expect(municipalityField.enabled, isTrue);
    });
  });
}
