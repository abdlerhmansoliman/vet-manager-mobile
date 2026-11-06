# VetManager Mobile Application: Task & Branch Roadmap

> **Workflow Rule**: Each task corresponds to an isolated Git branch. Work proceeds strictly one branch at a time. After each branch is implemented, test-verified, and reviewed, we merge to `main` before starting the next.
>
> **Testing Mandate (Zero Untested Code & Zero Untested Requests)**:
> 1. **Every screen or widget containing ANY request** (API call, async database mutation, sync push/pull, or form submit) **MUST have dedicated automated tests** verifying:
>    - **In-flight loading state** (disabling action buttons, showing spinners, preventing double-taps).
>    - **Payload & Header integrity** (asserting exact endpoint URL, HTTP method, `X-Tenant-ID`, Sanctum Bearer token, and UUID v7 `Idempotency-Key`).
>    - **Success transition & UI feedback** (asserting `AppSnackbar.showSuccess`, navigation, cache/state update).
>    - **Failure handling & Clinical Error Shielding** (asserting 422 validation field errors, 401 unauthenticated, 403 forbidden, 500 server crash, and offline network failure with `ClinicalErrorFormatter` — **never leaking raw technical exceptions to users**).
> 2. **Real-World Backend Connection Protocol**:
>    - The mobile application connects to the Laravel backend strictly like a production client. Zero artificial live mock shortcuts.
>    - Real multi-tenant isolation via mandatory `X-Tenant-ID` header.
>    - Strict RFC 9562 UUID v7 `Idempotency-Key` headers on all mutating endpoints (`POST`, `PUT`, `PATCH`, `DELETE`).
>    - Real Laravel 11 validation format handling (`{"message": "...", "errors": {"field": [...]}}`).
>    - Real bidirectional delta sync protocol (`/api/v1/sync/push` & `/api/v1/sync/pull`) with force-reconciliation.
>    - All tests must pass (`flutter test`) and `flutter analyze` must have 0 issues before merging any branch into `main`.

---

## Progress Dashboard

| Part | Branch Name | Scope | Status |
| :--- | :--- | :--- | :--- |
| **01** | `mobile/01-project-scaffold` | Flutter 3.24+ project bootstrap, dependencies & build config | 🟢 **Completed** |
| **02** | `mobile/02-theme-ui-system` | Cheerful color palette, typography & micro-animations | 🟢 **Completed** |
| **03** | `mobile/03-core-network-tenancy` | Dio client, tenant interceptor, secure storage & errors | 🟢 **Completed** |
| **04** | `mobile/04-auth-smart-login` | Two-step email discovery, clinic cards & biometric unlock | 🟢 **Completed** |
| **05** | `mobile/05-drift-clinical-database` | Drift SQLite setup, clinical tables (Clients, Patients, Cases) | 🟢 **Completed** |
| **06** | `mobile/06-drift-pharmacy-tables` | 4-tier pharmacy tables (Products, Batches, Containers, Ledger) | 🟢 **Completed** |
| **07** | `mobile/07-offline-sync-engine` | FIFO mutation queue & Force-Reconcile conflict protocol | 🟢 **Completed** |
| **08** | `mobile/08-clients-patients-module` | Client/Patient lists, search, and `OpenContainer` hero morph | 🟢 **Completed** |
| **08-B** | `mobile/08-patient-crud-medical-file` | Patient Edit, Delete, Multi-Case Medical File & Quick Visit | 🟢 **Completed** |
| **09** | `mobile/09-cases-triage-board` | Triage board (Routine/Urgent/Critical), SOAP notes & addenda | 🟢 **Completed** |
| **09-B** | `mobile/offline-sync-error-shielding` | Clinical error shielding, AppSnackbar, inline form validation, and real-time sync push | 🟢 **Completed** |
| **11** | `mobile/11-staff-and-doctor-profile` | Doctor profile, on-duty toggle & Owner staff CRUD (Create/Edit/PIN) | 🟢 **Completed** |
| **13** | `mobile/13-diagnostic-media-r2` | Direct-to-R2 upload pipeline, WebP compression & zoom viewer | 🟢 **Completed** |
| **14** | `mobile/14-store-review-hardening` | Privacy manifest, account deletion & medical disclaimers | 🟡 **Ready to Start** |
| **10** | `mobile/10-case-study-pdf-export` | Case study PDF generator with owner anonymization toggle (deferred) | ⚪ Deferred |
| **12** | `mobile/12-witness-pin-and-dosing` | Fractional dosing slider & blurred witness PIN bottom sheet (deferred) | ⚪ Deferred |

