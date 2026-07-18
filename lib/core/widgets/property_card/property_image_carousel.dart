// Carrusel de imágenes de propiedad.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/features/properties/data/properties.dart';

class PropertyImageCarousel extends StatefulWidget {
  const PropertyImageCarousel({super.key, required this.property});
  final Property property;

  @override
  State<PropertyImageCarousel> createState() => _PropertyImageCarouselState();
}

class _PropertyImageCarouselState extends State<PropertyImageCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final mediaCount = widget.property.imageUrls.length;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: PageView.builder(
            itemCount: mediaCount > 0 ? mediaCount : 1,
            onPageChanged: (int index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final url = mediaCount > 0
                  ? widget.property.imageUrls[index]
                  : 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80';

              return Hero(
                tag:
                    'property-image-${widget.property.id}${index == 0 ? '' : '-$index'}',
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.error_outline, size: 40),
                    );
                  },
                ),
              );
            },
          ),
        ),
        // Indicadores
        if (mediaCount > 1)
          Positioned(
            bottom: 12,
            right: 0,
            left: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                mediaCount,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? colorScheme.primary
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}