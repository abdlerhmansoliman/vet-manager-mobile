import 'dart:io';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/diagnostic_image_entity.dart';
import '../../domain/repositories/media_repository.dart';
import '../services/image_compression_service.dart';
import '../services/r2_direct_uploader.dart';

/// Concrete repository coordinating image compression, direct R2 cloud storage, and Drift persistence.
class MediaRepositoryImpl implements IMediaRepository {
  final ImageCompressionService _compressionService;
  final R2DirectUploader _uploader;
  final AppDatabase _db;
  final ISecureStorageService _storageService;
  final Uuid _uuid;

  MediaRepositoryImpl({
    ImageCompressionService? compressionService,
    R2DirectUploader? uploader,
    required AppDatabase db,
    ISecureStorageService? storageService,
    Uuid? uuid,
  })  : _compressionService = compressionService ?? ImageCompressionService(),
        _uploader = uploader ?? R2DirectUploader(),
        _db = db,
        _storageService = storageService ?? SecureStorageService(),
        _uuid = uuid ?? const Uuid();

  @override
  Future<DiagnosticImageEntity> captureAndUploadImage({
    required String imageableType,
    required String imageableId,
    required String sourceFilePath,
    String? title,
    String? tenantId,
    void Function(double progress)? onProgress,
  }) async {
    final imageId = _uuid.v7();
    final effectiveTenantId = tenantId ?? await _storageService.getTenantId() ?? 'default';
    final now = DateTime.now();

    // 1. Optimize raw photo into WebP with checksum verification
    final compressed = await _compressionService.compressImage(
      sourceFile: File(sourceFilePath),
    );

    // 2. Register entry into local Drift SQLite upload queue
    await _db.into(_db.mediaUploadQueueTable).insert(
          MediaUploadQueueTableCompanion.insert(
            id: imageId,
            tenantId: effectiveTenantId,
            caseId: Value(imageableType == 'clinical_case' ? imageableId : null),
            patientId: Value(imageableType == 'patient' ? imageableId : null),
            localFilePath: compressed.file.path,
            mimeType: Value(compressed.mimeType),
            fileSizeBytes: compressed.fileSizeBytes,
            checksumSha256: compressed.checksumSha256,
            title: Value(title),
            status: const Value('uploading'),
            createdAt: now,
          ),
        );

    // 3. Attempt direct cloud upload stream
    try {
      final remotePath = 'media/$effectiveTenantId/${imageableType}s/$imageableId/$imageId.webp';
      final remoteUrl = await _uploader.uploadFile(
        file: compressed.file,
        remotePath: remotePath,
        mimeType: compressed.mimeType,
        tenantId: effectiveTenantId,
        checksumSha256: compressed.checksumSha256,
        onProgress: onProgress,
      );

      // 4. Mark completed in local database
      await (_db.update(_db.mediaUploadQueueTable)..where((t) => t.id.equals(imageId))).write(
        MediaUploadQueueTableCompanion(
          remoteUrl: Value(remoteUrl),
          status: const Value('completed'),
          uploadedAt: Value(DateTime.now()),
        ),
      );

      return DiagnosticImageEntity(
        id: imageId,
        imageableType: imageableType,
        imageableId: imageableId,
        url: remoteUrl,
        localPath: compressed.file.path,
        title: title,
        mimeType: compressed.mimeType,
        fileSizeBytes: compressed.fileSizeBytes,
        createdAt: now,
      );
    } catch (e) {
      // Offline fallback: Keep local file referenced, mark pending in queue for background sync
      await (_db.update(_db.mediaUploadQueueTable)..where((t) => t.id.equals(imageId))).write(
        MediaUploadQueueTableCompanion(
          status: const Value('pending'),
          errorMessage: Value(e.toString()),
        ),
      );

      return DiagnosticImageEntity(
        id: imageId,
        imageableType: imageableType,
        imageableId: imageableId,
        url: compressed.file.path,
        localPath: compressed.file.path,
        title: title,
        mimeType: compressed.mimeType,
        fileSizeBytes: compressed.fileSizeBytes,
        createdAt: now,
      );
    }
  }

  @override
  Future<List<DiagnosticImageEntity>> getImagesForCase(String caseId) async {
    final records = await (_db.select(_db.mediaUploadQueueTable)
          ..where((t) => t.caseId.equals(caseId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .get();

    return records.map(_mapQueueDataToEntity).toList();
  }

  @override
  Future<List<DiagnosticImageEntity>> getImagesForPatient(String patientId) async {
    final records = await (_db.select(_db.mediaUploadQueueTable)
          ..where((t) => t.patientId.equals(patientId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .get();

    return records.map(_mapQueueDataToEntity).toList();
  }

  @override
  Future<void> deleteImage(String imageId) async {
    await (_db.delete(_db.mediaUploadQueueTable)..where((t) => t.id.equals(imageId))).go();
  }

  @override
  Future<int> retryPendingUploads() async {
    final pending = await (_db.select(_db.mediaUploadQueueTable)
          ..where((t) => t.status.equals('pending') | t.status.equals('failed')))
        .get();

    var succeeded = 0;
    for (final item in pending) {
      final file = File(item.localFilePath);
      if (!await file.exists()) continue;

      try {
        final entityType = item.caseId != null ? 'clinical_cases' : 'patients';
        final entityId = item.caseId ?? item.patientId ?? 'generic';
        final remotePath = 'media/${item.tenantId}/$entityType/$entityId/${item.id}.webp';

        final remoteUrl = await _uploader.uploadFile(
          file: file,
          remotePath: remotePath,
          mimeType: item.mimeType,
          tenantId: item.tenantId,
          checksumSha256: item.checksumSha256,
        );

        await (_db.update(_db.mediaUploadQueueTable)..where((t) => t.id.equals(item.id))).write(
          MediaUploadQueueTableCompanion(
            remoteUrl: Value(remoteUrl),
            status: const Value('completed'),
            uploadedAt: Value(DateTime.now()),
          ),
        );
        succeeded++;
      } catch (_) {
        // Will be retried on next sync pass
      }
    }
    return succeeded;
  }

  DiagnosticImageEntity _mapQueueDataToEntity(MediaUploadQueueData data) {
    return DiagnosticImageEntity(
      id: data.id,
      imageableType: data.caseId != null ? 'clinical_case' : 'patient',
      imageableId: data.caseId ?? data.patientId ?? '',
      url: data.remoteUrl ?? data.localFilePath,
      localPath: data.localFilePath,
      title: data.title,
      mimeType: data.mimeType,
      fileSizeBytes: data.fileSizeBytes,
      createdAt: data.createdAt,
    );
  }
}
