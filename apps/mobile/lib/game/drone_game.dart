import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import 'components/background_layer_component.dart';
import 'components/boundary_component.dart';
import 'components/drone_component.dart';
import 'components/obstacle_pair_component.dart';
import 'components/tank_component.dart';
import 'game_state.dart';
import 'level_config.dart';
import 'systems/level_generator.dart';
import 'systems/mission_progress_system.dart';

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

  final LevelConfig levelConfig;
  final int initialPlayerLevel;
  final VoidCallback? onGameOver;
  final VoidCallback? onMissionComplete;
  final VoidCallback? onPause;
  final VoidCallback? onRestart;
  final ValueNotifier<DroneGameState> stateNotifier;

  late final DroneComponent _drone;
  late MissionProgressSystem _progressSystem;
  late List<ObstaclePairComponent> _obstaclePairs;
  late TankComponent _tank;
  double _worldOffset = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _progressSystem = MissionProgressSystem(
      missionDistanceMeters: levelConfig.missionDistanceMeters,
    );
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
    _progressSystem.update(dt, levelConfig.forwardSpeed);
    _worldOffset = _progressSystem.currentDistanceMeters;
    _updateWorldComponents();
    _syncState(
      remainingDistanceMeters: _progressSystem.remainingDistanceMeters,
    );
    _checkBoundaryDeath();
    _checkObstacleDeath();
    _checkTankOutcome();
  }

  @override
  void onTapDown(TapDownEvent event) {
    final status = stateNotifier.value.status;
    if (status == DroneMissionStatus.ready) {
      _syncState(status: DroneMissionStatus.running);
      _drone.boost();
      return;
    }
    if (status == DroneMissionStatus.running) {
      _drone.boost();
    }
  }

  void pauseGame() {
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
    if (stateNotifier.value.status != DroneMissionStatus.paused) {
      return;
    }
    overlays.remove(pauseOverlay);
    _syncState(status: DroneMissionStatus.running);
  }

  void restart() {
    overlays.remove(pauseOverlay);
    overlays.remove(gameOverOverlay);
    overlays.remove(missionCompleteOverlay);
    _progressSystem.reset();
    _worldOffset = 0;
    _drone.resetTo(_startPosition());
    _updateWorldComponents();
    stateNotifier.value = DroneGameState(
      missionNumber: levelConfig.missionNumber,
      lives: 3,
      score: 0,
      playerLevel: initialPlayerLevel,
      remainingDistanceMeters: levelConfig.missionDistanceMeters,
      status: DroneMissionStatus.ready,
    );
    onRestart?.call();
  }

  void triggerGameOver({String? reason}) {
    if (stateNotifier.value.status == DroneMissionStatus.gameOver) {
      return;
    }
    _syncState(status: DroneMissionStatus.gameOver);
    overlays.remove(pauseOverlay);
    overlays.add(gameOverOverlay);
    onGameOver?.call();
  }

  void triggerMissionComplete() {
    if (stateNotifier.value.status == DroneMissionStatus.completed) {
      return;
    }
    _syncState(
      status: DroneMissionStatus.completed,
      remainingDistanceMeters: 0,
    );
    overlays.remove(pauseOverlay);
    overlays.remove(gameOverOverlay);
    overlays.add(missionCompleteOverlay);
    onMissionComplete?.call();
  }

  Vector2 _startPosition() {
    return Vector2(
      size.x * levelConfig.droneStartXRatio,
      size.y * levelConfig.droneStartYRatio - levelConfig.droneHeight / 2,
    );
  }

  void _checkBoundaryDeath() {
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

  void _updateWorldComponents() {
    for (final pair in _obstaclePairs) {
      pair.updateWorld(worldOffset: _worldOffset, viewportHeight: size.y);
    }
    _tank.updateWorld(worldOffset: _worldOffset, viewportHeight: size.y);
  }

  Rect get _droneRect {
    return Rect.fromLTWH(
      _drone.position.x + 5,
      _drone.position.y + 4,
      _drone.size.x - 10,
      _drone.size.y - 8,
    );
  }

  void _syncState({
    double? remainingDistanceMeters,
    DroneMissionStatus? status,
  }) {
    stateNotifier.value = stateNotifier.value.copyWith(
      remainingDistanceMeters: remainingDistanceMeters,
      status: status,
    );
  }

  @override
  void onRemove() {
    stateNotifier.dispose();
    super.onRemove();
  }
}
