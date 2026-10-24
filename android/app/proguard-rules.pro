# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# SQLite3 libs for Drift
-keep class org.sqlite.** { *; }

# Biometric & Secure Storage
-keep class androidx.biometric.** { *; }
-keep class androidx.security.crypto.** { *; }
