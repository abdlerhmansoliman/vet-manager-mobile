# VetManager Mobile Application: Task & Branch Roadmap

> **Workflow Rule**: Each task corresponds to an isolated Git branch. Work proceeds strictly one branch at a time. After each branch is implemented, test-verified, and reviewed, we merge to `main` before starting the next.
>
> **Testing Mandate**: Every feature added to this project MUST include corresponding automated test cases (unit, widget, or integration tests). No branch can be merged to `main` without dedicated passing tests for the newly added feature.

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
| **08-B** | `mobile/08-patient-crud-medical-file` | Patient Edit, Delete, Multi-Case Medical File & Quick Visit | 🟡 **In Progress** |
| **09** | `mobile/09-cases-triage-board` | Triage board (Routine/Urgent/Critical), SOAP notes & addenda | 🟢 **Completed** |
| **10** | `mobile/10-case-study-pdf-export` | Case study PDF generator with owner anonymization toggle | ⏸️ **Deferred** |
| **11** | `mobile/11-staff-and-doctor-profile` | Doctor profile, on-duty toggle & Owner staff CRUD (Create/Edit/PIN) | ⚪ Ready Next |
| **12** | `mobile/12-witness-pin-and-dosing` | Fractional dosing slider & blurred witness PIN bottom sheet | ⚪ Pending |
| **13** | `mobile/13-diagnostic-media-r2` | Direct-to-R2 upload pipeline, WebP compression & zoom viewer | ⚪ Pending |
| **14** | `mobile/14-store-review-hardening` | Privacy manifest, account deletion & medical disclaimers | ⚪ Pending |

---

## Detailed Task Breakdown

### Phase 1: Foundation & Design System

#### Part 01: Project Scaffold & Build Configurations
* **Branch**: `mobile/01-project-scaffold`
* **Status**: 🟢 Completed
* **Files to Create / Modify**:
  - `vet_manager_mobile/pubspec.yaml` (full dependency baseline)
  - `vet_manager_mobile/analysis_options.yaml` (strict linter rules)
  - `android/app/build.gradle.kts` (targetSdk 35, 16KB page alignment)
  - `ios/Runner/PrivacyInfo.xcprivacy` (Apple Required-Reason APIs skeleton)
* **Definition of Done**:
  - `flutter pub get` succeeds without version conflicts.
  - Project builds cleanly on Android and iOS debug targets.

---

#### Part 02: Cheerful UI System & Micro-Animations
* **Branch**: `mobile/02-theme-ui-system`
* **Status**: 🟢 Completed
* **Files to Create**:
  - `lib/app/theme/app_colors.dart` (Warm Cream `#FAF8F5`, Emerald `#0D9488`, Coral `#FF7E67`, Pastel badges)
  - `lib/app/theme/text_styles.dart` (Plus Jakarta Sans via `google_fonts`)
  - `lib/app/theme/app_theme.dart` (Light and Dark `ThemeData`)
  - `lib/core/widgets/animated_pressable.dart` (Elastic spring tap feedback)
  - `lib/core/widgets/blurred_bottom_sheet.dart` (BackdropFilter blur + spring slide)
  - `lib/core/widgets/triage_priority_badge.dart` (Mint, Amber, Rose chips)
  - `lib/core/widgets/animal_species_avatar.dart` (Canine, Feline, Equine, Bovine)
* **Definition of Done**:
  - Widget showcase screen displaying color tokens, typography hierarchy, and micro-animations.

---

### Phase 2: Core Networking & Multi-Tenant Auth

#### Part 03: Core Networking & Tenant Interceptors
* **Branch**: `mobile/03-core-network-tenancy`
* **Status**: 🟢 **Completed**
* **Files to Create**:
  - `lib/core/network/api_client.dart` (Dio singleton)
  - `lib/core/network/tenant_interceptor.dart` (Injects `X-Tenant-ID` & Bearer token)
  - `lib/core/network/idempotency_interceptor.dart` (Injects UUID v7 `Idempotency-Key`)
  - `lib/core/network/error_interceptor.dart` (Maps HTTP 401, 403, 409, 422 to domain exceptions)
  - `lib/core/storage/secure_storage_service.dart` (Keychain / EncryptedSharedPreferences)
