import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_service.dart';
import '../../../game/drone_game.dart';
import '../../../game/level_config.dart';
import '../../../game/overlays/game_hud.dart';
import '../../../game/overlays/game_over_overlay.dart';
import '../../../game/overlays/mission_complete_overlay.dart';
import '../../../game/overlays/pause_overlay.dart';
import '../../auth/domain/auth_controller.dart';
import '../../progress/domain/progress_controller.dart';

class GamePlaceholderScreen extends ConsumerStatefulWidget {
  const GamePlaceholderScreen({required this.missionNumber, super.key});

  final int missionNumber;

  @override
  ConsumerState<GamePlaceholderScreen> createState() =>
      _GamePlaceholderScreenState();
}

class _GamePlaceholderScreenState extends ConsumerState<GamePlaceholderScreen> {
  late final DroneGame _game;
  late final AudioService _audioService;

  @override
  void initState() {
    super.initState();
    _audioService = ref.read(audioServiceProvider);
    final levelConfig = LevelConfig.forMission(widget.missionNumber);
    _game = DroneGame(
      levelConfig: levelConfig,
      initialPlayerLevel: _readInitialPlayerLevel(),
      onGameOver: _handleGameOver,
      onMissionComplete: _handleMissionComplete,
      onRestart: _playMissionMusic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _playMissionMusic();
    });
  }

  @override
  void dispose() {
    _audioService.stopMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget<DroneGame>(
      key: ValueKey('drone-game-${widget.missionNumber}'),
      game: _game,
      initialActiveOverlays: const [DroneGame.hudOverlay],
      overlayBuilderMap: {
        DroneGame.hudOverlay: (context, game) => GameHud(game: game),
        DroneGame.pauseOverlay: (context, game) => PauseOverlay(game: game),
        DroneGame.gameOverOverlay: (context, game) =>
            GameOverOverlay(game: game),
        DroneGame.missionCompleteOverlay: (context, game) =>
            MissionCompleteOverlay(game: game),
      },
    );
  }

  int _readInitialPlayerLevel() {
    final progressLevel = ref
        .read(progressControllerProvider)
        .asData
        ?.value
        .playerLevel;
    final profileLevel = ref
        .read(authControllerProvider)
        .asData
        ?.value
        .user
        ?.playerLevel;
    return progressLevel ?? profileLevel ?? 1;
  }

  void _playMissionMusic() {
    _audioService.playMissionMusic();
  }

  void _handleGameOver() {
    _audioService.stopMusic();
    _audioService.playDefeat();
  }

  void _handleMissionComplete() {
    _audioService.stopMusic();
    _audioService.playVictory();
  }
}
