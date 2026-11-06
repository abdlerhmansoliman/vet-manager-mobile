import 'package:equatable/equatable.dart';
import '../../domain/entities/diagnostic_image_entity.dart';

abstract class MediaState extends Equatable {
  final List<DiagnosticImageEntity> images;
  final bool isUploading;
  final double uploadProgress;

  const MediaState({
    this.images = const [],
    this.isUploading = false,
    this.uploadProgress = 0.0,
  });

  @override
  List<Object?> get props => [images, isUploading, uploadProgress];
}

class MediaInitial extends MediaState {
  const MediaInitial();
}

class MediaLoading extends MediaState {
  const MediaLoading({
    super.images,
  });
}

class MediaUploading extends MediaState {
  final String? uploadingTitle;

  const MediaUploading({
    super.images,
    super.uploadProgress,
    this.uploadingTitle,
  }) : super(isUploading: true);

  @override
  List<Object?> get props => [images, isUploading, uploadProgress, uploadingTitle];
}

class MediaLoaded extends MediaState {
  const MediaLoaded({
    super.images,
    super.isUploading = false,
    super.uploadProgress = 0.0,
  });
}

class MediaOperationSuccess extends MediaState {
  final String message;
  final DiagnosticImageEntity? attachedImage;

  const MediaOperationSuccess({
    required this.message,
    this.attachedImage,
    super.images,
  });

  @override
  List<Object?> get props => [message, attachedImage, images];
}

class MediaFailure extends MediaState {
  final String message;

  const MediaFailure({
    required this.message,
    super.images,
  });

  @override
  List<Object?> get props => [message, images];
}
