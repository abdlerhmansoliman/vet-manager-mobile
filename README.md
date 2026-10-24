# VetManager Mobile Application

Enterprise-grade, offline-first clinical client for veterinary clinics, hospitals, and ambulatory farm practices.

## System Requirements
- Flutter SDK `>=3.24.0` (Dart `>=3.5.0`)
- Android Studio / Android SDK (targetSdk 35)
- Xcode 15+ (iOS 14.0+)

## Quick Start
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run code generation (Drift, Injectable, JSON Serializable)
dart run build_runner build --delete-conflicting-outputs

# 3. Run on connected device or emulator
flutter run
```

## Architecture
- **State Management**: `flutter_bloc`
- **Persistence**: `drift` with SQLite (`sqlite3_flutter_libs` 16KB aligned)
- **Networking**: `dio` with dynamic multi-tenant injection (`X-Tenant-ID`, `Idempotency-Key` UUID v7)
- **UI & Motion**: Cheerful Warm Cream palette, Plus Jakarta Sans, `flutter_animate`, and `animations` Hero Container Transforms
- **Store Compliance**: Android 15 edge-to-edge + Photo Picker, Apple `PrivacyInfo.xcprivacy` manifest & in-app account deletion