* **Definition of Done**:
  - Unit tests verifying header injection and token attachment.

---

#### Part 04: Two-Step Smart Login & Session Management
* **Branch**: `mobile/04-auth-smart-login`
* **Status**: 🟢 **Completed**
* **Files to Create**:
  - `lib/features/auth/presentation/screens/smart_login_screen.dart` (Step 1: Email discovery -> Staggered clinic cards -> Step 2: Password)
  - `lib/features/auth/presentation/screens/biometric_unlock_screen.dart` (FaceID/Fingerprint)
  - `lib/features/auth/presentation/bloc/auth_bloc.dart` (State machine)
  - `lib/app/router/app_router.dart` (GoRouter with auth and tenant guards)
* **Definition of Done**:
  - User can discover multiple clinics with email, select clinic with animation, and successfully login against the backend API.

---

### Phase 3: Drift Relational Database & Offline Sync

#### Part 05: Drift Clinical Relational Database
* **Branch**: `mobile/05-drift-clinical-database`
* **Status**: 🟢 **Completed**
* **Files to Create**:
  - `lib/database/app_database.dart`
  - `lib/database/tables/clients_table.dart`
  - `lib/database/tables/patients_table.dart`
  - `lib/database/tables/clinical_cases_table.dart`
  - `lib/database/tables/clinical_progress_notes_table.dart`
  - `lib/database/tables/diagnoses_table.dart`
  - `lib/database/tables/media_upload_queue_table.dart`
  - `lib/database/tables/sync_queue_table.dart`
  - `lib/database/daos/clinical_case_dao.dart`
* **Definition of Done**:
  - `build_runner` generates database schema cleanly; unit tests pass for relational inserts and queries.

---

#### Part 06: Drift 4-Tier Pharmacy Schema
* **Branch**: `mobile/06-drift-pharmacy-tables`
* **Status**: 🟢 **Completed**
* **Files Created**:
  - `lib/database/converters/decimal_converter.dart`
  - `lib/database/tables/inventory_products_table.dart`
  - `lib/database/tables/inventory_batches_table.dart` (FEFO lot tracking)
  - `lib/database/tables/inventory_containers_table.dart` (Physical vial tracking)
  - `lib/database/tables/inventory_movement_ledger_table.dart` (Immutable audit log)
  - `lib/database/daos/inventory_dao.dart` (FEFO queries, open vial checks)
  - `test/database/inventory_dao_test.dart` (FEFO and open vial priority integration tests)
* **Definition of Done**:
  - Integration tests verifying open vial priority and FEFO expiration ordering.

---

#### Part 07: Offline Sync Engine & Force-Reconcile Protocol
* **Branch**: `mobile/07-offline-sync-engine`
* **Status**: 🟢 **Completed**
* **Files to Create**:
  - `lib/sync/sync_manager.dart` (Connectivity listener)
  - `lib/sync/sync_queue_dispatcher.dart` (Flushes FIFO queue to `POST /api/v1/sync/push`)
  - `lib/sync/sync_pull_service.dart` (Ingests deltas from `GET /api/v1/sync/pull`)
  - `lib/sync/conflict_resolver.dart` (Force-Reconcile & Immutable Append-Only protocol)
  - `test/sync/sync_manager_test.dart` (Connectivity & automatic queue flushing)
  - `test/sync/conflict_resolver_test.dart` (Force-Reconcile & FEFO spillover simulation)
* **Definition of Done**:
  - Simulation tests proving offline doses and notes commit without data loss; all sync unit tests pass.

---

### Phase 4: Core Clinical Modules

