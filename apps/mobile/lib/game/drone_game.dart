import 'dart:async';
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../core/assets/app_assets.dart';
import 'components/background_layer_component.dart';
import 'components/boundary_component.dart';
import 'components/drone_component.dart';
import 'components/obstacle_pair_component.dart';
import 'components/tank_component.dart';
import 'game_config.dart';
import 'game_image_cache.dart';
import 'game_state.dart';
import 'level_config.dart';
import 'systems/level_generator.dart';
import 'systems/mission_progress_system.dart';
import 'systems/scoring_system.dart';

typedef GameOverCallback = Future<void> Function();
typedef MissionCompleteCallback =
    Future<MissionResult> Function(MissionResult result);

class DroneGame extends FlameGame with TapCallbacks {
  DroneGame({
    required this.levelConfig,
    required this.initialPlayerLevel,
    this.onGameOver,
    this.onMissionComplete,
    this.onPause,
    this.onRestart,
  }) : stateNotifier = ValueNotifier(
         DroneGameState(
           missionNumber: levelConfig.missionNumber,
           lives: 3,
           score: 0,
           playerLevel: initialPlayerLevel,
           remainingDistanceMeters: levelConfig.missionDistanceMeters,
           status: DroneMissionStatus.ready,
         ),
       );

  static const hudOverlay = 'hud';
  static const pauseOverlay = 'pause';
  static const gameOverOverlay = 'gameOver';
  static const missionCompleteOverlay = 'missionComplete';
  static const noLivesOverlay = 'noLives';

  final LevelConfig levelConfig;
  final int initialPlayerLevel;
  final GameOverCallback? onGameOver;
  final MissionCompleteCallback? onMissionComplete;
  final VoidCallback? onPause;
  final VoidCallback? onRestart;
  final ValueNotifier<DroneGameState> stateNotifier;

  late final DroneComponent _drone;
  late MissionProgressSystem _progressSystem;
  late ScoringSystem _scoringSystem;
  late List<ObstaclePairComponent> _obstaclePairs;
  late TankComponent _tank;
  double _worldOffset = 0;
  double _startGraceRemaining = 0;
  bool _isDisposed = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    unawaited(GameImageCache.precache(AppAssets.gameImageAssets));

    _progressSystem = MissionProgressSystem(
      missionDistanceMeters: levelConfig.missionDistanceMeters,
    );
    _scoringSystem = ScoringSystem();
    await add(BackgroundLayerComponent(forwardSpeed: levelConfig.forwardSpeed));
    _drone = DroneComponent()..position = _startPosition();
    final generatedLevel = const LevelGenerator().generate(
      config: levelConfig,
      viewportSize: size,
    );
    _obstaclePairs = generatedLevel.obstaclePairs;
    _tank = generatedLevel.tank;

