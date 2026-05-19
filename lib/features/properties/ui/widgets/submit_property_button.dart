// Boton de enviar propiedad: boton principal para publicar la
// propiedad, manejando estados de carga y limites.
import 'package:flutter/material.dart';

/// Botón principal para enviar el formulario de propiedad, manejando estados de carga y límites.
class SubmitPropertyButton extends StatelessWidget {
  const SubmitPropertyButton({
    super.key,
    required this.isSubmitting,
    required this.isLoadingLimit,
    required this.hasLimitError,
    required this.isEditing,
    this.onPressed,
  });
  final bool isSubmitting;
  final bool isLoadingLimit;
  final bool hasLimitError;
  final bool isEditing;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: (isSubmitting || hasLimitError || isLoadingLimit)
          ? null
          : onPressed,
      icon: (isSubmitting || isLoadingLimit)
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Icon(isEditing ? Icons.save : Icons.publish),
      label: Text(
        isLoadingLimit
            ? 'Verificando...'
            : isSubmitting
            ? (isEditing ? 'Guardando...' : 'Publicando...')
            : (isEditing ? 'Guardar Cambios' : 'Publicar Propiedad'),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
