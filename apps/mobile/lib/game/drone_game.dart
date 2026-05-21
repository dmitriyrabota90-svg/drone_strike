import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import 'components/background_layer_component.dart';
import 'components/boundary_component.dart';
import 'components/drone_component.dart';
import 'game_config.dart';
import 'game_state.dart';
import 'systems/mission_progress_system.dart';

class DroneGame extends FlameGame with TapCallbacks {
  DroneGame({
    required this.missionNumber,
    required this.initialPlayerLevel,
    this.onGameOver,
    this.onPause,
    this.onRestart,
  }) : stateNotifier = ValueNotifier(
         DroneGameState(
           missionNumber: missionNumber,
           lives: 3,
           score: 0,
           playerLevel: initialPlayerLevel,
           remainingDistanceMeters: GameConfig.initialRemainingDistanceMeters,
           status: DroneMissionStatus.ready,
         ),
       );

  static const hudOverlay = 'hud';
  static const pauseOverlay = 'pause';
  static const gameOverOverlay = 'gameOver';

  final int missionNumber;
  final int initialPlayerLevel;
  final VoidCallback? onGameOver;
  final VoidCallback? onPause;
  final VoidCallback? onRestart;
  final ValueNotifier<DroneGameState> stateNotifier;

  late final DroneComponent _drone;
  late MissionProgressSystem _progressSystem;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _progressSystem = MissionProgressSystem(
      missionDistanceMeters: GameConfig.missionDistanceMeters,
    );
    await add(BackgroundLayerComponent());
    _drone = DroneComponent()..position = _startPosition();
    await add(_drone);
    await add(
      BoundaryComponent(
        side: BoundarySide.top,
        thickness: GameConfig.topBoundaryHeight,
      ),
    );
    await add(
      BoundaryComponent(
        side: BoundarySide.bottom,
        thickness: GameConfig.bottomBoundaryHeight,
      ),
    );
  }

  @override
  void update(double dt) {
    final status = stateNotifier.value.status;
    if (status != DroneMissionStatus.running) {
      return;
    }

    super.update(dt);
    _progressSystem.update(dt, GameConfig.forwardSpeed);
    _syncState(
      remainingDistanceMeters: _progressSystem.remainingDistanceMeters,
    );
    _checkBoundaryDeath();
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
    _progressSystem.reset();
    _drone.resetTo(_startPosition());
    stateNotifier.value = DroneGameState(
      missionNumber: missionNumber,
      lives: 3,
      score: 0,
      playerLevel: initialPlayerLevel,
      remainingDistanceMeters: GameConfig.initialRemainingDistanceMeters,
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

  Vector2 _startPosition() {
    return Vector2(
      size.x * GameConfig.droneStartXRatio,
      size.y * GameConfig.droneStartYRatio - GameConfig.droneHeight / 2,
    );
  }

  void _checkBoundaryDeath() {
    if (_drone.position.y <= GameConfig.topBoundaryHeight ||
        _drone.position.y + _drone.size.y >=
            size.y - GameConfig.bottomBoundaryHeight) {
      triggerGameOver(reason: 'boundary');
    }
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