    for (final pair in _obstaclePairs) {
      await add(pair);
    }
    await add(_tank);
    await add(
      BoundaryComponent(
        side: BoundarySide.top,
        thickness: levelConfig.topBoundaryHeight,
      ),
    );
    await add(
      BoundaryComponent(
        side: BoundarySide.bottom,
        thickness: levelConfig.bottomBoundaryHeight,
      ),
    );
    await add(_drone);
    _updateWorldComponents();
  }

  @override
  void update(double dt) {
    final status = stateNotifier.value.status;
    if (status != DroneMissionStatus.running) {
      return;
    }

    super.update(dt);
    if (_startGraceRemaining > 0) {
      _startGraceRemaining = (_startGraceRemaining - dt).clamp(
        0.0,
        double.infinity,
      );
    }
    _progressSystem.update(dt, levelConfig.forwardSpeed);
    _worldOffset = _progressSystem.currentDistanceMeters;
    _updateWorldComponents();
    _syncState(
      remainingDistanceMeters: _progressSystem.remainingDistanceMeters,
    );
    _recordFlightAccuracy();
    _checkBoundaryDeath();
    if (stateNotifier.value.status != DroneMissionStatus.running) {
      return;
    }
    _checkObstacleDeath();
    if (stateNotifier.value.status != DroneMissionStatus.running) {
      return;
    }
    _checkTankOutcome();
  }

  @override
  void onTapDown(TapDownEvent event) {
    handleFieldTap();
  }

  void handleFieldTap() {
    if (_isDisposed) {
      return;
    }
    final status = stateNotifier.value.status;
    if (status == DroneMissionStatus.ready) {
      _syncState(status: DroneMissionStatus.running);
      _startGraceRemaining = GameConfig.startGraceSeconds;
      _drone.startBoost();
      return;
    }
    if (status == DroneMissionStatus.running) {
      _drone.boost();
    }
  }

  void pauseGame() {
    if (_isDisposed) {
      return;
    }
    final status = stateNotifier.value.status;
    if (status == DroneMissionStatus.gameOver ||
        status == DroneMissionStatus.paused) {
      return;
    }
    _syncState(status: DroneMissionStatus.paused);
    overlays.add(pauseOverlay);
    onPause?.call();
  }

  void resumeGame() {
    if (_isDisposed) {
      return;
    }
    if (stateNotifier.value.status != DroneMissionStatus.paused) {
      return;
    }
    overlays.remove(pauseOverlay);
    _syncState(status: DroneMissionStatus.running);
  }

  void restart() {
    if (_isDisposed) {
      return;
    }
    final currentLives = stateNotifier.value.lives;
    overlays.remove(pauseOverlay);
    overlays.remove(gameOverOverlay);
    overlays.remove(missionCompleteOverlay);
    overlays.remove(noLivesOverlay);
    _progressSystem.reset();
    _scoringSystem = ScoringSystem();
    _worldOffset = 0;
    _startGraceRemaining = 0;
    _drone.resetTo(_startPosition());
    _updateWorldComponents();
    stateNotifier.value = DroneGameState(
      missionNumber: levelConfig.missionNumber,
      lives: currentLives,
      score: 0,
      playerLevel: initialPlayerLevel,
      remainingDistanceMeters: levelConfig.missionDistanceMeters,
      status: DroneMissionStatus.ready,
    );
    onRestart?.call();
  }

  void triggerGameOver({String? reason}) {
    if (_isDisposed) {
      return;
    }
    if (stateNotifier.value.status == DroneMissionStatus.gameOver) {
      return;
    }
    _syncState(status: DroneMissionStatus.gameOver);
    overlays.remove(pauseOverlay);
    overlays.add(gameOverOverlay);
    onGameOver?.call();
  }

  void triggerMissionComplete() {
    if (_isDisposed) {
      return;
    }
    if (stateNotifier.value.status == DroneMissionStatus.completed) {
      return;
    }
    final localResult = _scoringSystem.buildMissionResult(
      missionNumber: levelConfig.missionNumber,
      tankHitBonus: _scoringSystem.calculateTankHitBonus(
        droneCenter: _droneRect.center,
        tankRect: _tank.collisionRect,
      ),
      isGuest: true,
    );
    _syncState(
      status: DroneMissionStatus.completed,
      remainingDistanceMeters: 0,
    );
    overlays.remove(pauseOverlay);
    overlays.remove(gameOverOverlay);
    overlays.add(missionCompleteOverlay);
    final sync = onMissionComplete;
    if (sync == null) {
      return;
    }
    sync(localResult).catchError((Object error, StackTrace stackTrace) {
      debugPrint('Mission result sync failed: $error');
      debugPrint('$stackTrace');
      return localResult;
    });
  }

  Vector2 _startPosition() {
    return Vector2(
      size.x * levelConfig.droneStartXRatio,
      size.y * levelConfig.droneStartYRatio - levelConfig.droneHeight / 2,
    );
  }

  void _checkBoundaryDeath() {
    if (_startGraceRemaining > 0) {
      return;
    }
    if (_drone.position.y <= levelConfig.topBoundaryHeight ||
        _drone.position.y + _drone.size.y >=
            size.y - levelConfig.bottomBoundaryHeight) {
      triggerGameOver(reason: 'boundary');
    }
  }

  void _checkObstacleDeath() {
    final droneRect = _droneRect;
    for (final pair in _obstaclePairs) {
      if (pair.tree.collisionRect.overlaps(droneRect) ||
          pair.net.collisionRect.overlaps(droneRect)) {
        triggerGameOver(reason: 'obstacle');
        return;
      }
    }
  }

  void _checkTankOutcome() {
    final droneRect = _droneRect;
    if (_tank.collisionRect.overlaps(droneRect)) {
      triggerMissionComplete();
      return;
    }
    if (_tank.missedDroneFailSafe) {
      triggerGameOver(reason: 'missed_tank');
    }
  }

  void updateLives(int currentLives) {
    if (_isDisposed) {
      return;
    }
    _syncState(lives: currentLives);
  }

  void showNoLivesOverlay() {
    if (_isDisposed) {
      return;
    }
    overlays.remove(gameOverOverlay);
    overlays.remove(pauseOverlay);
    overlays.add(noLivesOverlay);
  }

  void _recordFlightAccuracy() {
    ObstaclePairComponent? nearestPair;
    var nearestDistance = double.infinity;

    for (final pair in _obstaclePairs) {
      final distance = (pair.screenCenterX - _droneRect.center.dx).abs();
      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearestPair = pair;
      }
    }

    if (nearestPair == null || nearestDistance > 150) {
      return;
    }

    _scoringSystem.recordAccuracySample(
      droneCenterY: _droneRect.center.dy,
      gapCenterY: nearestPair.gapCenterY,
      gapHeight: nearestPair.gapHeight,
    );
  }

  void _updateWorldComponents() {
    for (final pair in _obstaclePairs) {
      pair.updateWorld(worldOffset: _worldOffset, viewportHeight: size.y);
    }
    _tank.updateWorld(worldOffset: _worldOffset, viewportHeight: size.y);
  }

  Rect get _droneRect {
    return Rect.fromLTWH(
      _drone.position.x + 8,
      _drone.position.y + 7,
      _drone.size.x - 16,
      _drone.size.y - 14,
    );
  }

  void _syncState({
    int? lives,
    double? remainingDistanceMeters,
    DroneMissionStatus? status,
  }) {
    if (_isDisposed) {
      return;
    }
    stateNotifier.value = stateNotifier.value.copyWith(
      lives: lives,
      remainingDistanceMeters: remainingDistanceMeters,
      status: status,
    );
  }

  @override
  void onRemove() {
    _isDisposed = true;
    stateNotifier.dispose();
    super.onRemove();
  }
}
