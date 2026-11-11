import '../entities/diagnostic_image_entity.dart';

/// Repository interface for veterinary clinical media, radiographs, and ultrasound imaging.
abstract class IMediaRepository {
  /// Compresses, hashes, and uploads an image from a local file path, returning the persistent image entity.
  Future<DiagnosticImageEntity> captureAndUploadImage({
    required String imageableType,
    required String imageableId,
    required String sourceFilePath,
    String? parentCaseId,
    String? title,
    String? tenantId,
    void Function(double progress)? onProgress,
  });

  /// Retrieves diagnostic images associated with a clinical case/encounter.
  Future<List<DiagnosticImageEntity>> getImagesForCase(String caseId);

  /// Retrieves diagnostic images associated with a specific visit encounter.
  Future<List<DiagnosticImageEntity>> getImagesForVisit(String visitId);

  /// Retrieves diagnostic images associated with a patient file.
  Future<List<DiagnosticImageEntity>> getImagesForPatient(String patientId);

  /// Removes an image attachment.
  Future<void> deleteImage(String imageId);

  /// Retries any queued pending uploads that were saved while offline.
  Future<int> retryPendingUploads();
}
