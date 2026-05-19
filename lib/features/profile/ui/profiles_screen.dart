// Pantalla de perfil: permite ver y editar la informacion personal
// del usuario incluyendo foto, nombre, correo y telefono.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xatruch_realstate/features/profile/controllers/profile_controller.dart';
import 'package:xatruch_realstate/features/profile/ui/widgets/profile_text_field.dart';
import 'package:xatruch_realstate/features/profile/ui/widgets/profile_verifiable_field.dart';
import 'package:xatruch_realstate/features/profile/ui/widgets/profile_photo_selector.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = ProfileController();

  @override
  void initState() {
    super.initState();
    _controller.loadProfile();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => _PhotoPickerSheet(
        hasPhoto: _controller.photoUrl != null || _controller.newPhoto != null,
        onRemove: () => setState(() => _controller.removePhoto()),
      ),
    );

    if (source == null) return;
    final image = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 80);
    if (image != null) setState(() => _controller.setNewPhoto(File(image.path)));
  }

  Future<void> _handleEmailUpdate() async {
    final newEmail = await _showInputDialog('Cambiar Correo', 'Nuevo correo', _controller.emailController.text, TextInputType.emailAddress);
    if (newEmail == null || newEmail.isEmpty) return;

    try {
      await _controller.startEmailUpdate(newEmail);
      _showSnackBar('Se envió un correo de verificación a $newEmail.');
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _handlePhoneUpdate() async {
    final newPhone = await _showInputDialog('Cambiar Teléfono', 'Nuevo teléfono (Ej: +504...)', _controller.phoneController.text, TextInputType.phone);
    if (newPhone == null || newPhone.isEmpty) return;

    try {
      final verificationId = await _controller.sendPhoneVerification(newPhone);
      final smsCode = await _showInputDialog('Verificar SMS', 'Código de 6 dígitos', '', TextInputType.number, maxLength: 6);
      if (smsCode != null) {
        await _controller.verifySmsCode(verificationId, smsCode);
        _showSnackBar('Teléfono actualizado correctamente.', isSuccess: true);
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) return const Center(child: CircularProgressIndicator());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ProfilePhotoSelector(
                    newPhoto: _controller.newPhoto,
                    photoUrl: _controller.photoUrl,
                    isSaving: _controller.isSaving,
                    onTap: _pickPhoto,
                  ),
                  const SizedBox(height: 30),
                  ProfileTextField(
                    controller: _controller.nameController,
                    label: 'Nombre Completo',
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 16),
                  ProfileVerifiableField(
                    controller: _controller.emailController,
                    label: 'Correo Electrónico',
                    icon: Icons.email_outlined,
                    onEditTap: _handleEmailUpdate,
                  ),
                  const SizedBox(height: 16),
                  ProfileVerifiableField(
                    controller: _controller.phoneController,
                    label: 'Teléfono',
                    icon: Icons.phone_outlined,
                    onEditTap: _handlePhoneUpdate,
                  ),
                  const SizedBox(height: 16),
                  ProfileTextField(
                    controller: _controller.dniController,
                    label: 'DNI / Identidad',
                    icon: Icons.badge_outlined,
                    enabled: false,
                  ),
                  const SizedBox(height: 40),
                  _SaveButton(
                    isSaving: _controller.isSaving,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (await _controller.saveProfile()) {
                          _showSnackBar('¡Perfil actualizado!', isSuccess: true);
                          if (context.mounted) Navigator.of(context).pop();
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(String msg, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: isSuccess ? Colors.green : null));
  }

  void _showErrorSnackBar(String error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Theme.of(context).colorScheme.error));
  }

  Future<String?> _showInputDialog(String title, String label, String initialValue, TextInputType type, {int? maxLength}) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, keyboardType: type, maxLength: maxLength, decoration: InputDecoration(labelText: label)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Aceptar')),
        ],
      ),
    );
  }
}

class _PhotoPickerSheet extends StatelessWidget {
  const _PhotoPickerSheet({required this.hasPhoto, required this.onRemove});
  final bool hasPhoto;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(padding: EdgeInsets.all(16), child: Text('Cambiar foto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ListTile(leading: Icon(Icons.photo_library, color: primary), title: const Text('Galería'), onTap: () => Navigator.pop(context, ImageSource.gallery)),
          ListTile(leading: Icon(Icons.camera_alt, color: primary), title: const Text('Cámara'), onTap: () => Navigator.pop(context, ImageSource.camera)),
          if (hasPhoto) ListTile(leading: const Icon(Icons.delete_outline, color: Colors.red), title: const Text('Eliminar', style: TextStyle(color: Colors.red)), onTap: onRemove),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isSaving, required this.onPressed});
  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSaving ? null : onPressed,
        icon: isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save_outlined),
        label: Text(isSaving ? 'Guardando...' : 'Guardar Cambios', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}
