import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

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
import '../../../l10n/generated/app_localizations.dart';
import '../../achievements/domain/achievement_state.dart';
import '../../achievements/domain/achievements_controller.dart';
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
  DroneGame? _game;
  late final AudioService _audioService;
  bool _orientationReady = false;
  bool _gameLayoutReady = false;
  bool _gameLayoutCheckScheduled = false;
  bool _startCheckScheduled = false;
  MissionResult? _missionResult;

  @override
  void initState() {
    super.initState();
    _audioService = ref.read(audioServiceProvider);
    _enterLandscape();
  }

  @override
  void didUpdateWidget(covariant GamePlaceholderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.missionNumber == widget.missionNumber) {
      return;
    }
    _audioService.stopMusic();
    _game = null;
    _missionResult = null;
    _startCheckScheduled = false;
    _gameLayoutReady = false;
    _gameLayoutCheckScheduled = false;
  }

  @override
  void dispose() {
    _audioService.stopMusic();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(livesControllerProvider, (previous, next) {
      final lives = next.asData?.value;
      final game = _game;
      if (lives == null) {
        return;
      }
      game?.updateLives(lives.currentLives);
      if (!lives.hasLives) {
        game?.showNoLivesOverlay();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF061426),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final gameSize = _resolveGameSize(constraints);
          final hasValidGameSize = _hasValidGameSize(gameSize);
          if (!_orientationReady || !hasValidGameSize) {
            return const SizedBox.expand(
              child: ColoredBox(
                color: Color(0xFF061426),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (!_gameLayoutReady) {
            _scheduleGameLayoutCheck();
            return const SizedBox.expand(
              child: ColoredBox(
                color: Color(0xFF061426),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          final game = _ensureGame();
          _scheduleStartCheck();

          return ColoredBox(
            color: const Color(0xFF061426),
            child: Center(
              child: SizedBox(
                width: gameSize.width,
                height: gameSize.height,
                child: GameWidget<DroneGame>(
                  key: ValueKey('drone-game-${widget.missionNumber}'),
                  game: game,
                  initialActiveOverlays: const [DroneGame.hudOverlay],
                  overlayBuilderMap: {
                    DroneGame.hudOverlay: (context, game) =>
                        GameHud(game: game),
                    DroneGame.pauseOverlay: (context, game) =>
                        PauseOverlay(game: game),
                    DroneGame.gameOverOverlay: (context, game) =>
                        GameOverOverlay(game: game),
                    DroneGame.missionCompleteOverlay: (context, game) =>
                        MissionCompleteOverlay(result: _missionResult),
                    DroneGame.noLivesOverlay: (context, game) =>
                        const NoLivesOverlay(),
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _enterLandscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _orientationReady = true;
          _gameLayoutReady = false;
          _gameLayoutCheckScheduled = false;
        });
      });
    });
  }

  Size _resolveGameSize(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0;
    final maxHeight = constraints.maxHeight.isFinite
        ? constraints.maxHeight
        : 0.0;
    if (maxWidth <= 0 || maxHeight <= 0) {
      return Size.zero;
    }

    const targetAspectRatio = 16 / 9;
    final widthFromHeight = maxHeight * targetAspectRatio;
    if (widthFromHeight <= maxWidth) {
      return Size(widthFromHeight, maxHeight);
    }
    return Size(maxWidth, maxWidth / targetAspectRatio);
  }

  bool _hasValidGameSize(Size size) => size.width > 0 && size.height > 0;

  void _scheduleGameLayoutCheck() {
    if (_gameLayoutCheckScheduled) {
      return;
    }
    _gameLayoutCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _gameLayoutReady = true;
        _gameLayoutCheckScheduled = false;
      });
    });
  }

  DroneGame _ensureGame() {
    final existing = _game;
    if (existing != null) {
      return existing;
    }

    final levelConfig = LevelConfig.forMission(widget.missionNumber);
    _missionResult = null;
    final created = DroneGame(
      levelConfig: levelConfig,
      initialPlayerLevel: _readInitialPlayerLevel(),
      onGameOver: _handleGameOver,
      onMissionComplete: _handleMissionComplete,
      onRestart: _playMissionMusic,
    );
    _game = created;
    return created;
  }

  void _scheduleStartCheck() {
    if (_startCheckScheduled) {
      return;
    }
    _startCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _startIfLivesAvailable();
    });
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
    final game = _game;
    if (game == null) {
      return;
    }
    final lives = await ref.read(livesControllerProvider.future);
    if (!mounted || game != _game) {
      return;
    }
    game.updateLives(lives.currentLives);
    if (!lives.hasLives) {
      game.showNoLivesOverlay();
      return;
    }
    _playMissionMusic();
  }

  Future<void> _handleGameOver() async {
    _audioService.stopMusic();
    _audioService.playDefeat();
    final game = _game;
    final lives = await ref.read(livesControllerProvider.notifier).spendLife();
    if (!mounted || game != _game) {
      return;
    }
    game?.updateLives(lives.currentLives);
    if (!lives.hasLives) {
      game?.showNoLivesOverlay();
    }
  }

  Future<MissionResult> _handleMissionComplete(MissionResult result) async {
    if (!mounted) {
      return result;
    }
    setState(() {
      _missionResult = result;
    });
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
      if (!mounted) {
        return result.copyWith(isGuest: false, backendSubmitted: false);
      }
      if (response == null) {
        final failedResult = result.copyWith(
          isGuest: false,
          backendSubmitted: false,
        );
        setState(() {
          _missionResult = failedResult;
        });
        await _unlockAchievementsForMission(failedResult);
        return failedResult;
      }
      final syncedResult = result.copyWith(
        isGuest: false,
        backendSubmitted: true,
        scoreImproved: response.scoreImproved,
        savedBestScore: response.savedBestScore,
        totalPlayerScore: response.totalScore,
        playerLevel: response.playerLevel,
      );
      setState(() {
        _missionResult = syncedResult;
      });
      await _unlockAchievementsForMission(syncedResult);
      return syncedResult;
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
      if (!mounted) {
        return result;
      }
    }
    final guestResult = result.copyWith(isGuest: true, backendSubmitted: false);
    if (mounted) {
      setState(() {
        _missionResult = guestResult;
      });
    }
    await _unlockAchievementsForMission(guestResult);
    return guestResult;
  }

  Future<void> _unlockAchievementsForMission(MissionResult result) async {
    final progress = ref
        .read(progressControllerProvider)
        .asData
        ?.value
        .progress;
    final unlocked = await ref
        .read(achievementsControllerProvider.notifier)
        .evaluateMissionResult(missionResult: result, progress: progress);
    if (!mounted || unlocked.isEmpty) {
      return;
    }
    _showAchievementUnlocked(unlocked);
  }

  void _showAchievementUnlocked(List<UnlockedAchievement> unlocked) {
    final l10n = AppLocalizations.of(context)!;
    final first = unlocked.first;
    final titles = unlocked
        .map((achievement) => achievement.definition.title(l10n))
        .join(', ');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Image.asset(first.definition.iconPath, width: 36, height: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.achievementUnlocked,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(titles, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
