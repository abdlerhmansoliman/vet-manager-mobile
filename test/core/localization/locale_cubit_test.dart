import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vet_manager_mobile/core/localization/locale_cubit.dart';
import 'package:vet_manager_mobile/core/localization/locale_state.dart';
import 'package:vet_manager_mobile/core/storage/secure_storage_service.dart';

class MockSecureStorageService extends Mock implements ISecureStorageService {}

void main() {
  late MockSecureStorageService mockStorage;

  setUp(() {
    mockStorage = MockSecureStorageService();
  });

  group('LocaleState', () {
    test('reports correct flags for English', () {
      const state = LocaleState(Locale('en'));
      expect(state.isEnglish, isTrue);
      expect(state.isArabic, isFalse);
      expect(state.textDirection, TextDirection.ltr);
    });

    test('reports correct flags for Arabic', () {
      const state = LocaleState(Locale('ar'));
      expect(state.isEnglish, isFalse);
      expect(state.isArabic, isTrue);
      expect(state.textDirection, TextDirection.rtl);
    });
  });

  group('LocaleCubit', () {
    test('initializes with default English locale when no initialLocale or storage provided', () async {
      final cubit = LocaleCubit();
      expect(cubit.state.locale, const Locale('en'));
      expect(cubit.state.isEnglish, isTrue);
      await cubit.close();
    });

    test('initializes with given initialLocale', () async {
      final cubit = LocaleCubit(initialLocale: const Locale('ar'));
      expect(cubit.state.locale, const Locale('ar'));
      expect(cubit.state.isArabic, isTrue);
      await cubit.close();
    });

    test('loads persisted Arabic locale from secure storage on creation', () async {
      when(() => mockStorage.read(LocaleCubit.localeStorageKey))
          .thenAnswer((_) async => 'ar');

      final cubit = LocaleCubit(storageService: mockStorage);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.locale, const Locale('ar'));
      expect(cubit.state.isArabic, isTrue);
      verify(() => mockStorage.read(LocaleCubit.localeStorageKey)).called(1);
      await cubit.close();
    });

    test('gracefully ignores invalid persisted locale code', () async {
      when(() => mockStorage.read(LocaleCubit.localeStorageKey))
          .thenAnswer((_) async => 'fr');

      final cubit = LocaleCubit(storageService: mockStorage);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.locale, const Locale('en'));
      await cubit.close();
    });

    test('gracefully handles storage read exception', () async {
      when(() => mockStorage.read(LocaleCubit.localeStorageKey))
          .thenThrow(Exception('Storage corrupted'));

      final cubit = LocaleCubit(storageService: mockStorage);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.locale, const Locale('en'));
      await cubit.close();
    });

    test('setLocale emits new state and persists to storage', () async {
      when(() => mockStorage.read(LocaleCubit.localeStorageKey))
          .thenAnswer((_) async => null);
      when(() => mockStorage.write(LocaleCubit.localeStorageKey, 'ar'))
          .thenAnswer((_) async {});

      final cubit = LocaleCubit(storageService: mockStorage);
      await Future<void>.delayed(Duration.zero);

      await cubit.setLocale(const Locale('ar'));
      expect(cubit.state.locale, const Locale('ar'));
      expect(cubit.state.isArabic, isTrue);

      verify(() => mockStorage.write(LocaleCubit.localeStorageKey, 'ar')).called(1);
      await cubit.close();
    });

    test('setLocale does not emit or persist if new locale matches current', () async {
      final cubit = LocaleCubit(
        storageService: mockStorage,
        initialLocale: const Locale('en'),
      );

      await cubit.setLocale(const Locale('en'));
      verifyNever(() => mockStorage.write(any(), any()));
      await cubit.close();
    });

    test('toggleLocale alternates between English and Arabic', () async {
      when(() => mockStorage.write(any(), any())).thenAnswer((_) async {});

      final cubit = LocaleCubit(
        storageService: mockStorage,
        initialLocale: const Locale('en'),
      );

      await cubit.toggleLocale();
      expect(cubit.state.locale, const Locale('ar'));
      expect(cubit.state.isArabic, isTrue);

      await cubit.toggleLocale();
      expect(cubit.state.locale, const Locale('en'));
      expect(cubit.state.isEnglish, isTrue);

      await cubit.close();
    });
  });
}
