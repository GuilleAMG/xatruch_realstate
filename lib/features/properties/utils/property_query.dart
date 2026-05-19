// Utilidades de consulta de propiedades: funciones para filtrar,
// ordenar por distancia y aplicar criterios de busqueda.
import 'package:geolocator/geolocator.dart';
import 'package:xatruch_realstate/features/properties/data/properties.dart';
import 'package:xatruch_realstate/features/properties/ui/widgets/filter_modal.dart';

class PropertyQuery {
  static List<Property> applyFilters(
    List<Property> properties, {
    required String searchQuery,
    required PropertyFilters filters,
  }) {
    return properties.where((property) {
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchTitle = property.title.toLowerCase().contains(query);
        final matchLocation = property.location.toLowerCase().contains(query) ||
            property.municipality.toLowerCase().contains(query);
        if (!matchTitle && !matchLocation) {
          return false;
        }
      }

      if (filters.department != null && filters.department!.isNotEmpty) {
        if (property.department != filters.department) {
          return false;
        }
      }
      if (filters.propertyType != null && filters.propertyType!.isNotEmpty) {
        if (property.propertyType != filters.propertyType) {
          return false;
        }
      }
      if (filters.minPrice != null && property.price < filters.minPrice!) {
        return false;
      }
      if (filters.maxPrice != null && property.price > filters.maxPrice!) {
        return false;
      }
      if (filters.minBedrooms != null && property.bedrooms < filters.minBedrooms!) {
        return false;
      }
      if (filters.minBathrooms != null && property.bathrooms < filters.minBathrooms!) {
        return false;
      }
      if (filters.reqElectricity && !property.hasElectricity) {
        return false;
      }
      if (filters.reqWater && !property.hasWater) {
        return false;
      }

      return true;
    }).toList();
  }

  static List<Property> applySort(
    List<Property> properties, {
    required bool sortByDistance,
    required Position? currentPosition,
  }) {
    final sorted = List<Property>.from(properties);

    if (sortByDistance && currentPosition != null) {
      sorted.sort((left, right) {
        if (left.latitude == null || left.longitude == null) {
          return 1;
        }
        if (right.latitude == null || right.longitude == null) {
          return -1;
        }

        final leftDistance = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          left.latitude!,
          left.longitude!,
        );
        final rightDistance = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          right.latitude!,
          right.longitude!,
        );

        return leftDistance.compareTo(rightDistance);
      });
    }

    return sorted;
  }
}