import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../bloc/media_bloc.dart';
import '../bloc/media_event.dart';
import '../bloc/media_state.dart';

/// Modal bottom sheet for capturing or selecting diagnostic radiographs and clinical encounter photos.
class CameraCaptureSheet extends StatefulWidget {
  final String imageableType;
  final String imageableId;
  final ImagePicker? imagePicker;

  const CameraCaptureSheet({
    super.key,
    required this.imageableType,
    required this.imageableId,
    this.imagePicker,
  });

  @override
  State<CameraCaptureSheet> createState() => _CameraCaptureSheetState();
}

class _CameraCaptureSheetState extends State<CameraCaptureSheet> {
  late final ImagePicker _picker;
  final TextEditingController _titleController = TextEditingController();
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _picker = widget.imagePicker ?? ImagePicker();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );
      if (picked != null) {
        setState(() {
          _selectedFile = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Unable to access camera or photo library.');
      }
    }
  }

  void _onUploadPressed() {
    if (_selectedFile == null) return;

    context.read<MediaBloc>().add(
          UploadMediaRequested(
            imageableType: widget.imageableType,
            imageableId: widget.imageableId,
            sourceFilePath: _selectedFile!.path,
            title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MediaBloc, MediaState>(
      listener: (context, state) {
        if (state is MediaOperationSuccess) {
          Navigator.of(context).pop();
          AppSnackbar.showSuccess(context, state.message);
        } else if (state is MediaFailure) {
          AppSnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isUploading = state.isUploading;
        final progress = state.uploadProgress;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.borderWarm,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryEmerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_a_photo_rounded,
                        color: AppColors.primaryEmerald,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Attach Diagnostic Media',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textCharcoal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      onPressed: isUploading ? null : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Source selection buttons if no photo selected yet
                if (_selectedFile == null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('camera_source_button'),
                          onPressed: isUploading ? null : () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_rounded),
                          label: const Text('Camera'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryEmerald,
                            side: const BorderSide(color: AppColors.primaryEmerald),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('gallery_source_button'),
                          onPressed: isUploading ? null : () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_rounded),
                          label: const Text('Gallery'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryEmerald,
                            side: const BorderSide(color: AppColors.borderWarm),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  // Image preview card
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          _selectedFile!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (!isUploading)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            radius: 16,
                            child: IconButton(
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                              onPressed: () {
                                setState(() {
                                  _selectedFile = null;
                                });
                              },
                              tooltip: 'Retake photo',
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title / Clinical Caption input
                  TextField(
                    key: const Key('media_title_field'),
                    controller: _titleController,
                    enabled: !isUploading,
                    decoration: InputDecoration(
                      labelText: 'Image Caption / Clinical Label (Optional)',
                      hintText: 'e.g. Right lateral thorax, Day 3 post-op',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.label_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Upload progress indicator if in flight
                if (isUploading) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Compressing & streaming to cloud...',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryEmerald,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      key: const Key('media_upload_progress_bar'),
                      value: progress > 0 ? progress : null,
                      backgroundColor: AppColors.borderWarm,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryEmerald),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Inline error notice if upload operation encountered a problem
                if (state is MediaFailure) ...[
                  Container(
                    key: const Key('media_upload_error_banner'),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.badgeCriticalRose,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.badgeCriticalRoseText,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.message,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.badgeCriticalRoseText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Action button
                ElevatedButton.icon(
                  key: const Key('submit_media_upload_button'),
                  onPressed: (_selectedFile != null && !isUploading) ? _onUploadPressed : null,
                  icon: isUploading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.cloud_upload_rounded),
                  label: Text(isUploading ? 'Uploading...' : 'Save & Attach to Case'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