#### Part 08: Clients & Patients Directory
* **Branch**: `mobile/08-clients-patients-module`
* **Status**: 🟢 **Completed**
* **Files Created**:
  - `lib/database/daos/client_patient_dao.dart` (Reactive cross-entity search & sync queue outbox)
  - `lib/features/clients_patients/domain/entities/patient_entity.dart`
  - `lib/features/clients_patients/domain/repositories/patient_repository.dart`
  - `lib/features/clients_patients/data/repositories/patient_repository_impl.dart`
  - `lib/features/clients_patients/presentation/bloc/patient_list_bloc.dart`
  - `lib/features/clients_patients/presentation/screens/patient_list_screen.dart`
  - `lib/features/clients_patients/presentation/screens/patient_detail_screen.dart`
  - `lib/features/clients_patients/presentation/screens/create_patient_screen.dart`
  - `lib/features/clients_patients/presentation/widgets/patient_card.dart` (`OpenContainer` hero transition)
  - `test/database/client_patient_dao_test.dart`
  - `test/features/clients_patients/patient_list_bloc_test.dart`
  - `test/features/clients_patients/patient_card_widget_test.dart`
  - `test/features/clients_patients/patient_detail_screen_test.dart`
  - `test/features/clients_patients/patient_list_screen_test.dart`
* **Definition of Done**:
  - Search by phone/name, filter by species, and seamless transition from card to patient profile; all widget & unit tests pass.

---

#### Part 08-B: Patient Medical File Structure & Full CRUD
* **Branch**: `mobile/08-patient-crud-medical-file`
* **Status**: 🟡 **In Progress**
* **Files to Create / Modify**:
  - `lib/database/daos/client_patient_dao.dart` (`updatePatient`, `deletePatient` with sync queue)
  - `lib/features/clients_patients/domain/repositories/patient_repository.dart`
  - `lib/features/clients_patients/data/repositories/patient_repository_impl.dart`
  - `lib/features/clinical_cases/domain/repositories/case_repository.dart` (`watchCasesForPatient`)
  - `lib/features/clinical_cases/data/repositories/case_repository_impl.dart`
  - `lib/features/clients_patients/presentation/screens/patient_form_screen.dart` (Unified Create & Edit)
  - `lib/features/clients_patients/presentation/screens/patient_detail_screen.dart` (Multi-case history, tabs, edit/delete actions, new encounter quick sheet)
  - `test/database/client_patient_dao_test.dart` (CRUD & sync queue tests)
  - `test/features/clients_patients/` (Widget and unit tests)
* **Definition of Done**:
  - Patient profile functions as complete medical file showing all clinical cases/visits; doctor can create new visit directly from patient; edit & soft-delete operate atomically offline; all tests pass.

---

#### Part 09: Cases Board & SOAP Notes
* **Branch**: `mobile/09-cases-triage-board`
* **Status**: 🟢 **Completed**
* **Files to Create**:
  - `lib/features/clinical_cases/presentation/screens/cases_board_screen.dart` (Routine/Urgent/Critical tabs)
  - `lib/features/clinical_cases/presentation/screens/case_detail_screen.dart`
  - `lib/features/clinical_cases/presentation/widgets/soap_notes_view.dart`
  - `lib/features/clinical_cases/presentation/widgets/create_addendum_dialog.dart`
  - `test/features/clinical_cases/cases_board_screen_test.dart`
  - `test/features/clinical_cases/soap_notes_view_test.dart`
* **Definition of Done**:
  - Attending doctor can triage cases, record SOAP notes, and append immutable signed addenda; all clinical case tests pass.

---

#### Part 10: Case Study PDF Export
* **Branch**: `mobile/10-case-study-pdf-export`
* **Status**: 🟡 **Ready to Start**
* **Files to Create**:
  - `lib/features/clinical_cases/presentation/widgets/export_case_study_pdf_sheet.dart` (Live PDF preview & anonymize toggle)
  - `lib/features/clinical_cases/domain/usecases/export_case_pdf_usecase.dart` (PDF document generator with PII masking)
  - `test/features/clinical_cases/export_case_pdf_usecase_test.dart`
  - `test/features/clinical_cases/export_case_study_pdf_sheet_test.dart`
* **Backend Alignment**:
  - Ingests full case dataset matching Laravel transformers: `ClinicalCaseTransformer`, `ClinicalProgressNoteTransformer`, and `DiagnosisTransformer`.
  - Includes case identifiers (`case_number`, dates, complaint, diagnoses), vitals (`temperature_c`, `heart_rate_bpm`, `respiratory_rate`, `systolic_bp`, `diastolic_bp`, `mucous_membrane`, `weight_kg`), and signed SOAP notes with attending vet credentials (`job_title`, `license_number`).
  - Supports one-click PII anonymization toggle: replaces client name, phone numbers, and address with `[ANONYMIZED CLIENT #ID]`, and patient name with `[CANINE / FELINE PATIENT #ID]` for clinical study sharing.
