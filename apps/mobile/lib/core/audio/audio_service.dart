import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_settings_controller.dart';
import 'audio_settings_state.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService(ref);
});

class AudioService {
  AudioService(this._ref);

  static const _menuMusic = 'music/music_menu_loop.ogg';
  static const _missionMusic = 'music/music_mission_loop.ogg';
  static const _victoryJingle = 'music/music_victory_jingle.ogg';
  static const _defeatJingle = 'music/music_defeat_jingle.ogg';
  static const _finalTensionStinger = 'music/music_final_tension_stinger.ogg';

  final Ref _ref;
  String? _currentMusic;

  Future<void> playMenuMusic() => _playMusicLoop(_menuMusic);

  Future<void> playMissionMusic() => _playMusicLoop(_missionMusic);

  Future<void> stopMusic() async {
    try {
      await FlameAudio.bgm.stop();
      _currentMusic = null;
    } on Object catch (error, stackTrace) {
      debugPrint('Audio stop failed: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> playVictory() => _playOneShot(_victoryJingle);

  Future<void> playDefeat() => _playOneShot(_defeatJingle);

  Future<void> playFinalTension() => _playOneShot(_finalTensionStinger);

  Future<void> handleSettingsChanged(AudioSettingsState settings) async {
    if (!settings.masterSoundEnabled || !settings.musicEnabled) {
      await stopMusic();
    }
  }

  Future<void> _playMusicLoop(String asset) async {
    final settings = await _readSettings();
    if (!settings.masterSoundEnabled || !settings.musicEnabled) {
      await stopMusic();
      return;
    }
    if (_currentMusic == asset) {
      return;
    }

    try {
      await FlameAudio.bgm.stop();
      await FlameAudio.bgm.play(asset, volume: 0.65);
      _currentMusic = asset;
    } on Object catch (error, stackTrace) {
      debugPrint('Audio music playback failed for $asset: $error');
      debugPrint('$stackTrace');
      _currentMusic = null;
    }
  }

  Future<void> _playOneShot(String asset) async {
    final settings = await _readSettings();
    if (!settings.masterSoundEnabled || !settings.sfxEnabled) {
      return;
    }

    try {
      await FlameAudio.play(asset, volume: 0.8);
    } on Object catch (error, stackTrace) {
      debugPrint('Audio one-shot playback failed for $asset: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<AudioSettingsState> _readSettings() async {
    try {
      return await _ref.read(audioSettingsControllerProvider.future);
    } on Object catch (error, stackTrace) {
      debugPrint('Audio settings read failed: $error');
      debugPrint('$stackTrace');
      return const AudioSettingsState();
    }
  }
}
