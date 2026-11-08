import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../domain/entities/diagnostic_image_entity.dart';
import '../../domain/repositories/media_repository.dart';
import '../bloc/media_bloc.dart';
import '../bloc/media_event.dart';
import '../bloc/media_state.dart';
import '../screens/photo_viewer_screen.dart';
import 'camera_capture_sheet.dart';

class _InMemoryMediaRepository implements IMediaRepository {
  final List<DiagnosticImageEntity> _images = [];

  _InMemoryMediaRepository();

  @override
  Future<DiagnosticImageEntity> captureAndUploadImage({
    required String imageableType,
    required String imageableId,
    required String sourceFilePath,
    String? title,
    String? tenantId,
    void Function(double progress)? onProgress,
  }) async {
    final image = DiagnosticImageEntity(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      imageableType: imageableType,
      imageableId: imageableId,
      url: sourceFilePath,
      localPath: sourceFilePath,
      title: title,
      mimeType: 'image/jpeg',
      fileSizeBytes: File(sourceFilePath).existsSync() ? File(sourceFilePath).lengthSync() : 0,
      createdAt: DateTime.now(),
    );
    _images.insert(0, image);
    return image;
  }

  @override
  Future<List<DiagnosticImageEntity>> getImagesForCase(String caseId) async =>
      _images.where((img) => img.imageableType == 'clinical_case' && img.imageableId == caseId).toList();

  @override
  Future<List<DiagnosticImageEntity>> getImagesForPatient(String patientId) async =>
      _images.where((img) => img.imageableType == 'patient' && img.imageableId == patientId).toList();

  @override
  Future<void> deleteImage(String imageId) async {
    _images.removeWhere((img) => img.id == imageId);
  }

  @override
  Future<int> retryPendingUploads() async => 0;
}

/// Clinical gallery widget displaying diagnostic radiographs, ultrasounds, and wound progression images.
class DiagnosticMediaGallery extends StatefulWidget {
  final String imageableType;
  final String imageableId;
  final IMediaRepository? repository;
  final MediaBloc? bloc;

  const DiagnosticMediaGallery({
    super.key,
    required this.imageableType,
    required this.imageableId,
    this.repository,
    this.bloc,
  });

  @override
  State<DiagnosticMediaGallery> createState() => _DiagnosticMediaGalleryState();
}

class _DiagnosticMediaGalleryState extends State<DiagnosticMediaGallery> {
  MediaBloc? _localBloc;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      if (widget.bloc == null) {
        IMediaRepository? repo = widget.repository;
        if (repo == null) {
          try {
            repo = RepositoryProvider.of<IMediaRepository>(context);
          } catch (_) {}
        }
        repo ??= _InMemoryMediaRepository();
        _localBloc = MediaBloc(repository: repo);
        if (widget.imageableType == 'clinical_case') {
          _localBloc!.add(LoadCaseMediaRequested(widget.imageableId));
        } else {
          _localBloc!.add(LoadPatientMediaRequested(widget.imageableId));
        }
      }
    }
  }

  @override
  void dispose() {
    _localBloc?.close();
    super.dispose();
  }

  MediaBloc _getBloc() {
    return widget.bloc ?? _localBloc!;
  }

  void _openCaptureSheet(BuildContext context) {
    final bloc = _getBloc();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<MediaBloc>.value(
        value: bloc,
        child: CameraCaptureSheet(
          imageableType: widget.imageableType,
          imageableId: widget.imageableId,
        ),
      ),
    );
  }

  void _openPhotoViewer(BuildContext context, DiagnosticImageEntity image) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PhotoViewerScreen(image: image),
      ),
    );
  }

  void _confirmDelete(BuildContext context, DiagnosticImageEntity image) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Diagnostic Image?'),
        content: Text('Are you sure you want to remove "${image.title ?? 'this image'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryCoral),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _getBloc().add(DeleteMediaRequested(image.id));
            },
            child: const Text('Delete Image', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = _getBloc();
    return BlocProvider<MediaBloc>.value(
      value: bloc,
      child: Builder(
        builder: (innerContext) => _buildGalleryContent(innerContext),
      ),
    );
  }

  Widget _buildGalleryContent(BuildContext context) {
    return BlocBuilder<MediaBloc, MediaState>(
      builder: (context, state) {
        final images = state.images;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderWarm),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryEmerald.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.perm_media_rounded,
                          color: AppColors.primaryEmerald,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Diagnostic Media & X-Rays',
                        style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    key: const Key('add_diagnostic_media_button'),
                    onPressed: () => _openCaptureSheet(context),
                    icon: const Icon(Icons.add_a_photo_rounded, size: 16),
                    label: const Text('Add Photo'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryEmerald,
                      textStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Image list or empty state
              if (state is MediaLoading && images.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryEmerald),
                    ),
                  ),
                )
              else if (images.isEmpty)
                InkWell(
                  onTap: () => _openCaptureSheet(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderWarm, style: BorderStyle.solid),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.camera_alt_outlined, color: AppColors.textMuted, size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'No radiographs or clinical photos attached yet',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to photograph wound, X-ray, or ultrasound',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primaryEmerald,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = images[index];
                      return _buildThumbnailItem(context, item);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThumbnailItem(BuildContext context, DiagnosticImageEntity item) {
    return InkWell(
      onTap: () => _openPhotoViewer(context, item),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderWarm),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Image
            Positioned.fill(
              child: item.isLocalOnly && item.localPath != null
                  ? Image.file(
                      File(item.localPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : item.url.startsWith('file:') || item.url.startsWith('/')
                      ? Image.file(
                          File(item.url.replaceFirst('file://', '')),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : CachedNetworkImage(
                          imageUrl: item.url,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.backgroundCream,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryEmerald),
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => _buildPlaceholder(),
                        ),
            ),

            // Delete icon button
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _confirmDelete(context, item),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),

            // Gradient shadow and title label
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title?.trim().isNotEmpty == true ? item.title! : 'X-Ray / Photo',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.formattedSize,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.backgroundCream,
      child: const Center(
        child: Icon(Icons.broken_image_rounded, color: AppColors.textMuted),
      ),
    );
  }
}
