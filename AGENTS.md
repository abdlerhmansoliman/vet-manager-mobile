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
2. **Network & Tenancy Protocol**:
   - Every authenticated request requires `X-Tenant-ID` header and Sanctum Bearer token (managed automatically by `TenantInterceptor`).
   - Every mutating request (`POST`, `PUT`, `PATCH`, `DELETE`) must send an `Idempotency-Key` (managed automatically by `IdempotencyInterceptor`).
3. **Error Handling**:
   - HTTP errors are mapped into domain `AppException`s (`NetworkException`, `UnauthorizedException`, `ValidationException`, etc.) by `ErrorInterceptor`.
   - Never catch untyped exceptions silently; present meaningful user messages or handle them in BLoC state.
4. **Calculations**:
   - Always use `Decimal` from the `decimal` package for pharmacy stock quantities, unit conversions, and dosage calculations. Avoid native double/float rounding errors.
5. **Testing Requirements**:
   - Every new BLoC must have unit tests using `bloc_test`.
   - Every new Drift table/DAO must have in-memory database tests in `test/database/`.
   - Every repository or network client must mock dependencies with `mocktail`.