---

## Detailed Task Breakdown

### Phase 1: Foundation & Design System

#### Part 01: Project Scaffold & Build Configurations
* **Branch**: `mobile/01-project-scaffold`
* **Status**: 🟢 Completed
* **Files Created**:
  - `pubspec.yaml` (full dependency baseline)
  - `analysis_options.yaml` (strict linter rules)
  - `android/app/build.gradle.kts` (targetSdk 35, 16KB page alignment)
  - `ios/Runner/PrivacyInfo.xcprivacy` (Apple Required-Reason APIs skeleton)
* **Definition of Done**:
  - Project builds cleanly on Android and iOS debug targets.

---

#### Part 02: Cheerful UI System & Micro-Animations
* **Branch**: `mobile/02-theme-ui-system`
* **Status**: 🟢 Completed
* **Files Created**:
  - `lib/app/theme/app_colors.dart` (Warm Cream `#FAF8F5`, Emerald `#0D9488`, Coral `#FF7E67`, Pastel badges)
  - `lib/app/theme/text_styles.dart` (Plus Jakarta Sans via `google_fonts`)
  - `lib/app/theme/app_theme.dart` (Light and Dark `ThemeData`)
  - `lib/core/widgets/animated_pressable.dart` (Elastic spring tap feedback)
  - `lib/core/widgets/blurred_bottom_sheet.dart` (BackdropFilter blur + spring slide)
  - `lib/core/widgets/triage_priority_badge.dart` (Mint, Amber, Rose chips)
  - `lib/core/widgets/animal_species_avatar.dart` (Canine, Feline, Equine, Bovine)
* **Definition of Done**:
  - Semantic tokens match Warm Clinical spec; widget tests pass.

---

### Phase 2: Core Infrastructure & Smart Auth

#### Part 03: Network Core, Tenancy & Secure Storage
* **Branch**: `mobile/03-core-network-tenancy`
* **Status**: 🟢 Completed
* **Files Created**:
  - `lib/core/network/api_client.dart`
  - `lib/core/network/tenant_interceptor.dart`
  - `lib/core/network/idempotency_interceptor.dart`
  - `lib/core/network/error_interceptor.dart`
  - `lib/core/storage/secure_storage_service.dart`
  - `lib/core/errors/app_exceptions.dart`
* **Definition of Done**:
  - `X-Tenant-ID` and UUID v7 `Idempotency-Key` are automatically injected into mutating requests; typed exceptions map cleanly.

---

#### Part 04: Two-Step Smart Login & Biometrics
* **Branch**: `mobile/04-auth-smart-login`
* **Status**: 🟢 Completed
* **Files Created**:
  - `lib/features/auth/presentation/screens/smart_login_screen.dart`
  - `lib/features/auth/presentation/bloc/auth_bloc.dart`
  - `lib/features/auth/data/auth_repository.dart`
* **Definition of Done**:
  - Clinician enters email -> discovers clinics -> enters password/biometrics; all auth tests pass.

---

### Phase 3: Relational Persistence & Sync Engine

#### Part 05: Drift Relational Clinical Schema
* **Branch**: `mobile/05-drift-clinical-database`
* **Status**: 🟢 Completed
* **Files Created**:
  - `lib/database/tables/clients_table.dart`
  - `lib/database/tables/patients_table.dart`
  - `lib/database/tables/cases_table.dart`
  - `lib/database/tables/progress_notes_table.dart`
  - `lib/database/daos/client_patient_dao.dart`
  - `lib/database/daos/clinical_case_dao.dart`
