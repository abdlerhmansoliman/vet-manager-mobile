import 'dart:ffi';
import 'dart:io';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/open.dart';
import 'package:vet_manager_mobile/core/errors/app_exceptions.dart';
import 'package:vet_manager_mobile/core/storage/secure_storage_service.dart';
import 'package:vet_manager_mobile/database/app_database.dart';
import 'package:vet_manager_mobile/features/media/data/repositories/media_repository_impl.dart';
import 'package:vet_manager_mobile/features/media/data/services/r2_direct_uploader.dart';

class MockR2DirectUploader extends Mock implements R2DirectUploader {}
class MockISecureStorageService extends Mock implements ISecureStorageService {}

void main() {
  late AppDatabase db;
  late MockR2DirectUploader mockUploader;
  late MockISecureStorageService mockStorage;
  late MediaRepositoryImpl repository;
  late Directory tempDir;
  late File sampleFile;

  setUpAll(() {
    open.overrideFor(OperatingSystem.linux, () => DynamicLibrary.open('libsqlite3.so.0'));
    registerFallbackValue(File(''));
  });

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mockUploader = MockR2DirectUploader();
    mockStorage = MockISecureStorageService();

    when(() => mockStorage.getTenantId()).thenAnswer((_) async => 'tenant-123');

    repository = MediaRepositoryImpl(
      db: db,
      uploader: mockUploader,
      storageService: mockStorage,
    );

    // Seed master records to satisfy foreign keys
    final now = DateTime.now();
    await db.into(db.clientsTable).insert(
          ClientsTableCompanion.insert(
            id: 'c-1',
            tenantId: 'tenant-123',
            name: 'John Doe',
            phonePrimary: '555-0100',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await db.into(db.patientsTable).insert(
          PatientsTableCompanion.insert(
            id: 'p-1',
            tenantId: 'tenant-123',
            clientId: 'c-1',
            nameOrTag: 'Max',
            species: 'Canine',
            createdAt: now,
            updatedAt: now,
          ),
        );

    for (final caseId in ['case-001', 'case-002', 'case-003', 'case-004']) {
      await db.into(db.clinicalCasesTable).insert(
            ClinicalCasesTableCompanion.insert(
              id: caseId,
              tenantId: 'tenant-123',
              caseNumber: 'CAS-$caseId',
              patientId: 'p-1',
              primaryVeterinarianId: 'vet-1',
              chiefComplaint: 'Radiology examination',
              priority: const Value('routine'),
              admittedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }

    tempDir = await Directory.systemTemp.createTemp('media_repo_test_');
    sampleFile = File('${tempDir.path}/test_film.jpg');
    await sampleFile.writeAsBytes([1, 2, 3, 4, 5, 6, 7, 8]);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('MediaRepositoryImpl', () {
    test('captureAndUploadImage persists record and marks completed on cloud upload success', () async {
      when(
        () => mockUploader.uploadFile(
          file: any(named: 'file'),
          remotePath: any(named: 'remotePath'),
          mimeType: any(named: 'mimeType'),
          tenantId: any(named: 'tenantId'),
          checksumSha256: any(named: 'checksumSha256'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async => 'https://storage.vetmanager.app/media/tenant-123/cases/case-001/img.webp');

      final result = await repository.captureAndUploadImage(
        imageableType: 'clinical_case',
        imageableId: 'case-001',
        sourceFilePath: sampleFile.path,
        title: 'Lateral Thoracic Radiograph',
      );

      expect(result.imageableId, equals('case-001'));
      expect(result.title, equals('Lateral Thoracic Radiograph'));
      expect(result.url, contains('storage.vetmanager.app'));

      final records = await db.select(db.mediaUploadQueueTable).get();
      expect(records.length, equals(1));
      expect(records.first.status, equals('completed'));
      expect(records.first.remoteUrl, contains('storage.vetmanager.app'));
    });

    test('captureAndUploadImage falls back seamlessly to pending offline status when network upload fails', () async {
      when(
        () => mockUploader.uploadFile(
          file: any(named: 'file'),
          remotePath: any(named: 'remotePath'),
          mimeType: any(named: 'mimeType'),
          tenantId: any(named: 'tenantId'),
          checksumSha256: any(named: 'checksumSha256'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenThrow(const NetworkException(message: 'Connection dropped while ambulatory in field.'));

      final result = await repository.captureAndUploadImage(
        imageableType: 'clinical_case',
        imageableId: 'case-002',
        sourceFilePath: sampleFile.path,
        title: 'Offline Field Capture',
      );

      expect(result.imageableId, equals('case-002'));
      expect(result.isLocalOnly, isTrue);

      final records = await db.select(db.mediaUploadQueueTable).get();
      expect(records.length, equals(1));
      expect(records.first.status, equals('pending'));
      expect(records.first.errorMessage, contains('Connection dropped'));
    });

    test('getImagesForCase retrieves items and deleteImage removes entry from Drift SQLite', () async {
      when(
        () => mockUploader.uploadFile(
          file: any(named: 'file'),
          remotePath: any(named: 'remotePath'),
          mimeType: any(named: 'mimeType'),
          tenantId: any(named: 'tenantId'),
          checksumSha256: any(named: 'checksumSha256'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async => 'https://storage.vetmanager.app/img.webp');

      final item = await repository.captureAndUploadImage(
        imageableType: 'clinical_case',
        imageableId: 'case-003',
        sourceFilePath: sampleFile.path,
        title: 'Right Forelimb AP',
      );

      final images = await repository.getImagesForCase('case-003');
      expect(images.length, equals(1));
      expect(images.first.id, equals(item.id));

      await repository.deleteImage(item.id);
      final afterDelete = await repository.getImagesForCase('case-003');
      expect(afterDelete, isEmpty);
    });

    test('retryPendingUploads uploads pending items and updates status to completed', () async {
      // First, simulate failed initial upload
      when(
        () => mockUploader.uploadFile(
          file: any(named: 'file'),
          remotePath: any(named: 'remotePath'),
          mimeType: any(named: 'mimeType'),
          tenantId: any(named: 'tenantId'),
          checksumSha256: any(named: 'checksumSha256'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenThrow(const NetworkException(message: 'Offline'));

      await repository.captureAndUploadImage(
        imageableType: 'clinical_case',
        imageableId: 'case-004',
        sourceFilePath: sampleFile.path,
        title: 'Ultrasound Bladder',
      );

      // Now mock successful retry
      when(
        () => mockUploader.uploadFile(
          file: any(named: 'file'),
          remotePath: any(named: 'remotePath'),
          mimeType: any(named: 'mimeType'),
          tenantId: any(named: 'tenantId'),
          checksumSha256: any(named: 'checksumSha256'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async => 'https://storage.vetmanager.app/retried.webp');

      final retriedCount = await repository.retryPendingUploads();
      expect(retriedCount, equals(1));

      final records = await db.select(db.mediaUploadQueueTable).get();
      expect(records.first.status, equals('completed'));
      expect(records.first.remoteUrl, equals('https://storage.vetmanager.app/retried.webp'));
    });
  });
}
