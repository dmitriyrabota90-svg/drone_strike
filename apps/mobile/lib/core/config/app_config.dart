import 'package:flutter/foundation.dart';

class AppConfig {
  static const _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');
  static const apiBaseUrl = _apiBaseUrlOverride == ''
      ? (kReleaseMode ? 'https://api.fpv-last-run.ru' : 'http://localhost:8000')
      : _apiBaseUrlOverride;
}
