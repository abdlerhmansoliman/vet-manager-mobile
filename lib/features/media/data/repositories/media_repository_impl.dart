import 'dart:io';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/diagnostic_image_entity.dart';
import '../../domain/repositories/media_repository.dart';
import '../services/image_compression_service.dart';
import '../services/r2_direct_uploader.dart';

/// Concrete repository coordinating image compression, MinIO S3 backend storage, and Drift persistence.
class MediaRepositoryImpl implements IMediaRepository {
  final ImageCompressionService _compressionService;
  final R2DirectUploader _uploader;
  final ApiClient? _apiClient;
  final AppDatabase _db;
  final ISecureStorageService _storageService;
  final Uuid _uuid;

  MediaRepositoryImpl({
    ImageCompressionService? compressionService,
    R2DirectUploader? uploader,
    ApiClient? apiClient,
    required AppDatabase db,
    ISecureStorageService? storageService,
    Uuid? uuid,
  })  : _compressionService = compressionService ?? ImageCompressionService(),
        _uploader = uploader ?? R2DirectUploader(),
        _apiClient = apiClient,
        _db = db,
        _storageService = storageService ?? SecureStorageService(),
        _uuid = uuid ?? const Uuid();

  @override
  Future<DiagnosticImageEntity> captureAndUploadImage({
    required String imageableType,
    required String imageableId,
    required String sourceFilePath,
    String? parentCaseId,
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

    final isVisit = imageableType == 'visit';
    final isCase = imageableType == 'clinical_case' || imageableType == 'cases';

    // Resolve parent Case ID to authorize Presigned S3 upload for offline-generated visits
    String? resolvedCaseId = parentCaseId;
    if (resolvedCaseId == null && isVisit) {
      final visitRow = await (_db.select(_db.visitsTable)..where((t) => t.id.equals(imageableId))).getSingleOrNull();
      resolvedCaseId = visitRow?.caseId;
    } else if (isCase) {
      resolvedCaseId = imageableId;
    }

    // 2. Register entry into local Drift SQLite upload queue
    await _db.into(_db.mediaUploadQueueTable).insert(
          MediaUploadQueueTableCompanion.insert(
            id: imageId,
            tenantId: effectiveTenantId,
            caseId: Value(resolvedCaseId ?? (isCase ? imageableId : null)),
            visitId: Value(isVisit ? imageableId : null),
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

    // 3. Attempt direct upload to MinIO S3 via Presigned URL authorized by parent Case ID
    try {
      String remoteUrl = '';

      if (_apiClient != null && resolvedCaseId != null) {
        // Step A: Request Presigned URL from backend (authorized by case_id, handles offline visit_id)
        final presignedRes = await _apiClient.post<Map<String, dynamic>>(
          '/cases/$resolvedCaseId/media/presigned-url',
          data: {
            'filename': '$imageId.webp',
            'visit_id': isVisit ? imageableId : null,
            'content_type': compressed.mimeType,
            'title': title,
          },
        );

        final presignedData = presignedRes.data?['data'] as Map<String, dynamic>?;
        final uploadUrl = presignedData?['upload_url']?.toString();
        final fileUrl = presignedData?['file_url']?.toString();
        final headers = (presignedData?['headers'] as Map<String, dynamic>?) ?? {};

        if (uploadUrl != null && uploadUrl.isNotEmpty) {
          // Step B: Direct PUT stream to MinIO S3 using presigned URL
          await _uploader.uploadToPresignedUrl(
            file: compressed.file,
            presignedUrl: uploadUrl,
            mimeType: compressed.mimeType,
            extraHeaders: headers,
            onProgress: onProgress,
          );

          // Step C: Confirm upload with backend so Image metadata is registered in MySQL
          try {
            await _apiClient.post<Map<String, dynamic>>(
              '/cases/$resolvedCaseId/media/confirm',
              data: {
                'file_url': fileUrl ?? uploadUrl,
                'visit_id': isVisit ? imageableId : null,
                'image_id': imageId,
                'title': title,
                'file_size_bytes': compressed.fileSizeBytes,
                'mime_type': compressed.mimeType,
              },
            );
          } catch (_) {
            // Even if immediate confirmation fails, file is safely in MinIO S3 and queue tracks it
          }

          remoteUrl = fileUrl ?? uploadUrl;
        }
      }

      if (remoteUrl.isEmpty) {
        // Fallback direct upload if presigned url was not available
        final remotePath = 'media/$effectiveTenantId/${imageableType}s/$imageableId/$imageId.webp';
        remoteUrl = await _uploader.uploadFile(
          file: compressed.file,
          remotePath: remotePath,
          mimeType: compressed.mimeType,
          tenantId: effectiveTenantId,
          checksumSha256: compressed.checksumSha256,
          onProgress: onProgress,
        );
      }

      // 4. Mark completed in local database
      await (_db.update(_db.mediaUploadQueueTable)..where((t) => t.id.equals(imageId))).write(
        MediaUploadQueueTableCompanion(
          remoteUrl: Value(remoteUrl.isNotEmpty ? remoteUrl : null),
          status: const Value('completed'),
          uploadedAt: Value(DateTime.now()),
        ),
      );

      return DiagnosticImageEntity(
        id: imageId,
        imageableType: imageableType,
        imageableId: imageableId,
        url: remoteUrl.isNotEmpty ? remoteUrl : compressed.file.path,
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
  Future<List<DiagnosticImageEntity>> getImagesForVisit(String visitId) async {
    final records = await (_db.select(_db.mediaUploadQueueTable)
          ..where((t) => t.visitId.equals(visitId))
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
    final records = await (_db.select(_db.mediaUploadQueueTable)
          ..where((t) => t.id.equals(imageId)))
        .get();

    if (_apiClient != null && records.isNotEmpty) {
      try {
        await _apiClient.delete<void>('/images/$imageId');
      } catch (_) {
        // Tolerant if server is offline or record not on remote yet
      }
    }

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
        String remoteUrl = '';

        if (_apiClient != null) {
          final isVisit = item.visitId != null;
          final targetId = item.visitId ?? item.caseId ?? item.patientId ?? '';
          final endpoint = isVisit
              ? '/visits/$targetId/images'
              : '/cases/$targetId/images';

          final formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(
              file.path,
              filename: '${item.id}.webp',
            ),
            if (item.title != null && item.title!.isNotEmpty) 'title': item.title,
          });

          final response = await _apiClient.post<Map<String, dynamic>>(
            endpoint,
            data: formData,
          );

          final responseData = response.data;
          if (responseData != null && responseData['data'] != null) {
            final dataMap = responseData['data'] as Map<String, dynamic>;
            remoteUrl = dataMap['url']?.toString() ?? '';
          }
        } else {
          final entityType = item.visitId != null
              ? 'visits'
              : item.caseId != null
                  ? 'clinical_cases'
                  : 'patients';
          final entityId = item.visitId ?? item.caseId ?? item.patientId ?? 'generic';
          final remotePath = 'media/${item.tenantId}/$entityType/$entityId/${item.id}.webp';

          remoteUrl = await _uploader.uploadFile(
            file: file,
            remotePath: remotePath,
            mimeType: item.mimeType,
            tenantId: item.tenantId,
            checksumSha256: item.checksumSha256,
          );
        }

        await (_db.update(_db.mediaUploadQueueTable)..where((t) => t.id.equals(item.id))).write(
          MediaUploadQueueTableCompanion(
            remoteUrl: Value(remoteUrl.isNotEmpty ? remoteUrl : null),
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
      imageableType: data.visitId != null
          ? 'visit'
          : data.caseId != null
              ? 'clinical_case'
              : 'patient',
      imageableId: data.visitId ?? data.caseId ?? data.patientId ?? '',
      url: data.remoteUrl ?? data.localFilePath,
      localPath: data.localFilePath,
      title: data.title,
      mimeType: data.mimeType,
      fileSizeBytes: data.fileSizeBytes,
      createdAt: data.createdAt,
    );
  }
}
