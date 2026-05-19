import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:xatruch_realstate/features/properties/data/properties.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';
import 'package:xatruch_realstate/core/services/property_service.dart';
import 'package:xatruch_realstate/core/services/storage_service.dart';
import 'package:xatruch_realstate/core/services/payment_service.dart';
import 'package:xatruch_realstate/core/services/location_service.dart';

/// Controlador para la gestión de la lógica de creación/edición de propiedades.
class CreatePropertyController extends ChangeNotifier {
  CreatePropertyController({this.propertyToEdit}) {
    _initControllers();
    _checkLimit();
  }

  final Property? propertyToEdit;

  late TextEditingController titleController;
  late TextEditingController locationController;
  late TextEditingController municipalityController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  late TextEditingController bedroomsController;
  late TextEditingController bathroomsController;
  late TextEditingController areaController;

  String? selectedDepartment;
  String? selectedPropertyType;

  final List<XFile> selectedMedia = [];
  List<String> existingMediaUrls = [];
  final ImagePicker _picker = ImagePicker();

  bool isSubmitting = false;
  double uploadProgress = 0;
  bool isLoadingLimit = true;
  String? limitMessage;

  bool hasElectricity = false;
  bool hasWater = false;
  double? selectedLatitude;
  double? selectedLongitude;

  void _initControllers() {
    final p = propertyToEdit;
    titleController = TextEditingController(text: p?.title ?? '');
    locationController = TextEditingController(text: p?.location ?? '');
    municipalityController = TextEditingController(text: p?.municipality ?? '');
    selectedDepartment = p?.department.isNotEmpty == true ? p!.department : null;
    selectedPropertyType = p?.propertyType.isNotEmpty == true ? p!.propertyType : null;
    priceController = TextEditingController(text: p?.price.toString() ?? '');
    descriptionController = TextEditingController(text: p?.description ?? '');
    bedroomsController = TextEditingController(text: p?.bedrooms.toString() ?? '');
    bathroomsController = TextEditingController(text: p?.bathrooms.toString() ?? '');
    areaController = TextEditingController(text: p?.area.toString() ?? '');
    hasElectricity = p?.hasElectricity ?? false;
    hasWater = p?.hasWater ?? false;
    selectedLatitude = p?.latitude;
    selectedLongitude = p?.longitude;
    existingMediaUrls = p != null ? List.from(p.imageUrls) : [];
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    municipalityController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    bedroomsController.dispose();
    bathroomsController.dispose();
    areaController.dispose();
    super.dispose();
  }

  Future<void> _checkLimit() async {
    final user = authService.currentUser;
    if (user == null || propertyToEdit != null) {
      isLoadingLimit = false;
      notifyListeners();
      return;
    }
    try {
      await paymentService.syncCustomerInfo();
      await propertyService.checkPostLimit(user.uid);
      isLoadingLimit = false;
      notifyListeners();
    } catch (e) {
      limitMessage = e.toString().replaceFirst('Exception:', '').trim();
      isLoadingLimit = false;
      notifyListeners();
    }
  }

  // ── Modificadores de Estado (Setters) ──

  void setDepartment(String? val) {
    selectedDepartment = val;
    notifyListeners();
  }

  void setPropertyType(String? val) {
    selectedPropertyType = val;
    notifyListeners();
  }

  void setElectricity(bool val) {
    hasElectricity = val;
    notifyListeners();
  }

  void setWater(bool val) {
    hasWater = val;
    notifyListeners();
  }

  // ── Media ──

  Future<void> pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      selectedMedia.addAll(images);
      notifyListeners();
    }
  }

  Future<void> pickFromCamera() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      selectedMedia.add(photo);
      notifyListeners();
    }
  }

  Future<void> pickVideo() async {
    final video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      selectedMedia.add(video);
      notifyListeners();
    }
  }

  void removeMedia(int index) {
    selectedMedia.removeAt(index);
    notifyListeners();
  }

  void removeExistingMedia(int index) {
    existingMediaUrls.removeAt(index);
    notifyListeners();
  }

  // ── Localización ──

  Future<void> getCurrentLocation({required void Function(String) onError}) async {
    try {
      final position = await locationService.getCurrentLocation();
      selectedLatitude = position.latitude;
      selectedLongitude = position.longitude;
      notifyListeners();
    } catch (e) {
      onError(e.toString().replaceFirst('Exception:', '').trim());
    }
  }

  void setLocationFromMap(LatLng? result) {
    if (result != null) {
      selectedLatitude = result.latitude;
      selectedLongitude = result.longitude;
      notifyListeners();
    }
  }

  // ── Envío del Formulario ──

  Future<bool> submitProperty({required void Function(String) onError}) async {
    final user = authService.currentUser;
    if (user == null) {
      onError('Debe iniciar sesión para realizar esta acción');
      return false;
    }

    isSubmitting = true;
    uploadProgress = 0;
    notifyListeners();

    try {
      final isEditing = propertyToEdit != null;
      if (!isEditing) await propertyService.checkPostLimit(user.uid);

      final propertyId = isEditing
          ? propertyToEdit!.id
          : DateTime.now().millisecondsSinceEpoch.toString();

      final List<String> finalImageUrls = List.from(existingMediaUrls);
      final List<String> finalVideoUrls = List.from(propertyToEdit?.videoUrls ?? []);

      await _uploadMediaFiles(propertyId, finalImageUrls, finalVideoUrls);

      uploadProgress = 1.0;
      notifyListeners();

      final userProfile = await userService.getUsuarioById(user.uid);
      final String sellerName = (userProfile?['nombre'] as String?) ?? user.email ?? 'Vendedor';

      final property = Property(
        id: isEditing ? propertyToEdit!.id : '',
        title: titleController.text.trim(),
        location: locationController.text.trim(),
        department: selectedDepartment ?? '',
        municipality: municipalityController.text.trim(),
        propertyType: selectedPropertyType ?? '',
        price: double.parse(priceController.text.trim()),
        imageUrls: finalImageUrls,
        videoUrls: finalVideoUrls,
        description: descriptionController.text.trim(),
        bedrooms: int.parse(bedroomsController.text.trim()),
        bathrooms: int.parse(bathroomsController.text.trim()),
        area: double.parse(areaController.text.trim()),
        sellerName: isEditing ? propertyToEdit!.sellerName : sellerName,
        sellerId: user.uid,
        hasElectricity: hasElectricity,
        hasWater: hasWater,
        latitude: selectedLatitude,
        longitude: selectedLongitude,
      );

      if (isEditing) {
        await propertyService.updateProperty(property);
      } else {
        await propertyService.addProperty(property);
      }

      isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      isSubmitting = false;
      notifyListeners();
      onError(e.toString());
      return false;
    }
  }

  Future<void> _uploadMediaFiles(String propertyId, List<String> imageUrls, List<String> videoUrls) async {
    if (selectedMedia.isEmpty) return;

    final files = selectedMedia.map((xf) => File(xf.path)).toList();
    for (int i = 0; i < files.length; i++) {
      uploadProgress = (i / files.length);
      notifyListeners();
      
      final extension = files[i].path.split('.').last.toLowerCase();
      final storagePath = 'propiedades/$propertyId/${DateTime.now().millisecondsSinceEpoch}_$i.$extension';
      final url = await storageService.uploadFile(files[i], storagePath);

      if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
        videoUrls.add(url);
      } else {
        imageUrls.add(url);
      }
    }
  }
}
