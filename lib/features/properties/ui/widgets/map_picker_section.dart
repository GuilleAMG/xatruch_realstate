// Seccion de selector de mapa: muestra un mapa interactivo para
// elegir la ubicacion de la propiedad al publicarla.
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Muestra el selector de ubicación de mapa con vista previa, botón de ubicación actual
/// y un botón para abrir la pantalla completa del selector de mapa.
class MapPickerSection extends StatelessWidget {
  const MapPickerSection({
    super.key,
    required this.selectedLatitude,
    required this.selectedLongitude,
    required this.onGetCurrentLocation,
    required this.onOpenMapPicker,
  });
  final double? selectedLatitude;
  final double? selectedLongitude;
  final VoidCallback onGetCurrentLocation;
  final VoidCallback onOpenMapPicker;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.map_outlined, color: colorScheme.primary),
            title: const Text('Ubicación en el Mapa'),
            subtitle: Text(
              selectedLatitude != null
                  ? 'Ubicación seleccionada: ${selectedLatitude!.toStringAsFixed(4)}, ${selectedLongitude!.toStringAsFixed(4)}'
                  : 'Selecciona la ubicación exacta de la propiedad',
              style: TextStyle(
                color: selectedLatitude != null
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.my_location, color: colorScheme.primary),
              onPressed: onGetCurrentLocation,
            ),
          ),
          if (selectedLatitude != null)
            Container(
              height: 150,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(selectedLatitude!, selectedLongitude!),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected-location'),
                      position: LatLng(selectedLatitude!, selectedLongitude!),
                    ),
                  },

                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: false,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: OutlinedButton.icon(
              onPressed: onOpenMapPicker,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: Text(
                selectedLatitude != null
                    ? 'Cambiar ubicación'
                    : 'Seleccionar en el mapa',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
