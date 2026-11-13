import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// State representing the application's active locale and text direction.
class LocaleState extends Equatable {
  final Locale locale;

  const LocaleState(this.locale);

  bool get isArabic => locale.languageCode == 'ar';
  bool get isEnglish => locale.languageCode == 'en';

  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;

  @override
  List<Object?> get props => [locale];
}
