// Pantalla de crear propiedad: formulario completo para publicar
// una nueva propiedad con multimedia, ubicacion y detalles.
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xatruch_realstate/core/utils/validators.dart';
import 'package:xatruch_realstate/features/properties/data/properties.dart';
import 'package:xatruch_realstate/features/properties/controllers/create_property_controller.dart';
import 'package:xatruch_realstate/features/properties/ui/map_selection_screen.dart';
import 'package:xatruch_realstate/features/properties/ui/widgets/media_picker_section.dart';
import 'package:xatruch_realstate/features/properties/ui/widgets/property_form_fields.dart';
import 'package:xatruch_realstate/features/properties/ui/widgets/map_picker_section.dart';
import 'package:xatruch_realstate/features/properties/ui/widgets/limit_warning_banner.dart';
import 'package:xatruch_realstate/features/properties/ui/widgets/upload_progress_indicator.dart';
import 'package:xatruch_realstate/features/properties/ui/widgets/submit_property_button.dart';

class CreatePropertyScreen extends StatefulWidget {
  const CreatePropertyScreen({super.key, this.propertyToEdit});

  final Property? propertyToEdit;

  @override
  State<CreatePropertyScreen> createState() => _CreatePropertyScreenState();
}

class _CreatePropertyScreenState extends State<CreatePropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final CreatePropertyController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CreatePropertyController(propertyToEdit: widget.propertyToEdit);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  Future<void> _openMapPicker() async {
    final LatLng? result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute<LatLng>(
        builder: (context) => MapSelectionScreen(
          initialLocation: _controller.selectedLatitude != null
              ? LatLng(_controller.selectedLatitude!, _controller.selectedLongitude!)
              : const LatLng(14.0723, -87.1921),
        ),
      ),
    );
    _controller.setLocationFromMap(result);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final success = await _controller.submitProperty(onError: _showError);
    if (success && mounted) {
      final msg = widget.propertyToEdit != null ? '¡Propiedad actualizada exitosamente!' : '¡Propiedad publicada exitosamente!';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Propiedad', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MediaPickerSection(
                    selectedMedia: _controller.selectedMedia,
                    existingMediaUrls: _controller.existingMediaUrls,
                    onPickImages: _controller.pickImages,
                    onPickFromCamera: _controller.pickFromCamera,
                    onPickVideo: _controller.pickVideo,
                    onRemoveMedia: _controller.removeMedia,
                    onRemoveExistingMedia: _controller.removeExistingMedia,
                  ),
                  const SizedBox(height: 24),
                  if (_controller.limitMessage != null) 
                    LimitWarningBanner(message: _controller.limitMessage!),
                  PropertyFormFields(
                    titleController: _controller.titleController,
                    locationController: _controller.locationController,
                    municipalityController: _controller.municipalityController,
                    priceController: _controller.priceController,
                    descriptionController: _controller.descriptionController,
                    bedroomsController: _controller.bedroomsController,
                    bathroomsController: _controller.bathroomsController,
                    areaController: _controller.areaController,
                    selectedDepartment: _controller.selectedDepartment,
                    selectedPropertyType: _controller.selectedPropertyType,
                    hasElectricity: _controller.hasElectricity,
                    hasWater: _controller.hasWater,
                    onDepartmentChanged: _controller.setDepartment,
                    onPropertyTypeChanged: _controller.setPropertyType,
                    onMunicipalityChanged: _controller.setMunicipality,
                    onElectricityChanged: _controller.setElectricity,
                    onWaterChanged: _controller.setWater,
                    requiredValidator: Validators.validateRequired,
                    numberValidator: Validators.validateNumber,
                    intValidator: Validators.validateInt,
                  ),
                  const SizedBox(height: 16),
                  MapPickerSection(
                    selectedLatitude: _controller.selectedLatitude,
                    selectedLongitude: _controller.selectedLongitude,
                    onGetCurrentLocation: () => _controller.getCurrentLocation(onError: _showError),
                    onOpenMapPicker: _openMapPicker,
                  ),
                  const SizedBox(height: 32),
                  if (_controller.isSubmitting) 
                    UploadProgressIndicator(progress: _controller.uploadProgress),
                  SubmitPropertyButton(
                    isSubmitting: _controller.isSubmitting,
                    isLoadingLimit: _controller.isLoadingLimit,
                    hasLimitError: _controller.limitMessage != null,
                    isEditing: widget.propertyToEdit != null,
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
