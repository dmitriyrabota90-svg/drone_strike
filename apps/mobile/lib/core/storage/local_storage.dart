import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  const LocalStorage(this._preferences);

  final SharedPreferences _preferences;

  String? getString(String key) => _preferences.getString(key);

  Future<bool> setString(String key, String value) {
    return _preferences.setString(key, value);
  }

  bool? getBool(String key) => _preferences.getBool(key);

  Future<bool> setBool(String key, bool value) {
    return _preferences.setBool(key, value);
  }

  int? getInt(String key) => _preferences.getInt(key);

  Future<bool> setInt(String key, int value) {
    return _preferences.setInt(key, value);
  }

  Future<bool> remove(String key) => _preferences.remove(key);
}