* **Definition of Done**:
  - Relational constraints enforced, foreign keys protected, and in-memory SQLite tests pass.

---

#### Part 06: Drift 4-Tier Pharmacy Inventory Tables
* **Branch**: `mobile/06-drift-pharmacy-tables`
* **Status**: 🟢 Completed
* **Files Created**:
  - `lib/database/tables/products_table.dart`
  - `lib/database/tables/product_batches_table.dart`
  - `lib/database/tables/product_containers_table.dart`
  - `lib/database/tables/inventory_ledger_table.dart`
  - `lib/database/daos/inventory_dao.dart`
* **Definition of Done**:
  - First-Expired-First-Out (FEFO) queries prioritize open vials and nearest expiry batches; tests pass.

---

#### Part 07: Offline Sync Engine & Conflict Protocol
* **Branch**: `mobile/07-offline-sync-engine`
* **Status**: 🟢 Completed
* **Files Created**:
  - `lib/sync/sync_queue_dispatcher.dart`
  - `lib/sync/sync_pull_service.dart`
  - `lib/sync/conflict_resolver.dart`
  - `lib/sync/sync_manager.dart`
* **Definition of Done**:
  - Offline mutation queue dispatches FIFO deltas to `/api/v1/sync/push` and `/pull`; conflict tests prove zero clinical data loss.

---

### Phase 4: Clinical Core Workflows

#### Part 08: Patients & Clients Directory
* **Branch**: `mobile/08-clients-patients-module`
* **Status**: 🟢 Completed
* **Files Created**:
  - `lib/features/clients_patients/presentation/screens/patient_list_screen.dart`
  - `lib/features/clients_patients/presentation/widgets/patient_card.dart`
  - `lib/features/clients_patients/presentation/bloc/patient_list_bloc.dart`
* **Definition of Done**:
  - Real-time searching, species filter chips, and smooth OpenContainer navigation; widget tests pass.

---

#### Part 08-B: Patient Medical File & CRUD Operations
* **Branch**: `mobile/08-patient-crud-medical-file`
* **Status**: 🟢 Completed
* **Files Created**:
  - `lib/features/clients_patients/presentation/screens/create_patient_screen.dart`
  - `lib/features/clients_patients/presentation/screens/patient_detail_screen.dart`
* **Definition of Done**:
  - Complete patient medical profile with visits, diagnoses, and edit/delete actions; all tests pass.

---

#### Part 09: Cases Board & SOAP Notes
* **Branch**: `mobile/09-cases-triage-board`
* **Status**: 🟢 Completed
* **Files Created**:
  - `lib/features/clinical_cases/presentation/screens/cases_board_screen.dart`
  - `lib/features/clinical_cases/presentation/screens/case_detail_screen.dart`
  - `lib/features/clinical_cases/presentation/widgets/soap_notes_view.dart`
  - `lib/features/clinical_cases/presentation/widgets/create_addendum_dialog.dart`
* **Definition of Done**:
  - Doctor can triage cases, record SOAP notes, and append immutable signed addenda; tests pass.

---

#### Part 09-B: Clinical Error Shielding & Sync Hardening
* **Branch**: `mobile/offline-sync-error-shielding`
* **Status**: 🟢 Completed
* **Files Created**:
  - `lib/core/errors/clinical_error_formatter.dart` (Centralized user-friendly error translation)
  - `lib/core/widgets/app_snackbar.dart` (Floating clinical feedback banners)
  - `test/core/errors/clinical_error_formatter_test.dart` (19 test cases)
  - `test/core/widgets/app_snackbar_test.dart` (5 widget test cases)
* **Definition of Done**:
  - Zero raw technical exceptions leak to users; inline form validations protect SQLite constraints; background sync triggers seamlessly on patient registration/update/delete; all 150 automated tests pass.

---

