# Context Map: VetManager Mobile

### 1. Tech Stack & Versions
- **Mobile Framework & Platform:** Flutter >= 3.24.0, Dart SDK >= 3.5.0 < 4.0.0, Android 15 (targetSdk 35, 16KB memory page-aligned), iOS 14.0+.
- **Database & Local Persistence:** Drift ^2.20.0 (relational SQLite via `sqlite3_flutter_libs` ^0.5.24), `path_provider` ^2.1.4.
- **Queue System:** Drift SQLite FIFO table (`sync_queue_table`) orchestrated by `SyncQueueDispatcher` background worker.
- **Cache Layer:** Drift SQLite offline-first local state cache; `cached_network_image` ^3.4.0 for remote diagnostic media.
- **Storage Systems:** `flutter_secure_storage` ^9.2.2 (hardware keystore for tokens/keys), MinIO S3 / Cloudflare R2 presigned URLs (diagnostic binary media).
- **State Management & DI:** `flutter_bloc` ^8.1.6, `equatable` ^2.0.5, `get_it` ^7.7.0, `injectable` ^2.4.2 (`injectable_generator` ^2.6.1).
- **Networking & Serialization:** Dio ^5.7.0, `json_annotation` ^4.9.0 (`json_serializable` ^6.8.0), `connectivity_plus` ^6.0.5.
- **Precision Math & Identifiers:** `decimal` ^3.0.2 (arbitrary precision stock & dose math), `uuid` ^4.5.1 (RFC 9562 UUID v7).
- **UI, Media & Printing:** `google_fonts` ^6.2.1, `flutter_animate` ^4.5.0, `animations` ^2.0.11, `flutter_image_compress` ^2.3.0 (WebP), `printing` ^5.13.2.
- **Backend Stack:** Laravel 11 REST API, PHP 8.3, MySQL, Redis/Database queue, MinIO S3, Laravel Sanctum.

### 2. Directory Map
- `lib/app/`: Application bootstrap, routing (`go_router` in `router/`), design tokens (`theme/app_colors.dart`), DI setup (`injection.dart`).
- `lib/core/`: Network interceptors (`TenantInterceptor`, `IdempotencyInterceptor`), secure storage, clinical error shielding (`errors/`), atomic UI components (`widgets/`).
- `lib/database/`: Drift SQLite database definition (`app_database.dart`), schema tables (`tables/`), DAOs (`daos/`), type converters (`converters/`).
- `lib/sync/`: Offline-first synchronization engine (`SyncEngine`), queue dispatching (`SyncQueueDispatcher`), delta pulling (`SyncPullService`), force-reconciliation (`ConflictResolver`).
- `lib/features/auth/`: Multi-tenant authentication, clinic tenant selection, Sanctum token handling, biometric authentication.
- `lib/features/clients_patients/`: Level 1 Patient profile (`PatientDetailScreen`), client owners, animal demographics, species/breed DAOs.
- `lib/features/clinical_cases/`: Level 2 Case management (`CaseDetailScreen`) and Level 3 Clinical encounters (`VisitDetailScreen`), SOAP progress notes, dose administrations.
- `lib/features/media/`: Offline media staging, WebP compression, MinIO presigned binary streaming, radiograph zoom viewer.
- `lib/features/staff_profile/` & `lib/features/settings/`: Clinician profile, offline sync status, app preferences, store compliance.
- `test/`: Unit, DAO, BLoC, and widget test suites mirroring `lib/` structure.

