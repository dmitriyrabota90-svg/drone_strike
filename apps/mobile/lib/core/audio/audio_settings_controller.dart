import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/local_storage.dart';
import 'audio_settings_state.dart';

final audioSettingsControllerProvider =
    AsyncNotifierProvider<AudioSettingsController, AudioSettingsState>(
      AudioSettingsController.new,
    );

class AudioSettingsController extends AsyncNotifier<AudioSettingsState> {
  static const _masterSoundKey = 'audio.master_sound_enabled';
  static const _musicKey = 'audio.music_enabled';
  static const _sfxKey = 'audio.sfx_enabled';

  late LocalStorage _storage;

  @override
  Future<AudioSettingsState> build() async {
    final preferences = await SharedPreferences.getInstance();
    _storage = LocalStorage(preferences);

    return AudioSettingsState(
      masterSoundEnabled: _storage.getBool(_masterSoundKey) ?? true,
      musicEnabled: _storage.getBool(_musicKey) ?? true,
      sfxEnabled: _storage.getBool(_sfxKey) ?? true,
    );
  }

  Future<void> setMasterSoundEnabled(bool value) {
    return _update(
      state.requireValue.copyWith(masterSoundEnabled: value),
      key: _masterSoundKey,
      value: value,
    );
  }

  Future<void> setMusicEnabled(bool value) {
    return _update(
      state.requireValue.copyWith(musicEnabled: value),
      key: _musicKey,
      value: value,
    );
  }

  Future<void> setSfxEnabled(bool value) {
    return _update(
      state.requireValue.copyWith(sfxEnabled: value),
      key: _sfxKey,
      value: value,
    );
  }

  Future<void> _update(
    AudioSettingsState nextState, {
    required String key,
    required bool value,
  }) async {
    state = AsyncData(nextState);
    await _storage.setBool(key, value);
  }
}