#### Part 10: Case Study PDF Export
* **Branch**: `mobile/10-case-study-pdf-export`
* **Status**: 🟡 **Ready to Start**
* **Files to Create**:
  - `lib/features/clinical_cases/presentation/widgets/export_case_study_pdf_sheet.dart` (Live PDF preview & anonymize toggle)
  - `lib/features/clinical_cases/domain/usecases/export_case_pdf_usecase.dart` (PDF document generator with PII masking)
  - `test/features/clinical_cases/export_case_pdf_usecase_test.dart`
  - `test/features/clinical_cases/export_case_study_pdf_sheet_test.dart`
* **Backend Alignment & Real Protocol**:
  - Ingests full case dataset matching Laravel transformers: `ClinicalCaseTransformer`, `ClinicalProgressNoteTransformer`, and `DiagnosisTransformer`.
  - Supports one-click PII anonymization toggle: replaces client name, phone numbers, and address with `[ANONYMIZED CLIENT #ID]`, and patient name with `[CANINE / FELINE PATIENT #ID]` for clinical study sharing.
* **Screen Request & Contract Testing Checklist (MANDATORY)**:
  - [ ] **In-flight Loading**: Test PDF rendering spinner and disabled export button while document compiles.
  - [ ] **Contract Integrity**: Verify case study data model matches real Laravel backend API response for `/api/v1/cases/{id}`.
  - [ ] **Success UI Feedback**: Test `AppSnackbar.showSuccess` upon saving or printing document.
  - [ ] **Error Shielding**: Test corrupt case data or rendering exceptions masked cleanly via `ClinicalErrorFormatter`.
* **Definition of Done**:
  - Attending vet can generate, preview, and share high-resolution case PDFs with or without PII; automated PDF generation and anonymization unit tests pass.

---

### Phase 5: Staff, Dosing & Media

#### Part 11: Doctor Profile & Staff Management
* **Branch**: `mobile/11-staff-and-doctor-profile`
* **Status**: 🟢 **Completed**
* **Files to Create**:
  - `lib/features/staff_profile/domain/entities/staff_entity.dart` (9 roles, capabilities matrix)
  - `lib/features/staff_profile/domain/entities/vet_profile_entity.dart` (License, DEA, active workload, availability)
  - `lib/features/staff_profile/data/repositories/staff_repository_impl.dart`
  - `lib/features/staff_profile/presentation/bloc/staff_bloc.dart`
  - `lib/features/staff_profile/presentation/screens/doctor_profile_screen.dart` (Doctor credentials, active workload metrics, real-time `is_available` toggle)
  - `lib/features/staff_profile/presentation/screens/staff_management_screen.dart` (Owner staff CRUD: create, update, activate/suspend, reset 4-digit PIN)
  - `test/features/staff_profile/doctor_profile_screen_test.dart`
  - `test/features/staff_profile/staff_management_test.dart`
  - `test/features/staff_profile/staff_bloc_test.dart`
  - `test/features/staff_profile/staff_repository_test.dart`
* **Backend Alignment & Real Protocol**:
  - Directly matches Laravel 11 endpoints with full headers (`X-Tenant-ID`, Sanctum Bearer, `Idempotency-Key`):
    - `GET /api/v1/staff` & `POST /api/v1/staff` (fields: `name`, `email`, `password`, `role`, `phone`, `pin`, `job_title`, `specialty`, `license_number`, `is_available`)
    - `GET /api/v1/staff/{user}` & `PUT /api/v1/staff/{user}`
    - `PATCH /api/v1/staff/{user}/availability` (payload: `{"is_available": bool}`)
    - `PATCH /api/v1/staff/{user}/status` (payload: `{"is_active": bool}`)
    - `DELETE /api/v1/staff/{user}`
  - Supports all 9 backend `StaffRole`s: `owner`, `doctor`, `head_vet`, `field_doctor`, `assistant`, `vet_tech`, `counter`, `receptionist`, `employee`.
  - Integrates `capabilities` matrix: `can_manage_staff`, `can_witness_controlled_substances`, `can_access_owner_dashboard`, `can_prescribe_medication`, `can_perform_surgery`, `can_manage_billing`.
