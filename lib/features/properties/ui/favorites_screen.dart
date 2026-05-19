// Pantalla de favoritos: muestra las propiedades marcadas como
// favoritas por el usuario actual.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/features/properties/data/properties.dart';
import 'package:xatruch_realstate/core/services/favorite_service.dart';
import 'package:xatruch_realstate/core/services/property_service.dart';
import 'package:xatruch_realstate/core/widgets/property_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: StreamBuilder<Set<String>>(
        stream: favoriteService.getFavoriteIds(),
        builder: (context, favSnapshot) {
          if (favSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteIds = favSnapshot.data ?? {};

          if (favoriteIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Todavia no hay favoritos...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return StreamBuilder<List<Property>>(
            stream: propertyService.getProperties(),
            builder: (context, propsSnapshot) {
              if (propsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allProperties = propsSnapshot.data ?? [];
              final favoriteProperties = allProperties
                  .where((p) => favoriteIds.contains(p.id))
                  .toList();

              // Marcarlos como favorito para la UI
              for (var p in favoriteProperties) {
                p.isFavorite = true;
              }

              if (favoriteProperties.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Todavia no hay favoritos...',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteProperties.length,
                itemBuilder: (context, index) {
                  return PropertyCard(
                    property: favoriteProperties[index],
                    onFavoriteToggle: () {
                      favoriteService.toggleFavorite(
                        favoriteProperties[index].id,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
