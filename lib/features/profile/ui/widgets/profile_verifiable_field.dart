import 'package:flutter/material.dart';

/// Campo de texto de solo lectura con acción de editar para actualizaciones verificadas (Email/Teléfono).
class ProfileVerifiableField extends StatelessWidget {
  const ProfileVerifiableField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onEditTap,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        suffixIcon: IconButton(
          icon: Icon(Icons.edit, color: colorScheme.primary, size: 20),
          tooltip: 'Cambiar $label con verificación',
          onPressed: onEditTap,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }
}
