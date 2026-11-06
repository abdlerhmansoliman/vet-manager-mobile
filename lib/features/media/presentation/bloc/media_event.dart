import 'package:equatable/equatable.dart';

abstract class MediaEvent extends Equatable {
  const MediaEvent();

  @override
  List<Object?> get props => [];
}

/// Request to load images attached to a clinical case.
class LoadCaseMediaRequested extends MediaEvent {
  final String caseId;

  const LoadCaseMediaRequested(this.caseId);

  @override
  List<Object?> get props => [caseId];
}

/// Request to load images attached to a patient file.
class LoadPatientMediaRequested extends MediaEvent {
  final String patientId;

  const LoadPatientMediaRequested(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

/// Request to capture, compress, and stream an image to object storage.
class UploadMediaRequested extends MediaEvent {
  final String imageableType;
  final String imageableId;
  final String sourceFilePath;
  final String? title;

  const UploadMediaRequested({
    required this.imageableType,
    required this.imageableId,
    required this.sourceFilePath,
    this.title,
  });

  @override
  List<Object?> get props => [imageableType, imageableId, sourceFilePath, title];
}

/// Real-time progress update during direct cloud upload.
class UploadProgressUpdated extends MediaEvent {
  final double progress;

  const UploadProgressUpdated(this.progress);

  @override
  List<Object?> get props => [progress];
}

/// Request to delete an attached image.
class DeleteMediaRequested extends MediaEvent {
  final String imageId;

  const DeleteMediaRequested(this.imageId);

  @override
  List<Object?> get props => [imageId];
}

/// Request to retry any queued offline uploads.
class RetryPendingUploadsRequested extends MediaEvent {
  const RetryPendingUploadsRequested();
}
