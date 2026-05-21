import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_service.dart';
import '../../../features/lives/domain/lives_controller.dart';
import '../../../game/drone_game.dart';
import '../../../game/level_config.dart';
import '../../../game/overlays/game_hud.dart';
import '../../../game/overlays/game_over_overlay.dart';
import '../../../game/overlays/mission_complete_overlay.dart';
import '../../../game/overlays/no_lives_overlay.dart';
import '../../../game/overlays/pause_overlay.dart';
import '../../../game/systems/scoring_system.dart';
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
      _startIfLivesAvailable();
    });
  }

  @override
  void dispose() {
    _audioService.stopMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(livesControllerProvider, (previous, next) {
      final lives = next.asData?.value;
      if (lives == null) {
        return;
      }
      _game.updateLives(lives.currentLives);
      if (!lives.hasLives) {
        _game.showNoLivesOverlay();
      }
    });

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
        DroneGame.noLivesOverlay: (context, game) => const NoLivesOverlay(),
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

  Future<void> _startIfLivesAvailable() async {
    final lives = await ref.read(livesControllerProvider.future);
    _game.updateLives(lives.currentLives);
    if (!lives.hasLives) {
      _game.showNoLivesOverlay();
      return;
    }
    _playMissionMusic();
  }

  Future<void> _handleGameOver() async {
    _audioService.stopMusic();
    _audioService.playDefeat();
    final lives = await ref.read(livesControllerProvider.notifier).spendLife();
    _game.updateLives(lives.currentLives);
    if (!lives.hasLives) {
      _game.showNoLivesOverlay();
    }
  }

  Future<MissionResult> _handleMissionComplete(MissionResult result) async {
    _audioService.stopMusic();
    _audioService.playVictory();
    final authState = ref.read(authControllerProvider).asData?.value;
    final isAuthenticated = authState?.isAuthenticated ?? false;

    if (isAuthenticated) {
      final response = await ref
          .read(progressControllerProvider.notifier)
          .completeMission(
            missionNumber: result.missionNumber,
            flightAccuracyBonus: result.flightAccuracyBonus,
            tankHitBonus: result.tankHitBonus,
          );
      if (response == null) {
        return result.copyWith(isGuest: false, backendSubmitted: false);
      }
      return result.copyWith(
        isGuest: false,
        backendSubmitted: true,
        scoreImproved: response.scoreImproved,
        savedBestScore: response.savedBestScore,
        totalPlayerScore: response.totalScore,
        playerLevel: response.playerLevel,
      );
    }

    if (result.missionNumber <= 2) {
      await ref
          .read(progressControllerProvider.notifier)
          .saveGuestMissionResult(
            missionNumber: result.missionNumber,
            bestScore: result.totalScore,
            flightAccuracyBonus: result.flightAccuracyBonus,
            tankHitBonus: result.tankHitBonus,
          );
    }
    return result.copyWith(isGuest: true, backendSubmitted: false);
  }
}
