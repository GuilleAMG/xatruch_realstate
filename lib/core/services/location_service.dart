import 'package:geolocator/geolocator.dart';

/// Servicio para manejar la obtención de la ubicación actual del usuario.
class LocationService {
  /// Obtiene la ubicación actual tras verificar y solicitar los permisos necesarios.
  /// Lanza una excepción con un mensaje descriptivo si no es posible.
  Future<Position> getCurrentLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Por favor, active los servicios de ubicación');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Los permisos de ubicación están denegados permanentemente');
    }

    return await Geolocator.getCurrentPosition();
  }
}

final locationService = LocationService();
