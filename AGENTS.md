# VetManager Mobile — AI Agent Guidelines & Project Playbook

Welcome to **VetManager Mobile**. This guide provides essential context, architecture patterns, conventions, and operational workflows to enable fast, reliable, and high-quality contributions across the codebase.

---

## 1. Project Overview & Architecture

**VetManager Mobile** is an enterprise-grade, offline-first Flutter application (Flutter 3.24+, Dart 3.5+) built for veterinary practitioners (clinic owners, doctors, technicians, and ambulatory farm veterinarians). It interfaces with the multi-tenant VetManager Laravel backend.

### Architectural Principles
- **Clean Architecture & Feature-Driven**:
  - `lib/features/<feature>/`: Feature modules split into `presentation`, `domain`, and `data`.
  - `lib/core/`: Shared network, storage, errors, and reusable atomic UI widgets.
  - `lib/database/`: Drift (SQLite) tables, DAOs, schema definitions, and migration handlers.
  - `lib/app/`: App entrypoint, routing (`go_router`), global theme, and dependency injection setup.
- **Offline-First Persistence**: All clinical cases, progress notes, patients, and inventory reads/writes interact with local Drift SQLite first. The background sync engine handles bidirectional synchronization.
- **Immutable Append-Only Audit**: Progress notes, medical addenda, and pharmacy ledger entries are strictly append-only; historical clinical records are never mutated in place.
- **Strict 3-Level Clinical Hierarchy (`Patient -> Case -> Visit`)**:
  - Full specification detailed in [`CLINICAL_WORKFLOW_ARCHITECTURE.md`](file:///home/abdelrhaman/www/vet-manager-mobile/CLINICAL_WORKFLOW_ARCHITECTURE.md).
  - **Level 1: Patient Profile (`PatientDetailScreen`)**: Strictly displays Clinical Cases ONLY (no visits, no media, no SOAP notes here). Primary button: `"Create New Case"`. Full edit capabilities: Demographics, weight, microchip, high-risk allergies, and owner details (`PUT /api/v1/patients/{patient}`).
  - **Level 2: Case Detail Screen (`CaseDetailScreen`)**: Represents one medical problem/disease umbrella. Displays case details and the timeline of Visits belonging to this case as compact `VisitCard` title tiles. Zero media galleries allowed here. Primary button: `"Start New Visit"`. Full edit capabilities: Chief complaint, provisional/final diagnoses, triage priority, and case status (`PUT /api/v1/cases/{case}`).
  - **Level 3: Visit Detail Screen (`VisitDetailScreen`)**: The EXCLUSIVE place for SOAP exams, administered doses, and uploading diagnostic media to MinIO S3 via Presigned URLs. Full edit capabilities: Visit title, visit type, and reason for visit before signing & locking (`PUT /api/v1/visits/{visit}`).

---

## 2. Core Technology Stack & Libraries

| Capability | Library / Version | Role & Notes |
| :--- | :--- | :--- |
| **State Management** | `flutter_bloc: ^8.1.6`, `equatable: ^2.0.5` | Predictable event-driven BLoC architecture for all feature screens. |
| **Local Relational DB**| `drift: ^2.20.0`, `sqlite3_flutter_libs: ^0.5.24` | Local SQLite database. Compatible with Android 15 16KB memory page size. |
| **Dependency Injection**| `get_it: ^7.7.0`, `injectable: ^2.4.2` | Compile-time DI registration via `@injectable`, `@lazySingleton`. |
| **Networking** | `dio: ^5.7.0` | Custom interceptors for tenancy (`X-Tenant-ID`), UUID v7 idempotency, and typed error mapping. |
| **Routing** | `go_router: ^14.2.7` | Declarative routing with route guards for authentication and tenancy. |
| **Security & Auth** | `flutter_secure_storage: ^9.2.2`, `local_auth: ^2.2.0` | Secure storage for tokens/tenant keys; biometric authentication unlock. |
| **Precision Math** | `decimal: ^3.0.2` | High-precision arithmetic for fractional doses and drug waste (no floats). |
| **Identities** | `uuid: ^4.5.1` | RFC 9562 UUID v7 for client-side generated entities and idempotency keys. |
| **UI & Animations** | `google_fonts: ^6.2.1`, `flutter_animate: ^4.5.0`, `animations: ^2.0.11` | Warm clinical design system, staggered transitions, and `OpenContainer` transforms. |

---

## 3. UI/UX & Design System Rules

The app strictly follows the **Cheerful Warm Clinical Aesthetic** (see `BLUEPRINT.md` §1.1). Never use stark sterile cold whites or generic unstyled Material widgets.

### Semantic Color Palette (`lib/app/theme/app_colors.dart`)
- **Background**: `AppColors.backgroundCream` (`#FAF8F5`) — main warm backdrop.
- **Surfaces**: `AppColors.surfaceWhite` (`#FFFFFF`) — cards and sheets.
- **Brand Primary**: `AppColors.primaryEmerald` (`#0D9488`) — main actions, primary buttons.
- **Brand Secondary**: `AppColors.secondaryCoral` (`#FF7E67`) — highlights, secondary FABs.
- **Typography**: `AppColors.textCharcoal` (`#1E293B`) for body text, `AppColors.textMuted` (`#64748B`) for labels.
- **Triage & Status Badges**:
  - Stable / Normal: `AppColors.badgeStableMint` (`#D1FAE5`)
  - Observation / Warning: `AppColors.badgeObsAmber` (`#FEF3C7`)
  - Critical / Emergency: `AppColors.badgeCriticalRose` (`#FFE4E6`)

### Mandatory Micro-Animations
1. **Staggered Entry**: Animate lists and dashboard cards with `.animate().fadeIn(duration: 250.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad)`.
2. **Container Morphing**: Use `OpenContainer` from `animations` package when navigating from list items to details.
3. **Blurred Modal Sheets**: Use `BlurredBottomSheet` with `ImageFilter.blur(sigmaX: 8, sigmaY: 8)` and spring curves for action panels.

---

## 4. Key Workflows & Common Commands

Always run these commands from the project root (`/home/abdelrhaman/www/vet-manager-mobile`):

### Running Tests
```bash
# Run all unit and widget tests
flutter test

# Run a specific test file
flutter test test/features/auth/auth_bloc_test.dart
```
> **Rule**: All tests must pass before concluding any task.

### Code Generation (Drift, Injectable, JsonSerializable)
```bash
# Run build_runner once
dart run build_runner build --delete-conflicting-outputs

# Watch mode during active schema development
dart run build_runner watch --delete-conflicting-outputs
```

### Static Analysis & Lints
```bash
# Analyze codebase against analysis_options.yaml
flutter analyze
```

### Roadmaps and Progress
Refer to `MOBILE_TASKS.md` for active development branches, phase completion status, and upcoming task specifications.

---

## 5. Coding Standards & Conventions

1. **Drift & Database Operations**:
   - Never write raw SQL in UI or presentation code.
   - Always encapsulate database logic inside Drift DAOs (`lib/database/daos/`).
   - Use streams (`watch...`) for reactive UI updates rather than one-time fetches where real-time synchronization is needed.
2. **Production-Grade Real Backend Connection Protocol**:
   - Live execution must connect to the real Laravel backend just like a production client. Zero fake live shortcuts.
   - **Tenancy Scoping**: Every clinic-scoped request must supply `X-Tenant-ID` header and Sanctum Bearer token (managed automatically by `TenantInterceptor`).
   - **Idempotency**: Every mutating request (`POST`, `PUT`, `PATCH`, `DELETE`) must send an RFC 9562 UUID v7 `Idempotency-Key` (managed automatically by `IdempotencyInterceptor`).
   - **Validation Format**: Handle Laravel 11 validation responses (`{"message": "...", "errors": {"field": [...]}}`) mapped to `ValidationException`.
   - **Offline-First Fallback**: When the real backend connection is unreachable or offline, the client must seamlessly persist data locally to Drift SQLite and enqueue the mutation for background sync without blocking the user.
3. **Clinical Error Shielding (Zero Raw Technical Errors to Users)**:
   - Users must **NEVER** see raw exceptions, SQL errors, SQLite lock errors, `InvalidDataException`, companion dumps, or network stack traces in the UI.
   - Always format user-facing error messages through `ClinicalErrorFormatter.format(e, fallbackMessage: ...)`.
   - Always display notices via `AppSnackbar.showError`, `AppSnackbar.showSuccess`, `AppSnackbar.showWarning`, or `AppSnackbar.showInfo`.
4. **Calculations**:
   - Always use `Decimal` from the `decimal` package for pharmacy stock quantities, unit conversions, and dosage calculations. Avoid native double/float rounding errors.
5. **Mandatory Testing Requirements (Zero Untested Code)**:
   - **Every single feature, module, service, use case, or screen added MUST include dedicated automated test cases.** No task or branch is considered complete without accompanying passing tests.
   - **MANDATORY SCREEN REQUEST TESTING**:
     - Any screen or widget that contains or triggers an HTTP request, background mutation, or database write MUST have dedicated automated tests covering:
       1. **In-Flight / Loading State**: Disabling buttons, showing progress indicators, preventing duplicate submissions.
       2. **Payload & Contract Integrity**: Verifying that the exact JSON request body, HTTP method, URL endpoint, headers (`X-Tenant-ID`, `Authorization: Bearer`, `Idempotency-Key`) conform to real backend API specifications.
       3. **Success State & UI Transitions**: Ensuring data updates locally, navigates or dismisses properly, and shows cheerful clinical success feedback (`AppSnackbar.showSuccess`).
       4. **Failure State & Error Shielding**: Testing 422 validation errors (showing inline red hints), 401 unauthenticated (session expiry), 403 forbidden, and 500/offline errors. Ensuring `ClinicalErrorFormatter` converts raw exceptions into friendly instructions and **NEVER** displays technical/database dumps to the user.
   - **BLoC State Management**: Every BLoC/Cubit must have comprehensive event-driven state transition tests using `bloc_test`.
   - **Database & DAOs**: Every Drift table, schema migration, and DAO query must have isolated in-memory SQLite tests in `test/database/` verifying relational constraints, sorting (e.g., FEFO), and atomic mutations.
   - **Repositories & Network**: Every repository and remote client must mock dependencies with `mocktail`, verifying request payload mapping, header injection, and typed error handling.
   - **Sync Engine**: Offline queue dispatchers and conflict resolvers must have simulation tests proving zero clinical data loss.
   - **UI Components & Screens**: Reusable widgets, bottom sheets, and critical user flows must have widget tests verifying rendering, user input, and state responsiveness.
   - **Invariant**: All tests must pass (`flutter test`) before merging any branch into `main`.

---

## 6. Permanent Directives for Full-Stack Parity & Continuous Documentation

> [!IMPORTANT]
> **MANDATORY STANDING AGENT DIRECTIVE**:
> Any modification made to the Backend (`/var/www/vet-manager`) or Mobile (`/home/abdelrhaman/www/vet-manager-mobile`) codebase MUST strictly follow these permanent rules:

### 6.1 Architectural Parity Invariant
Every clinical and domain entity must exist in perfect architectural parity between Mobile (Flutter + Drift SQLite) and Backend (Laravel 11 + MySQL + Eloquent). Whenever an entity, field, or action is added or updated on either side:
- **Schema Parity**: Eloquent migrations and MySQL schema must correspond 1:1 with Drift SQLite tables and DAOs.
- **Sync Engine Synchronization**: The bidirectional sync engine (`SyncController.php` delta pull & `ProcessSyncMutationsJob.php` mutation push <-> `SyncDao`, `SyncEngine`) must ingest and export the entity.
- **Contract & DTO Parity**: Laravel Request/Action/Transformer must conform exactly with Flutter DTOs and Repositories.

### 6.2 Strict 3-Tier Clinical Hierarchy & Multi-Visit Support
1. **Level 1 (Patient Profile - `PatientDetailScreen`)**: Holds ONLY Clinical Cases. Primary action is `"Create New Case"`. Strictly NO visits, NO SOAP notes, and NO media galleries on the patient profile.
2. **Level 2 (Case Detail Screen - `CaseDetailScreen`)**: Represents the medical problem umbrella. Holds ONLY the chronological list of Visits belonging to this case, displayed as clean, compact `VisitCard` title tiles. Primary action is `"Start New Visit"`. Strictly NO diagnostic media galleries on the case screen.
3. **Level 3 (Visit Detail Screen - `VisitDetailScreen`)**: The EXCLUSIVE place for SOAP clinical examinations, vital signs, administered medications/doses, diagnostic media uploads to MinIO S3 via Presigned URLs, and legal record signing & locking.

### 6.3 Universal 3-Level Edit Capabilities
All three levels MUST support complete editing without violating medical record immutability:
- **Level 1 (Patient)**: Demographics, species, breed, age, weight, microchip, high-risk allergies, and client owner information (`PUT /api/v1/patients/{patient}`).
- **Level 2 (Case)**: Chief complaint, provisional/final diagnoses, triage priority, and encounter status (`PUT /api/v1/cases/{case}`).
- **Level 3 (Visit)**: Visit title, visit type, and reason for visit before signing & locking (`PUT /api/v1/visits/{visit}`).

### 6.4 Continuous Documentation & Roadmap Synchronization
Whenever ANY modification is made to the backend or mobile codebase:
- All related `.md` documentation files (`AGENTS.md`, `CLINICAL_WORKFLOW_ARCHITECTURE.md`, `CLINICAL_WORKFLOW_AND_MEDIA.md`, `API_CONTRACT.md`, `MOBILE_TASKS.md`, `walkthrough.md`) MUST be updated immediately within the same task.
- Roadmaps, progress dashboards, and checklists must accurately reflect actual implemented states, route endpoints, and verified test counts.

### 6.5 Mandatory Automated Testing (Zero Untested Code)
- Every backend change must pass all PHPUnit feature & unit tests (`php artisan test`).
- Every mobile change must pass static analysis (`flutter analyze` with 0 issues) and all unit/widget tests (`flutter test`).
- Zero unverified code is ever merged or reported as complete.

