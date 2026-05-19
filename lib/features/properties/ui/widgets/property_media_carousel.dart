// Carrusel multimedia de propiedad: muestra imagenes y videos
// en un PageView con indicadores y controles de reproduccion.
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:xatruch_realstate/features/properties/data/properties.dart';

/// Carrusel multimedia de ancho completo que muestra imágenes y videos de propiedad
/// en un [PageView] con indicadores de puntos y controles de reproducción/pausa de video.
class PropertyMediaCarousel extends StatefulWidget {
  const PropertyMediaCarousel({super.key, required this.property});
  final Property property;

  @override
  State<PropertyMediaCarousel> createState() => _PropertyMediaCarouselState();
}

class _PropertyMediaCarouselState extends State<PropertyMediaCarousel> {
  final List<VideoPlayerController> _videoControllers = [];
  late final List<Map<String, String>> _media;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _media = [];
    for (final img in widget.property.imageUrls) {
      _media.add({'type': 'image', 'url': img});
    }
    for (final vid in widget.property.videoUrls) {
      _media.add({'type': 'video', 'url': vid});
      final controller = VideoPlayerController.networkUrl(Uri.parse(vid))
        ..initialize().then((_) => setState(() {}));
      _videoControllers.add(controller);
    }
  }

  @override
  void dispose() {
    for (final c in _videoControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _buildMediaItem(int index) {
    final item = _media[index];
    if (item['type'] == 'image') {
      return Hero(
        tag:
            'property-image-${widget.property.id}${index == 0 ? '' : '-$index'}',
        child: Image.network(
          item['url']!,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 300,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      );
    }

    final vidIndex = widget.property.imageUrls.isNotEmpty
        ? index - widget.property.imageUrls.length
        : index;
    final controller = _videoControllers[vidIndex];
    if (!controller.value.isInitialized) {
      return Container(
        height: 300,
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(controller),
          Positioned(
            bottom: 12,
            right: 12,
            child: FloatingActionButton.small(
              backgroundColor: Colors.black54,
              onPressed: () {
                setState(() {
                  controller.value.isPlaying
                      ? controller.pause()
                      : controller.play();
                });
              },
              child: Icon(
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: _media.isEmpty ? 1 : _media.length,
            onPageChanged: (p) {
              setState(() {
                _currentPage = p;
                for (final c in _videoControllers) {
                  if (c.value.isPlaying) c.pause();
                }
                if (_media.isNotEmpty && _media[p]['type'] == 'video') {
                  final vidIndex = p - widget.property.imageUrls.length;
                  if (vidIndex >= 0 && vidIndex < _videoControllers.length) {
                    final c = _videoControllers[vidIndex];
                    if (c.value.isInitialized) c.play();
                  }
                }
              });
            },
            itemBuilder: (context, index) {
              if (_media.isEmpty) {
                return Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Icon(
                      Icons.home,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return _buildMediaItem(index);
            },
          ),
        ),
        if (_media.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _media.length,
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
