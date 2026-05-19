// Seccion de selector de multimedia: botones para seleccionar fotos
// y videos desde galeria o camara con vista previa.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Muestra los botones de selección de multimedia y miniaturas de vista previa.
/// Gestiona la selección desde galería, cámara y video mediante callbacks.
class MediaPickerSection extends StatelessWidget {
  const MediaPickerSection({
    super.key,
    required this.selectedMedia,
    required this.existingMediaUrls,
    required this.onPickImages,
    required this.onPickFromCamera,
    required this.onPickVideo,
    required this.onRemoveMedia,
    required this.onRemoveExistingMedia,
  });
  final List<XFile> selectedMedia;
  final List<String> existingMediaUrls;
  final VoidCallback onPickImages;
  final VoidCallback onPickFromCamera;
  final VoidCallback onPickVideo;
  final void Function(int) onRemoveMedia;
  final void Function(int) onRemoveExistingMedia;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fotos y Videos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildMediaAddButton(
                context,
                Icons.photo_library_outlined,
                'Galería',
                onPickImages,
              ),
              _buildMediaAddButton(
                context,
                Icons.camera_alt_outlined,
                'Cámara',
                onPickFromCamera,
              ),
              _buildMediaAddButton(
                context,
                Icons.videocam_outlined,
                'Video',
                onPickVideo,
              ),
              ...existingMediaUrls.asMap().entries.map((entry) {
                return _buildExistingMediaPreview(
                  context,
                  entry.key,
                  entry.value,
                );
              }),
              ...selectedMedia.asMap().entries.map((entry) {
                return _buildMediaPreview(context, entry.key, entry.value);
              }),
            ],
          ),
        ),
        if (selectedMedia.isNotEmpty || existingMediaUrls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${existingMediaUrls.length} existente(s), ${selectedMedia.length} nuevo(s)',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMediaAddButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingMediaPreview(
    BuildContext context,
    int index,
    String url,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Container(
          width: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
            image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 12,
          child: GestureDetector(
            onTap: () => onRemoveExistingMedia(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 16, color: colorScheme.onError),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPreview(BuildContext context, int index, XFile file) {
    final colorScheme = Theme.of(context).colorScheme;
    final isVideo =
        file.path.endsWith('.mp4') ||
        file.path.endsWith('.mov') ||
        file.path.endsWith('.avi');

    return Stack(
      children: [
        Container(
          width: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: isVideo
                ? null
                : DecorationImage(
                    image: FileImage(File(file.path)),
                    fit: BoxFit.cover,
                  ),
            color: isVideo ? colorScheme.surfaceContainerHighest : null,
          ),
          child: isVideo
              ? const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                )
              : null,
        ),
        Positioned(
          top: 4,
          right: 12,
          child: GestureDetector(
            onTap: () => onRemoveMedia(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 16, color: colorScheme.onError),
            ),
          ),
        ),
      ],
    );
  }
}