### 3. Architecture & Isolation Rules
- **Multi-Tenancy Strategy:** Header-scoped tenancy; `TenantInterceptor` injects `X-Tenant-ID` (from `FlutterSecureStorage`) on all HTTP requests; Drift tables enforce local `tenant_id` scoping.
- **Authentication & Security:** Laravel Sanctum Bearer tokens stored in OS secure keystore; biometric unlock via `local_auth`; tenant-scoped session lifecycle.
- **Mutation Idempotency:** All mutating requests (`POST`, `PUT`, `PATCH`, `DELETE`) require RFC 9562 UUID v7 `Idempotency-Key` headers via `IdempotencyInterceptor`.
- **Offline-First Data Flow:** Drift SQLite is primary source of truth; mutations enqueue to `sync_queue_table`; background dispatcher syncs via `POST /api/v1/sync/push`; updates pull via `GET /api/v1/sync/pull`.
- **Timezone Conventions:** All persisted and wire timestamps are stored in UTC (ISO 8601); UI presentation transforms to client local timezone.
- **API Response & Error Handling:** Standard Laravel envelopes (`{data: ...}`, `{message: ..., errors: ...}`); errors mapped to typed exceptions without exposing raw SQL/traces.

### 4. Core Domain Entities
- `Client`: Owns 1:M `Patient` records; holds owner identity, contact numbers, and physical address.
- `Patient`: Belongs to `Client` (M:1); holds permanent animal identity (species, breed, microchip, weight, allergies) and 1:M `ClinicalCase` records.
- `ClinicalCase`: Belongs to `Patient` (M:1); represents a medical problem umbrella holding 1:M `Visit` records with triage priority and case status.
- `Visit`: Belongs to `ClinicalCase` (M:1); clinical encounter holding 1:M `ClinicalProgressNote`, 1:M `DoseAdministration`, and 1:M diagnostic media.
- `ClinicalProgressNote`: Belongs to `Visit` (M:1); records structured SOAP findings, objective vitals, or append-only addenda post-signature.
- `DoseAdministration`: Belongs to `Visit` (M:1); records administered medication with `Decimal` dosage, units, route, clinician, and waste.
- `InventoryProduct` / `Batch` / `Container`: 4-tier pharmacy tracking (Product -> Batch [FEFO lot/expiry] -> Container/Vial [volume/seal status]).
- `InventoryMovementLedger`: Immutable audit entry recording stock receipts, dispensations, and waste with witness user IDs.
- `MediaUploadQueue`: Stages local compressed WebP images with upload states (`pending`, `presigned`, `uploaded`) scoped to `Visit`.
- `SyncQueue`: Deterministic FIFO table tracking entity mutations, payloads, retry counts, and idempotency keys.

### 5. Conventions & Constraints
- **Strict 3-Level Clinical Hierarchy:** `Patient -> Case -> Visit`. Level 1 (`PatientDetailScreen`) displays Cases ONLY (no visits, no SOAP, no media). Level 2 (`CaseDetailScreen`) displays timeline of Visits ONLY as compact tiles (no media galleries). Level 3 (`VisitDetailScreen`) is the EXCLUSIVE home for SOAP exams, media uploads, and dose records.
- **Universal 3-Level Edit Capabilities:** Level 1 allows editing patient demographics/allergies; Level 2 allows editing chief complaint/diagnoses/triage; Level 3 allows editing visit title/type prior to signing.
- **Append-Only Clinical Immutability:** Signed visits and notes are permanently locked; subsequent clinical updates MUST use append-only addenda; historical ledger entries are never mutated.
- **Force-Reconcile Sync Protocol:** Offline-recorded clinical encounters and doses are never dropped during sync collisions; server performs FEFO spillover or flags discrepancies.
- **High-Precision Arithmetic:** All drug dosages, stock balances, and unit conversions MUST use `Decimal` (zero floating-point math).
- **Clinical Error Shielding:** Users must never see raw SQL, SQLite exceptions, companion dumps, or network traces; format via `ClinicalErrorFormatter` and present via `AppSnackbar`.
- **Database Access Pattern:** No raw SQL in presentation code; all Drift access through DAOs (`lib/database/daos/`); reactive UI binds to Drift streams (`watch...`).
- **Zero Untested Code Invariant:** All screens with HTTP/DB mutations require automated tests for in-flight loading, payload integrity, success navigation, and 422/offline error shielding.
