# VetManager Mobile Application: Task & Branch Roadmap

> **Workflow Rule**: Each task corresponds to an isolated Git branch. Work proceeds strictly one branch at a time. After each branch is implemented, test-verified, and reviewed, we merge to `main` before starting the next.

---

## Progress Dashboard

| Part | Branch Name | Scope | Status |
| :--- | :--- | :--- | :--- |
| **01** | `mobile/01-project-scaffold` | Flutter 3.24+ project bootstrap, dependencies & build config | 🟢 **Completed** |
| **02** | `mobile/02-theme-ui-system` | Cheerful color palette, typography & micro-animations | 🟢 **Completed** |
| **03** | `mobile/03-core-network-tenancy` | Dio client, tenant interceptor, secure storage & errors | 🟢 **Completed** |
| **04** | `mobile/04-auth-smart-login` | Two-step email discovery, clinic cards & biometric unlock | 🟢 **Completed** |
| **05** | `mobile/05-drift-clinical-database` | Drift SQLite setup, clinical tables (Clients, Patients, Cases) | 🟡 **Ready to Start** |
| **06** | `mobile/06-drift-pharmacy-tables` | 4-tier pharmacy tables (Products, Batches, Containers, Ledger) | ⚪ Pending |
| **07** | `mobile/07-offline-sync-engine` | FIFO mutation queue & Force-Reconcile conflict protocol | ⚪ Pending |
| **08** | `mobile/08-clients-patients-module` | Client/Patient lists, search, and `OpenContainer` hero morph | ⚪ Pending |
| **09** | `mobile/09-cases-triage-board` | Triage board (Routine/Urgent/Critical), SOAP notes & addenda | ⚪ Pending |
| **10** | `mobile/10-case-study-pdf-export` | Case study PDF generator with owner anonymization toggle | ⚪ Pending |
| **11** | `mobile/11-staff-and-doctor-profile` | Doctor profile, on-duty toggle & Owner staff management | ⚪ Pending |
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
* **Status**: ⚪ Pending
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
* **Status**: ⚪ Pending
* **Files to Create**:
  - `lib/database/tables/inventory_products_table.dart`
  - `lib/database/tables/inventory_batches_table.dart` (FEFO lot tracking)
  - `lib/database/tables/inventory_containers_table.dart` (Physical vial tracking)
  - `lib/database/tables/inventory_movement_ledger_table.dart` (Immutable audit log)
  - `lib/database/daos/inventory_dao.dart` (FEFO queries, open vial checks)
* **Definition of Done**:
  - Integration tests verifying open vial priority and FEFO expiration ordering.

---

#### Part 07: Offline Sync Engine & Force-Reconcile Protocol
* **Branch**: `mobile/07-offline-sync-engine`
* **Status**: ⚪ Pending
* **Files to Create**:
  - `lib/sync/sync_manager.dart` (Connectivity listener)
  - `lib/sync/sync_queue_dispatcher.dart` (Flushes FIFO queue to `POST /api/v1/sync/push`)
  - `lib/sync/sync_pull_service.dart` (Ingests deltas from `GET /api/v1/sync/pull`)
  - `lib/sync/conflict_resolver.dart` (Force-Reconcile & Immutable Append-Only protocol)
* **Definition of Done**:
  - Simulation tests proving offline doses and notes commit without data loss.

---

### Phase 4: Core Clinical Modules

#### Part 08: Clients & Patients Directory
* **Branch**: `mobile/08-clients-patients-module`
* **Status**: ⚪ Pending
* **Files to Create**:
  - `lib/features/clients_patients/presentation/screens/patient_list_screen.dart`
  - `lib/features/clients_patients/presentation/screens/patient_detail_screen.dart`
  - `lib/features/clients_patients/presentation/widgets/patient_card.dart` (`OpenContainer` hero transition)
  - `lib/features/clients_patients/presentation/screens/create_patient_screen.dart`
