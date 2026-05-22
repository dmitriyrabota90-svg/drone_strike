import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appLocaleControllerProvider =
    AsyncNotifierProvider<AppLocaleController, Locale?>(
      AppLocaleController.new,
    );

class AppLocaleController extends AsyncNotifier<Locale?> {
  static const _localeKey = 'settings.locale';
  static const supportedLanguageCodes = {'en', 'ru'};

  @override
  Future<Locale?> build() async {
    final preferences = await SharedPreferences.getInstance();
    final languageCode = preferences.getString(_localeKey);
    if (languageCode == null ||
        !supportedLanguageCodes.contains(languageCode)) {
      return null;
    }
    return Locale(languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    final languageCode = locale.languageCode;
    if (!supportedLanguageCodes.contains(languageCode)) {
      return;
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_localeKey, languageCode);
    state = AsyncData(Locale(languageCode));
  }
}