* **Definition of Done**:
  - Attending vet can generate, preview, and share high-resolution case PDFs with or without PII; automated PDF generation and anonymization unit tests pass.

---

### Phase 5: Staff, Dosing & Media

#### Part 11: Doctor Profile & Staff Management
* **Branch**: `mobile/11-staff-and-doctor-profile`
* **Status**: ⚪ Pending
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
* **Backend Alignment**:
  - Directly matches Laravel 11 endpoints:
    - `GET /api/v1/staff` & `POST /api/v1/staff` (fields: `name`, `email`, `password`, `role`, `phone`, `pin`, `job_title`, `specialty`, `license_number`, `is_available`)
    - `GET /api/v1/staff/{user}` & `PUT /api/v1/staff/{user}`
    - `PATCH /api/v1/staff/{user}/availability` (payload: `{"is_available": bool}`)
    - `PATCH /api/v1/staff/{user}/status` (payload: `{"is_active": bool}`)
    - `DELETE /api/v1/staff/{user}`
  - Supports all 9 backend `StaffRole`s: `owner`, `doctor`, `head_vet`, `field_doctor`, `assistant`, `vet_tech`, `counter`, `receptionist`, `employee`.
  - Integrates `capabilities` matrix: `can_manage_staff`, `can_witness_controlled_substances`, `can_access_owner_dashboard`, `can_prescribe_medication`, `can_perform_surgery`, `can_manage_billing`.
* **Definition of Done**:
  - Doctor can toggle on-duty availability (`PATCH /staff/{id}/availability`); Clinic Owner can manage staff CRUD, roles, and witness PINs; all unit, BLoC, and widget tests pass.

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
* **Backend Alignment**:
  - Witness Verification: binds to `POST /api/v1/auth/verify-pin` (payload: `witness_email` or `witness_id` + `pin`), validating `canWitnessControlledSubstances()` and returning verified witness metadata.
  - State-Modifying Movements:
    - Dispense/Dose: `POST /api/v1/inventory/consume` with mandatory `Idempotency-Key` header and payload `{"product_id", "quantity", "movement_type": "dispense", "reason"}`.
    - Waste/Discard: `POST /api/v1/inventory/waste` with mandatory `Idempotency-Key` header and payload `{"product_id", "quantity", "reason"}`.
* **Definition of Done**:
  - Administering Schedule II–V substances triggers the blurred witness modal; verification completes via PIN before ledger mutation commits; void reversals record audit log; all tests pass.

---

#### Part 13: Direct Cloudflare R2 / S3 Media Pipeline & Radiograph Viewer
* **Branch**: `mobile/13-diagnostic-media-r2`
* **Status**: ⚪ Pending
* **Files to Create**:
  - `lib/features/media/data/services/r2_direct_uploader.dart` (Direct HTTP PUT to cloud object storage)
  - `lib/features/media/presentation/widgets/camera_capture_sheet.dart` (Pre-upload WebP compression & metadata tagger)
  - `lib/features/media/presentation/screens/photo_viewer_screen.dart` (Pinch-to-zoom high-res radiograph / ultrasound viewer)
  - `test/features/media/r2_direct_uploader_test.dart`
  - `test/features/media/photo_viewer_screen_test.dart`
* **Backend Alignment**:
  - Aligns with backend polymorphic `images` table (`id` UUID, `imageable_type`, `imageable_id`, `url`, `title`, `mime_type`, `file_size_bytes`).
  - Supports attaching diagnostic images to both `ClinicalProgressNote` and `ClinicalCase`.
* **Definition of Done**:
  - Clinical photos compress locally to WebP, upload directly to S3/R2 storage with progress indicator, and link to clinical notes; pinch-to-zoom viewer works smoothly; all tests pass.

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
* **Definition of Done**:
  - Self-service account deletion functions properly; privacy manifest passes `xcrun altool` audit; edge-to-edge passes Android 15 audit; compliance widget tests pass.