* **Definition of Done**:
  - Search by phone/name, filter by species, and seamless transition from card to patient profile.

---

#### Part 09: Cases Board & SOAP Notes
* **Branch**: `mobile/09-cases-triage-board`
* **Status**: ⚪ Pending
* **Files to Create**:
  - `lib/features/clinical_cases/presentation/screens/cases_board_screen.dart` (Routine/Urgent/Critical tabs)
  - `lib/features/clinical_cases/presentation/screens/case_detail_screen.dart`
  - `lib/features/clinical_cases/presentation/widgets/soap_notes_view.dart`
  - `lib/features/clinical_cases/presentation/widgets/create_addendum_dialog.dart`
* **Definition of Done**:
  - Attending doctor can triage cases, record SOAP notes, and append immutable signed addenda.

---

#### Part 10: Case Study PDF Export
* **Branch**: `mobile/10-case-study-pdf-export`
* **Status**: ⚪ Pending
* **Files to Create**:
  - `lib/features/clinical_cases/presentation/widgets/export_case_study_pdf_sheet.dart`
  - `lib/features/clinical_cases/domain/usecases/export_case_pdf_usecase.dart`
* **Definition of Done**:
  - Live PDF preview via `printing` package with functional "Anonymize Owner & Pet" toggle switch.

---

### Phase 5: Staff, Dosing & Media

#### Part 11: Doctor Profile & Staff Management
* **Branch**: `mobile/11-staff-and-doctor-profile`
* **Status**: ⚪ Pending
* **Files to Create**:
  - `lib/features/staff_profile/presentation/screens/doctor_profile_screen.dart` (License, DEA, active workload, `is_available` toggle)
  - `lib/features/staff_profile/presentation/screens/staff_management_screen.dart` (Owner staff CRUD + PIN setup)
* **Definition of Done**:
  - Doctor can toggle on-duty availability; Owner can manage staff and reset 4-digit PINs.

---

#### Part 12: Controlled Substances & Witness PIN
* **Branch**: `mobile/12-witness-pin-and-dosing`
* **Status**: ⚪ Pending
* **Files to Create**:
  - `lib/features/inventory_doses/presentation/screens/administer_dose_screen.dart`
  - `lib/features/inventory_doses/presentation/widgets/witness_pin_bottom_sheet.dart` (Blurred 4-digit PIN modal)
  - `lib/features/inventory_doses/presentation/widgets/void_dose_bottom_sheet.dart` (Ledger reversal)
* **Definition of Done**:
  - Controlled drug administration requires supervisor PIN verification before ledger write.

---

#### Part 13: Direct Cloudflare R2 Media Pipeline
* **Branch**: `mobile/13-diagnostic-media-r2`
* **Status**: ⚪ Pending
* **Files to Create**:
  - `lib/features/media/data/services/r2_direct_uploader.dart` (Direct HTTP PUT to presigned URLs)
  - `lib/features/media/presentation/widgets/camera_capture_sheet.dart` (WebP compression)
  - `lib/features/media/presentation/screens/photo_viewer_screen.dart` (Pinch-to-zoom radiograph viewer)
* **Definition of Done**:
  - Photo is compressed to WebP locally and uploaded directly to R2; offline photos queue properly.

---

#### Part 14: Store Review & Launch Hardening
* **Branch**: `mobile/14-store-review-hardening`
* **Status**: ⚪ Pending
* **Files to Create**:
  - `lib/features/settings/presentation/screens/delete_account_screen.dart` (App Store Guideline 5.1.1(v))
  - `lib/features/settings/presentation/screens/medical_disclaimer_screen.dart` (App Store Guideline 1.4.1)
  - `ios/Runner/PrivacyInfo.xcprivacy` (Final Apple audit)
* **Definition of Done**:
  - Account deletion works; privacy manifests pass `xcrun altool` audit; edge-to-edge passes Android 15 audit.
