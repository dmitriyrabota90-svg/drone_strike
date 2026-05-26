import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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
  static const _operationTimeout = Duration(seconds: 2);
  static const _logThrottle = Duration(seconds: 8);
  static const _settingsLogKey = 'settings.current';

  final Ref _ref;
  String? _currentMusic;
  String? _requestedMusic;
  Future<void> _musicQueue = Future<void>.value();
  Future<void> _oneShotQueue = Future<void>.value();
  Future<bool>? _initializeFuture;
  dynamic _activeOneShot;
  final Map<String, DateTime> _lastLogByKey = <String, DateTime>{};

  Future<void> playMenuMusic() => _playMusicLoop(_menuMusic);

  Future<void> playMissionMusic() => _playMusicLoop(_missionMusic);

  Future<void> stopMusic() {
    if (_isWidgetTestBinding) {
      _requestedMusic = null;
      _currentMusic = null;
      return Future<void>.value();
    }
    _requestedMusic = null;
    _currentMusic = null;
    return _enqueueMusicOperation(() async {
      await _runAudioOperation(
        key: 'bgm.stop',
        description: 'Audio stop failed',
        operation: FlameAudio.bgm.stop,
      );
    });
  }

  Future<void> playVictory() => _playOneShot(_victoryJingle);

  Future<void> playDefeat() => _playOneShot(_defeatJingle);

  Future<void> playFinalTension() => _playOneShot(_finalTensionStinger);

  Future<void> stopOneShot() {
    if (_isWidgetTestBinding) {
      _activeOneShot = null;
      return Future<void>.value();
    }
    return _enqueueOneShotOperation(() => _stopActiveOneShot('oneshot.stop'));
  }

  Future<void> handleSettingsChanged(AudioSettingsState settings) {
    if (!settings.masterSoundEnabled || !settings.musicEnabled) {
      stopMusic();
    }
    return Future<void>.value();
  }

  Future<void> _playMusicLoop(String asset) {
    if (_isWidgetTestBinding) {
      return Future<void>.value();
    }
    _logAudioEvent('bgm.request.$asset', 'Audio music requested: $asset');
    if (_requestedMusic == asset || _currentMusic == asset) {
      _logAudioEvent(
        'bgm.request.duplicate.$asset',
        'Audio music already active/requested: $asset',
      );
      return Future<void>.value();
    }

    _requestedMusic = asset;
    return _enqueueMusicOperation(() async {
      final settings = await _readSettings();
      if (!settings.masterSoundEnabled || !settings.musicEnabled) {
        _logAudioEvent(
          'bgm.skipped.settings.$asset',
          'Audio music skipped by settings: $asset',
        );
        if (_requestedMusic == asset) {
          _requestedMusic = null;
        }
        _currentMusic = null;
        await _runAudioOperation(
          key: 'bgm.stop.disabled',
          description: 'Audio stop failed after settings disabled music',
          operation: FlameAudio.bgm.stop,
        );
        return;
      }
      if (_requestedMusic != asset || _currentMusic == asset) {
        return;
      }

      final initialized = await _ensureInitialized();
      if (!initialized) {
        if (_requestedMusic == asset) {
          _requestedMusic = null;
        }
        _currentMusic = null;
        return;
      }
      if (_currentMusic != null) {
        await _runAudioOperation(
          key: 'bgm.stop.before.$asset',
          description: 'Audio stop failed before music playback',
          operation: FlameAudio.bgm.stop,
        );
      }
      if (_requestedMusic != asset) {
        return;
      }
      final played = await _runAudioOperation(
        key: 'bgm.play.$asset',
        description: 'Audio music playback failed for $asset',
        operation: () => FlameAudio.bgm.play(asset, volume: 0.65),
      );
      if (played && _requestedMusic == asset) {
        _currentMusic = asset;
        _logAudioEvent('bgm.playing.$asset', 'Audio music playing: $asset');
      } else if (_requestedMusic == asset) {
        _requestedMusic = null;
        _currentMusic = null;
      }
    });
  }

  Future<void> _playOneShot(String asset) {
    if (_isWidgetTestBinding) {
      return Future<void>.value();
    }
    return _enqueueOneShotOperation(() async {
      final settings = await _readSettings();
      if (!settings.masterSoundEnabled || !settings.sfxEnabled) {
        _logAudioEvent(
          'oneshot.skipped.settings.$asset',
          'Audio SFX skipped by settings: $asset',
        );
        return;
      }

      await _stopActiveOneShot('oneshot.stop.before.$asset');
      try {
        await _runAudioOperation(
          key: 'oneshot.$asset',
          description: 'Audio one-shot playback failed for $asset',
          operation: () async {
            _activeOneShot = await FlameAudio.playLongAudio(asset, volume: 0.8);
          },
        );
      } on Object catch (error, stackTrace) {
        _logAudioError(
          key: 'oneshot.$asset',
          message: 'Audio one-shot playback failed for $asset: $error',
          stackTrace: stackTrace,
        );
      }
    });
  }

  Future<void> _stopActiveOneShot(String key) async {
    final player = _activeOneShot;
    _activeOneShot = null;
    if (player == null) {
      return;
    }

    await _runAudioOperation(
      key: key,
      description: 'Audio one-shot stop failed',
      operation: () async {
        await player.stop();
        await player.dispose();
      },
    );
  }

  Future<void> _enqueueOneShotOperation(Future<void> Function() operation) {
    final nextOperation = _oneShotQueue.catchError((_) {}).then((_) {
      return operation();
    });
    _oneShotQueue = nextOperation.catchError((_) {});
    return nextOperation;
  }

  Future<AudioSettingsState> _readSettings() async {
    try {
      final settings = await _ref.read(audioSettingsControllerProvider.future);
      _logAudioEvent(
        _settingsLogKey,
        'Audio settings: master=${settings.masterSoundEnabled}, '
        'music=${settings.musicEnabled}, sfx=${settings.sfxEnabled}',
      );
      return settings;
    } on Object catch (error, stackTrace) {
      _logAudioError(
        key: 'settings.read',
        message: 'Audio settings read failed: $error',
        stackTrace: stackTrace,
      );
      return const AudioSettingsState();
    }
  }

  Future<bool> _ensureInitialized() {
    final current = _initializeFuture;
    if (current != null) {
      return current;
    }
    final next =
        _runAudioOperation(
          key: 'bgm.initialize',
          description: 'Audio initialization failed',
          operation: FlameAudio.bgm.initialize,
        ).then((success) {
          if (!success) {
            _initializeFuture = null;
          }
          return success;
        });
    _initializeFuture = next;
    return next;
  }

  bool get _isWidgetTestBinding {
    if (kReleaseMode) {
      return false;
    }
    return WidgetsBinding.instance.runtimeType.toString().contains(
      'TestWidgetsFlutterBinding',
    );
  }

  Future<void> _enqueueMusicOperation(Future<void> Function() operation) {
    final nextOperation = _musicQueue.catchError((_) {}).then((_) {
      return operation();
    });
    _musicQueue = nextOperation.catchError((_) {});
    return nextOperation;
  }

  Future<bool> _runAudioOperation({
    required String key,
    required String description,
    required Future<void> Function() operation,
  }) async {
    try {
      await operation().timeout(_operationTimeout);
      return true;
    } on Object catch (error, stackTrace) {
      _logAudioError(
        key: key,
        message: '$description: $error',
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  void _logAudioEvent(String key, String message) {
    final now = DateTime.now();
    final lastLog = _lastLogByKey[key];
    if (lastLog != null && now.difference(lastLog) < _logThrottle) {
      return;
    }
    _lastLogByKey[key] = now;
    debugPrint(message);
  }

  void _logAudioError({
    required String key,
    required String message,
    required StackTrace stackTrace,
  }) {
    final now = DateTime.now();
    final lastLog = _lastLogByKey[key];
    if (lastLog != null && now.difference(lastLog) < _logThrottle) {
      return;
    }
    _lastLogByKey[key] = now;
    debugPrint(message);
    debugPrint('$stackTrace');
  }
}