* **Screen Request & Contract Testing Checklist (MANDATORY)**:
  - [x] **DoctorProfileScreen Requests**:
    - Test `PATCH /api/v1/staff/{user}/availability`: in-flight switch animation, real payload `{"is_available": bool}`, `X-Tenant-ID` header, success feedback banner, and offline recovery.
  - [x] **StaffManagementScreen Requests**:
    - Test `GET /api/v1/staff`: loading skeleton, rendered staff list, error retry banner.
    - Test `POST /api/v1/staff`: client-side form validation (email format, 4-digit numeric PIN), in-flight submission spinner, 422 Laravel validation error mapping (highlighting duplicate email or short password inline), and success feedback banner.
    - Test `PATCH /api/v1/staff/{user}/status`: modal confirmation, in-flight state update, and status toggle.
    - Test `DELETE /api/v1/staff/{user}`: soft-delete confirmation dialog, request execution, and list removal.
* **Definition of Done**:
  - Doctor can toggle on-duty availability; Clinic Owner can manage staff CRUD, roles, and witness PINs; all request widget and unit tests pass.

---

#### Part 12: Controlled Substances & Witness PIN Dual-Authorization
* **Branch**: `mobile/12-witness-pin-and-dosing`
* **Status**: ⚪ Pending
* **Files to Create**:
  - `lib/features/inventory_doses/data/datasources/inventory_dose_remote_datasource.dart`
  - `lib/features/inventory_doses/domain/usecases/verify_witness_pin_usecase.dart`
  - `lib/features/inventory_doses/presentation/screens/administer_dose_screen.dart` (Fractional dosing slider with `Decimal` precision)
  - `lib/features/inventory_doses/presentation/widgets/witness_pin_bottom_sheet.dart` (Blurred 4-digit supervisor PIN modal)
  - `lib/features/inventory_doses/presentation/widgets/void_dose_bottom_sheet.dart` (Movement reversal & waste reason audit)
  - `test/features/inventory_doses/administer_dose_screen_test.dart`
  - `test/features/inventory_doses/witness_pin_bottom_sheet_test.dart`
  - `test/features/inventory_doses/verify_witness_pin_usecase_test.dart`
* **Backend Alignment & Real Protocol**:
  - Witness Verification: binds to `POST /api/v1/auth/verify-pin` (payload: `witness_email` or `witness_id` + `pin`), validating `canWitnessControlledSubstances()` and returning verified witness metadata.
  - State-Modifying Movements:
    - Dispense/Dose: `POST /api/v1/inventory/consume` with mandatory `Idempotency-Key` header and payload `{"product_id", "quantity", "movement_type": "dispense", "reason"}`.
    - Waste/Discard: `POST /api/v1/inventory/waste` with mandatory `Idempotency-Key` header and payload `{"product_id", "quantity", "reason"}`.
* **Screen Request & Contract Testing Checklist (MANDATORY)**:
  - [ ] **AdministerDoseScreen Requests**:
    - Test `POST /api/v1/inventory/consume`: in-flight spinner, exact `Decimal` precision payload, `Idempotency-Key` header, 422 insufficient stock error handling, and success transition.
  - [ ] **WitnessPinBottomSheet Requests**:
    - Test `POST /api/v1/auth/verify-pin`: in-flight loading animation, invalid PIN error (401/422) display, and successful witness validation unlocking the dosing flow.
  - [ ] **VoidDoseBottomSheet Requests**:
    - Test `POST /api/v1/inventory/waste`: reversal audit payload, mandatory reason field validation, and error shielding.
* **Definition of Done**:
  - Administering Schedule II–V substances triggers the blurred witness modal; verification completes via PIN before ledger mutation commits; void reversals record audit log; all request tests pass.

---

