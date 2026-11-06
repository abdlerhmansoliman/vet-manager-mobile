import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/errors/clinical_error_formatter.dart';
import '../../domain/repositories/media_repository.dart';
import 'media_event.dart';
import 'media_state.dart';

class MediaBloc extends Bloc<MediaEvent, MediaState> {
  final IMediaRepository _repository;
  String? _currentCaseId;
  String? _currentPatientId;

  MediaBloc({
    required IMediaRepository repository,
  })  : _repository = repository,
        super(const MediaInitial()) {
    on<LoadCaseMediaRequested>(_onLoadCaseMedia);
    on<LoadPatientMediaRequested>(_onLoadPatientMedia);
    on<UploadMediaRequested>(_onUploadMedia);
    on<UploadProgressUpdated>(_onUploadProgressUpdated);
    on<DeleteMediaRequested>(_onDeleteMedia);
    on<RetryPendingUploadsRequested>(_onRetryPendingUploads);
  }

  Future<void> _onLoadCaseMedia(
    LoadCaseMediaRequested event,
    Emitter<MediaState> emit,
  ) async {
    _currentCaseId = event.caseId;
    emit(MediaLoading(images: state.images));

    try {
      final items = await _repository.getImagesForCase(event.caseId);
      emit(MediaLoaded(images: items));
    } on AppException catch (e) {
      emit(MediaFailure(
        message: ClinicalErrorFormatter.format(e),
        images: state.images,
      ));
    } catch (e) {
      emit(MediaFailure(
        message: ClinicalErrorFormatter.format(e, fallbackMessage: 'Failed to load case images.'),
        images: state.images,
      ));
    }
  }

  Future<void> _onLoadPatientMedia(
    LoadPatientMediaRequested event,
    Emitter<MediaState> emit,
  ) async {
    _currentPatientId = event.patientId;
    emit(MediaLoading(images: state.images));

    try {
      final items = await _repository.getImagesForPatient(event.patientId);
      emit(MediaLoaded(images: items));
    } on AppException catch (e) {
      emit(MediaFailure(
        message: ClinicalErrorFormatter.format(e),
        images: state.images,
      ));
    } catch (e) {
      emit(MediaFailure(
        message: ClinicalErrorFormatter.format(e, fallbackMessage: 'Failed to load patient images.'),
        images: state.images,
      ));
    }
  }

  Future<void> _onUploadMedia(
    UploadMediaRequested event,
    Emitter<MediaState> emit,
  ) async {
    emit(MediaUploading(
      images: state.images,
      uploadProgress: 0.05,
      uploadingTitle: event.title,
    ));

    try {
      final uploaded = await _repository.captureAndUploadImage(
        imageableType: event.imageableType,
        imageableId: event.imageableId,
        sourceFilePath: event.sourceFilePath,
        title: event.title,
        onProgress: (p) => add(UploadProgressUpdated(p)),
      );

      final updatedImages = [uploaded, ...state.images];
      emit(MediaOperationSuccess(
        message: 'Diagnostic image attached successfully.',
        attachedImage: uploaded,
        images: updatedImages,
      ));
      emit(MediaLoaded(images: updatedImages));
    } on AppException catch (e) {
      emit(MediaFailure(
        message: ClinicalErrorFormatter.format(e),
        images: state.images,
      ));
    } catch (e) {
      emit(MediaFailure(
        message: ClinicalErrorFormatter.format(e, fallbackMessage: 'Failed to upload diagnostic image.'),
        images: state.images,
      ));
    }
  }

  void _onUploadProgressUpdated(
    UploadProgressUpdated event,
    Emitter<MediaState> emit,
  ) {
    if (state is MediaUploading) {
      emit(MediaUploading(
        images: state.images,
        uploadProgress: event.progress.clamp(0.0, 1.0),
        uploadingTitle: (state as MediaUploading).uploadingTitle,
      ));
    }
  }

  Future<void> _onDeleteMedia(
    DeleteMediaRequested event,
    Emitter<MediaState> emit,
  ) async {
    try {
      await _repository.deleteImage(event.imageId);
      final updated = state.images.where((img) => img.id != event.imageId).toList();
      emit(MediaOperationSuccess(
        message: 'Image removed from case file.',
        images: updated,
      ));
      emit(MediaLoaded(images: updated));
    } on AppException catch (e) {
      emit(MediaFailure(
        message: ClinicalErrorFormatter.format(e),
        images: state.images,
      ));
    } catch (e) {
      emit(MediaFailure(
        message: ClinicalErrorFormatter.format(e, fallbackMessage: 'Failed to delete image.'),
        images: state.images,
      ));
    }
  }

  Future<void> _onRetryPendingUploads(
    RetryPendingUploadsRequested event,
    Emitter<MediaState> emit,
  ) async {
    try {
      final count = await _repository.retryPendingUploads();
      if (_currentCaseId != null) {
        add(LoadCaseMediaRequested(_currentCaseId!));
      } else if (_currentPatientId != null) {
        add(LoadPatientMediaRequested(_currentPatientId!));
      }
      if (count > 0) {
        emit(MediaOperationSuccess(
          message: '$count offline diagnostic images uploaded successfully.',
          images: state.images,
        ));
      }
    } catch (_) {}
  }
}
