import 'package:drift/drift.dart';
import 'clinical_cases_table.dart';
import 'patients_table.dart';

/// Drift SQLite Table for Queueing Diagnostic Images & Radiographs for Direct Cloudflare R2 Upload.
@DataClassName('MediaUploadQueueData')
class MediaUploadQueueTable extends Table {
  @override
  String get tableName => 'media_upload_queue';

  /// Primary UUID identifier
  TextColumn get id => text()();

  /// Practice tenant isolation identifier
  TextColumn get tenantId => text()();

  /// Optional association to clinical encounter
  TextColumn get caseId => text().nullable().references(ClinicalCasesTable, #id)();

  /// Optional association directly to patient record
  TextColumn get patientId => text().nullable().references(PatientsTable, #id)();

  /// Local cached device file path (WebP compressed artifact)
  TextColumn get localFilePath => text()();

  /// Cloudflare R2 public / presigned URL once uploaded
  TextColumn get remoteUrl => text().nullable()();

  /// Media MIME type: image/webp, image/jpeg, application/pdf
  TextColumn get mimeType => text().withDefault(const Constant('image/webp'))();

  /// Byte length for progress tracking and storage audits
  IntColumn get fileSizeBytes => integer()();

  /// SHA-256 cryptographic digest for payload integrity verification
  TextColumn get checksumSha256 => text().withLength(min: 64, max: 64)();

  /// Optional clinician description (e.g., "Right lateral abdominal radiograph")
  TextColumn get title => text().nullable().withLength(max: 191)();

  /// Processing state: pending, uploading, completed, failed
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// Number of retry attempts executed
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// Diagnostic error log from Cloudflare R2 or network failure
  TextColumn get errorMessage => text().nullable()();

  /// Queue entry timestamp
  DateTimeColumn get createdAt => dateTime()();

  /// Completion timestamp
  DateTimeColumn get uploadedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
