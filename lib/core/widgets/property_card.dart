// Tarjeta de propiedad.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/features/properties/data/properties.dart';
import 'package:xatruch_realstate/features/properties/ui/property_detail_screen.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/widgets/property_card/property_image_carousel.dart';
import 'package:xatruch_realstate/core/widgets/property_card/property_action_menu.dart';
import 'package:xatruch_realstate/core/widgets/property_card/property_favorite_button.dart';
import 'package:xatruch_realstate/core/widgets/property_card/property_price_tag.dart';
import 'package:xatruch_realstate/core/widgets/property_card/property_details.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard({
    super.key,
    required this.property,
    this.onFavoriteToggle,
  });

  final Property property;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (context) => PropertyDetailScreen(property: property),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 24),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Carrusel de multimedia y superposiciones
              Stack(
                children: [
                  PropertyImageCarousel(property: property),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: PropertyFavoriteButton(propertyId: property.id),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: PropertyPriceTag(price: property.price),
                  ),
                  // Menú de acciones (Editar/Eliminar)
                  if (property.sellerId == authService.currentUser?.uid)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: PropertyActionMenu(property: property),
                    ),
                ],
              ),
              PropertyDetails(property: property),
            ],
          ),
        ),
      ),
    );
  }
}
