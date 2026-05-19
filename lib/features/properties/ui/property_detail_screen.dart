// Pantalla de detalle de propiedad: muestra toda la informacion
// de una propiedad incluyendo multimedia, mapa y vendedor.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/core/widgets/report_dialog.dart';
import 'package:xatruch_realstate/features/properties/data/properties.dart';
import 'package:xatruch_realstate/features/properties/ui/widgets/property_media_carousel.dart';
import 'package:xatruch_realstate/features/properties/ui/widgets/seller_info_section.dart';
import 'package:xatruch_realstate/features/properties/ui/widgets/property_map_section.dart';
import 'package:xatruch_realstate/features/properties/ui/widgets/property_features_row.dart';
import 'package:xatruch_realstate/core/utils/responsive_utils.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';
import 'package:xatruch_realstate/core/services/chat_service.dart';
import 'package:xatruch_realstate/core/services/user_service.dart';
import 'package:xatruch_realstate/features/chat/ui/chat_room_screen.dart';

class PropertyDetailScreen extends StatelessWidget {
  const PropertyDetailScreen({super.key, required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(property.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.report_problem_outlined),
            tooltip: 'Reportar Propiedad',
            onPressed: () {
              ReportDialog.show(
                context,
                reportedId: property.id,
                reportedUserId: property.sellerId,
                reportType: 'property',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PropertyMediaCarousel(property: property),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.location,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'L. ${property.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: context.scaledFontSize(20),
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  SellerInfoSection(
                    sellerId: property.sellerId,
                    sellerName: property.sellerName,
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 12),

                  // ── Map Section ──
                  if (property.latitude != null &&
                      property.latitude != 0 &&
                      property.longitude != null &&
                      property.longitude != 0) ...[
                    PropertyMapSection(
                      latitude: property.latitude!,
                      longitude: property.longitude!,
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                  ],

                  Text(property.description),
                  const SizedBox(height: 16),
                  PropertyFeaturesRow(
                    bedrooms: property.bedrooms,
                    bathrooms: property.bathrooms,
                    area: property.area,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: (property.sellerId != authService.currentUser?.uid)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (property.sellerId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error: El vendedor no tiene un ID válido.'),
                        ),
                      );
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Contactando a ${property.sellerName}...'),
                        duration: const Duration(seconds: 1),
                      ),
                    );

                    try {
                      final sellerData =
                          await userService.getUsuarioById(property.sellerId);
                      final String sellerName =
                          (sellerData?['nombre'] as String?) ??
                              property.sellerName;
                      final String sellerAvatar =
                          (sellerData?['photoUrl'] as String?) ??
                              'assets/icons/default_avatar.png';

                      final chatId = await chatService.getOrCreateChatRoom(
                        property.sellerId,
                        sellerName,
                        otherUserAvatar: sellerAvatar,
                      );

                      if (context.mounted) {
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => ChatRoomScreen(
                              chatId: chatId,
                              otherUserName: sellerName,
                              otherUserAvatar: sellerAvatar,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al crear chat: $e'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.message_outlined),
                  label: Text(
                    context.isSmallPhone ? 'Contactar' : 'Contactar Vendedor',
                    style: TextStyle(fontSize: context.scaledFontSize(14)),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: context.isSmallPhone ? 12 : 16,
                    ),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
