import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../domain/entities/diagnostic_image_entity.dart';

enum RadiographFilterMode {
  normal('Standard'),
  invert('Invert (Film)'),
  highContrast('High Contrast');

  final String label;
  const RadiographFilterMode(this.label);
}

/// Full-screen high-resolution radiograph and diagnostic image viewer.
///
/// Features up to 5x multi-touch pinch-to-zoom, negative film luminance inversion,
/// and high-contrast edge enhancement for bone/fracture inspection.
class PhotoViewerScreen extends StatefulWidget {
  final DiagnosticImageEntity image;

  const PhotoViewerScreen({
    super.key,
    required this.image,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  RadiographFilterMode _filterMode = RadiographFilterMode.normal;
  late final PhotoViewController _photoViewController;

  // Negative film color matrix for radiographic inversion
  static const List<double> _invertMatrix = [
    -1.0, 0, 0, 0, 255,
    0, -1.0, 0, 0, 255,
    0, 0, -1.0, 0, 255,
    0, 0, 0, 1.0, 0,
  ];

  // High contrast enhancement matrix
  static const List<double> _highContrastMatrix = [
    1.6, 0, 0, 0, -60,
    0, 1.6, 0, 0, -60,
    0, 0, 1.6, 0, -60,
    0, 0, 0, 1.0, 0,
  ];

  @override
  void initState() {
    super.initState();
    _photoViewController = PhotoViewController();
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    super.dispose();
  }

  ImageProvider _getImageProvider() {
    if (widget.image.isLocalOnly && widget.image.localPath != null) {
      return FileImage(File(widget.image.localPath!));
    }
    if (widget.image.url.startsWith('file:') || widget.image.url.startsWith('/')) {
      return FileImage(File(widget.image.url.replaceFirst('file://', '')));
    }
    if (widget.image.url.isNotEmpty && widget.image.url.startsWith('http')) {
      return CachedNetworkImageProvider(widget.image.url);
    }
    if (widget.image.localPath != null) {
      return FileImage(File(widget.image.localPath!));
    }
    return const AssetImage('assets/images/placeholder.png');
  }

  Widget _applyFilter(Widget child) {
    switch (_filterMode) {
      case RadiographFilterMode.invert:
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix(_invertMatrix),
          child: child,
        );
      case RadiographFilterMode.highContrast:
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix(_highContrastMatrix),
          child: child,
        );
      case RadiographFilterMode.normal:
        return child;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _getImageProvider();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.85),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.image.title?.trim().isNotEmpty == true
                  ? widget.image.title!
                  : 'Diagnostic Image',
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${widget.image.formattedFileSize} • ${widget.image.mimeType}',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<RadiographFilterMode>(
            key: const Key('radiograph_filter_menu_button'),
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
            tooltip: 'Radiograph Diagnostic Filters',
            onSelected: (mode) {
              setState(() => _filterMode = mode);
            },
            itemBuilder: (context) => RadiographFilterMode.values.map((mode) {
              final isSelected = mode == _filterMode;
              return PopupMenuItem<RadiographFilterMode>(
                value: mode,
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: isSelected ? AppColors.primaryEmerald : AppColors.textMuted,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      mode.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Interactive PhotoView with Zoom and Pan
          Positioned.fill(
            child: _applyFilter(
              PhotoView(
                controller: _photoViewController,
                imageProvider: imageProvider,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 5.0,
                initialScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(tag: widget.image.id),
                loadingBuilder: (context, event) => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryEmerald),
                  ),
                ),
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.broken_image_rounded, color: Colors.white54, size: 54),
                      const SizedBox(height: 12),
                      Text(
                        'Unable to render image',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Active filter indicator badge
          if (_filterMode != RadiographFilterMode.normal)
            Positioned(
              bottom: 24,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryEmerald, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.filter_vintage_rounded, color: AppColors.primaryEmerald, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _filterMode.label,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
