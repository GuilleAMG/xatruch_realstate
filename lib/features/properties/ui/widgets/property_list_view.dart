// Vista de lista de propiedades: muestra el stream principal de propiedades
// con estados de error, carga y vacio, aplicando filtros y ordenamiento.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/features/properties/data/properties.dart';
import 'package:xatruch_realstate/features/properties/ui/create_property_screen.dart';
import 'package:xatruch_realstate/core/services/favorite_service.dart';
import 'package:xatruch_realstate/core/services/property_service.dart';
import 'package:xatruch_realstate/core/widgets/property_card.dart';
import 'package:xatruch_realstate/features/properties/ui/widgets/filter_modal.dart';
import 'package:geolocator/geolocator.dart';
import 'package:xatruch_realstate/utils/responsive.dart';
import 'package:xatruch_realstate/features/properties/utils/property_query.dart';

/// Muestra el stream principal de propiedades (con estados de error, carga y vacío),
/// aplica filtros y ordenamiento por distancia, y renderiza la lista de propiedades.
class PropertyListView extends StatelessWidget {
  const PropertyListView({
    super.key,
    required this.searchQuery,
    required this.filters,
    required this.sortByDistance,
    required this.currentPosition,
  });

  final String searchQuery;
  final PropertyFilters filters;
  final bool sortByDistance;
  final Position? currentPosition;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<Property>>(
      stream: propertyService.getProperties(),
      builder: (context, propertiesSnapshot) {
        // Estado de error
        if (propertiesSnapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar propiedades',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${propertiesSnapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          );
        }

        // Estado de carga
        if (propertiesSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final properties = propertiesSnapshot.data ?? [];

        // Estado vacío
        if (properties.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home_work_outlined, size: 80, color: colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    'No hay propiedades aún',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¡Sé el primero en publicar una propiedad!',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(builder: (context) => const CreatePropertyScreen()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Publicar Propiedad'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Lista de propiedades con superposición de favoritos
        return StreamBuilder<Set<String>>(
          stream: favoriteService.getFavoriteIds(),
          builder: (context, favSnapshot) {
            final favoriteIds = favSnapshot.data ?? {};

            for (var property in properties) {
              property.isFavorite = favoriteIds.contains(property.id);
            }

            final filteredProperties = PropertyQuery.applyFilters(
              properties,
              searchQuery: searchQuery,
              filters: filters,
            );
            final sortedProperties = PropertyQuery.applySort(
              filteredProperties,
              sortByDistance: sortByDistance,
              currentPosition: currentPosition,
            );

            if (isTablet(context)) {
              return GridView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.horizontal(context),
                  vertical: Spacing.vertical(context),
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: sortedProperties.length,
                itemBuilder: (context, index) {
                  return PropertyCard(
                    property: sortedProperties[index],
                    onFavoriteToggle: () {
                      favoriteService.toggleFavorite(sortedProperties[index].id);
                    },
                  );
                },
              );
            } else {
              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.horizontal(context),
                  vertical: Spacing.vertical(context),
                ),
                itemCount: sortedProperties.length,
                itemBuilder: (context, index) {
                  return PropertyCard(
                    property: sortedProperties[index],
                    onFavoriteToggle: () {
                      favoriteService.toggleFavorite(sortedProperties[index].id);
                    },
                  );
                },
              );
            }
          },
        );
      },
    );
  }

}
