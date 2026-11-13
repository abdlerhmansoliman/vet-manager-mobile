import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/secure_storage_service.dart';
import 'locale_state.dart';

/// Cubit managing persistent application localization (Arabic & English).
class LocaleCubit extends Cubit<LocaleState> {
  static const String localeStorageKey = 'app_locale';
  static const Locale defaultLocale = Locale('en');

  final ISecureStorageService? _storageService;

  LocaleCubit({ISecureStorageService? storageService, Locale? initialLocale})
      : _storageService = storageService,
        super(LocaleState(initialLocale ?? defaultLocale)) {
    if (initialLocale == null) {
      loadPersistedLocale();
    }
  }

  /// Loads saved language code from secure storage.
  Future<void> loadPersistedLocale() async {
    if (_storageService == null) return;
    try {
      final savedCode = await _storageService.read(localeStorageKey);
      if (savedCode != null && (savedCode == 'ar' || savedCode == 'en')) {
        emit(LocaleState(Locale(savedCode)));
      }
    } catch (_) {
      // Fallback to default
    }
  }

  /// Sets and persists a new locale ('en' or 'ar').
  Future<void> setLocale(Locale newLocale) async {
    if (state.locale == newLocale) return;
    emit(LocaleState(newLocale));
    if (_storageService != null) {
      try {
        await _storageService.write(localeStorageKey, newLocale.languageCode);
      } catch (_) {
        // Handle gracefully
      }
    }
  }

  /// Toggles between English and Arabic.
  Future<void> toggleLocale() async {
    final next = state.isArabic ? const Locale('en') : const Locale('ar');
    await setLocale(next);
  }
}