#### Part 13: Direct Cloudflare R2 / S3 Media Pipeline & Radiograph Viewer
* **Branch**: `mobile/13-diagnostic-media-r2`
* **Status**: 🟢 Completed
* **Files Created**:
  - `lib/features/media/domain/entities/diagnostic_image_entity.dart`
  - `lib/features/media/domain/repositories/media_repository.dart`
  - `lib/features/media/data/services/image_compression_service.dart` (WebP compression & SHA-256 integrity digest)
  - `lib/features/media/data/services/r2_direct_uploader.dart` (Direct HTTP PUT to Cloudflare R2 / S3 storage)
  - `lib/features/media/data/repositories/media_repository_impl.dart` (Drift SQLite offline fallback and sync retry)
  - `lib/features/media/presentation/bloc/media_bloc.dart` (Media state machine & upload progress tracking)
  - `lib/features/media/presentation/screens/photo_viewer_screen.dart` (Interactive PhotoView with Invert/High Contrast radiograph filters)
  - `lib/features/media/presentation/widgets/camera_capture_sheet.dart` (Modal image selector, captioning, and in-flight progress)
  - `lib/features/media/presentation/widgets/diagnostic_media_gallery.dart` (Embedded case file media gallery with delete confirmation)
  - `test/features/media/image_compression_service_test.dart`
  - `test/features/media/r2_direct_uploader_test.dart`
  - `test/features/media/media_repository_impl_test.dart`
  - `test/features/media/media_bloc_test.dart`
  - `test/features/media/photo_viewer_screen_test.dart`
  - `test/features/media/camera_capture_sheet_test.dart`
  - `test/features/media/diagnostic_media_gallery_test.dart`
* **Backend Alignment & Real Protocol**:
  - Aligns with backend polymorphic `images` table (`id` UUID, `imageable_type`, `imageable_id`, `url`, `title`, `mime_type`, `file_size_bytes`).
  - Supports attaching diagnostic images to both `ClinicalProgressNote` and `ClinicalCase`.
* **Screen Request & Contract Testing Checklist (MANDATORY)**:
  - [x] **CameraCaptureSheet Requests**:
    - Direct HTTP PUT upload progress stream (0% to 100% progress indicator).
    - Image attachment request to `ClinicalProgressNote` or `ClinicalCase`.
    - Upload failure retry and offline storage queuing in Drift `media_upload_queue`.
  - [x] **PhotoViewerScreen**:
    - Full-screen pinch-to-zoom interactive viewer up to 5x.
    - Radiograph filter modes: Standard, Invert (Negative Film), and High Contrast enhancement.
* **Definition of Done**:
  - Clinical photos compress locally to WebP, upload directly to S3/R2 storage with progress indicator, and link to clinical cases; pinch-to-zoom viewer works smoothly; all 28 media tests and 213 total regression tests pass with 0 warnings.

---

#### Part 14: Store Review & Launch Hardening
* **Branch**: `mobile/14-store-review-hardening`
* **Status**: ⚪ Pending
* **Files to Create**:
  - `lib/features/settings/presentation/screens/delete_account_screen.dart` (App Store Guideline 5.1.1(v))
  - `lib/features/settings/presentation/screens/medical_disclaimer_screen.dart` (App Store Guideline 1.4.1)
  - `ios/Runner/PrivacyInfo.xcprivacy` (Final Apple audit)
  - `test/features/settings/delete_account_screen_test.dart`
  - `test/features/settings/medical_disclaimer_screen_test.dart`
* **Backend Alignment & Real Protocol**:
  - Binds to backend `DELETE /api/v1/auth/account` with mandatory password verification.
* **Screen Request & Contract Testing Checklist (MANDATORY)**:
  - [ ] **DeleteAccountScreen Requests**:
    - Test `DELETE /api/v1/auth/account`: dual-confirmation modal, password confirmation payload, in-flight progress, local session purge from `FlutterSecureStorage`, redirect to login screen, and 401/422 error display.
* **Definition of Done**:
  - Self-service account deletion functions properly with real request test verification; privacy manifest passes `xcrun altool` audit; edge-to-edge passes Android 15 audit; all tests pass.
