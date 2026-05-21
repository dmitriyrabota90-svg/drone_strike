import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

class SecureTokenStorage {
  const SecureTokenStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } on MissingPluginException {
      return null;
    }
  }

  Future<void> writeAccessToken(String token) {
    return _safeWrite(key: _accessTokenKey, value: token);
  }

  Future<String?> readRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } on MissingPluginException {
      return null;
    }
  }

  Future<void> writeRefreshToken(String token) {
    return _safeWrite(key: _refreshTokenKey, value: token);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await writeAccessToken(accessToken);
    await writeRefreshToken(refreshToken);
  }

  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    } on MissingPluginException {
      return;
    }
  }

  Future<void> _safeWrite({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } on MissingPluginException {
      return;
    }
  }
}
