import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:xatruch_realstate/features/properties/data/properties.dart';
import 'package:xatruch_realstate/features/properties/ui/widgets/filter_modal.dart';
import 'package:xatruch_realstate/features/properties/utils/property_query.dart';

Property buildProperty({
  required String id,
  required String title,
  required String location,
  required String municipality,
  String department = '',
  String propertyType = '',
  double price = 0,
  int bedrooms = 0,
  int bathrooms = 0,
  bool hasElectricity = false,
  bool hasWater = false,
  double? latitude,
  double? longitude,
}) {
  return Property(
    id: id,
    title: title,
    location: location,
    municipality: municipality,
    department: department,
    propertyType: propertyType,
    price: price,
    imageUrls: const [],
    description: 'desc',
    bedrooms: bedrooms,
    bathrooms: bathrooms,
    area: 100,
    sellerName: 'seller',
    hasElectricity: hasElectricity,
    hasWater: hasWater,
    latitude: latitude,
    longitude: longitude,
  );
}

void main() {
  group('PropertyQuery.applyFilters', () {
    final properties = [
      buildProperty(
        id: '1',
        title: 'Casa Centro',
        location: 'Tegucigalpa',
        municipality: 'Distrito Central',
        department: 'Francisco Morazan',
        propertyType: 'Casa',
        price: 100000,
        bedrooms: 3,
        bathrooms: 2,
        hasElectricity: true,
        hasWater: true,
      ),
      buildProperty(
        id: '2',
        title: 'Apartamento Playa',
        location: 'La Ceiba',
        municipality: 'La Ceiba',
        department: 'Atlantida',
        propertyType: 'Apartamento',
        price: 250000,
        bedrooms: 2,
        bathrooms: 1,
        hasElectricity: true,
        hasWater: false,
      ),
    ];

    test('matches by search query across title and location', () {
      final filters = PropertyFilters();

      final result = PropertyQuery.applyFilters(
        properties,
        searchQuery: 'playa',
        filters: filters,
      );

      expect(result.map((property) => property.id), ['2']);
    });

    test('applies combined advanced filters', () {
      final filters = PropertyFilters(
        department: 'Francisco Morazan',
        propertyType: 'Casa',
        minPrice: 90000,
        maxPrice: 150000,
        minBedrooms: 3,
        minBathrooms: 2,
        reqElectricity: true,
        reqWater: true,
      );

      final result = PropertyQuery.applyFilters(
        properties,
        searchQuery: '',
        filters: filters,
      );

      expect(result.map((property) => property.id), ['1']);
    });
  });

  group('PropertyQuery.applySort', () {
    test('sorts nearest properties first and pushes missing coordinates last', () {
      final properties = [
        buildProperty(
          id: 'far',
          title: 'Far',
          location: 'A',
          municipality: 'A',
          latitude: 14.2,
          longitude: -87.3,
        ),
        buildProperty(
          id: 'near',
          title: 'Near',
          location: 'B',
          municipality: 'B',
          latitude: 14.1,
          longitude: -87.21,
        ),
        buildProperty(
          id: 'unknown',
          title: 'Unknown',
          location: 'C',
          municipality: 'C',
        ),
      ];

      final currentPosition = Position(
        longitude: -87.2,
        latitude: 14.1,
        timestamp: DateTime(2026),
        accuracy: 1,
        altitude: 0,
        altitudeAccuracy: 1,
        heading: 0,
        headingAccuracy: 1,
        speed: 0,
        speedAccuracy: 1,
      );

      final result = PropertyQuery.applySort(
        properties,
        sortByDistance: true,
        currentPosition: currentPosition,
      );

      expect(result.map((property) => property.id), ['near', 'far', 'unknown']);
    });
  });
}