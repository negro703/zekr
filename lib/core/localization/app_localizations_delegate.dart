import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// [LocalizationsDelegate] for [AppStrings].
///
/// Resolves the correct [AppStrings] implementation for the active
/// locale (Arabic or English) and rebuilds the widget tree when the
/// locale changes.
class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
  ];

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'ar' || locale.languageCode == 'en';

  @override
  Future<AppStrings> load(Locale locale) async {
    return stringsFor(locale);
  }

  @override
  bool shouldReload(AppStringsDelegate old) => false;
}