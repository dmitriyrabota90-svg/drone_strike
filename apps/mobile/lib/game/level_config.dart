import 'game_config.dart';

class LevelConfig {
  const LevelConfig({
    required this.missionNumber,
    required this.missionDurationSeconds,
    required this.finalZoneSeconds,
    required this.obstacleCount,
    required this.gapMultiplier,
    required this.forwardSpeed,
    required this.obstacleWidth,
    required this.minObstacleSpacing,
    required this.isTutorial,
  });

  factory LevelConfig.forMission(int missionNumber) {
    final clampedMission = missionNumber.clamp(1, 10).toInt();

    // Temporary balance table for the first playable prototype.
    // These values should be tuned again after real device playtests.
    if (clampedMission == 1) {
      return const LevelConfig(
        missionNumber: 1,
        missionDurationSeconds: 60,
        finalZoneSeconds: 8,
        obstacleCount: 8,
        gapMultiplier: 1.8,
        forwardSpeed: 112,
        obstacleWidth: 72,
        minObstacleSpacing: GameConfig.droneWidth * 3.35,
        isTutorial: true,
      );
    }

    if (clampedMission == 2) {
      return const LevelConfig(
        missionNumber: 2,
        missionDurationSeconds: 60,
        finalZoneSeconds: 8,
        obstacleCount: 10,
        gapMultiplier: 1.6,
        forwardSpeed: 124,
        obstacleWidth: 74,
        minObstacleSpacing: GameConfig.droneWidth * 3.2,
        isTutorial: true,
      );
    }

    final extraObstacles = ((clampedMission - 3) ~/ 2).clamp(0, 3);
    return LevelConfig(
      missionNumber: clampedMission,
      missionDurationSeconds: 60,
      finalZoneSeconds: 8,
      obstacleCount: 12 + extraObstacles,
      gapMultiplier: 1.4,
      forwardSpeed: 132 + (clampedMission - 3) * 3.5,
      obstacleWidth: 76,
      minObstacleSpacing: GameConfig.droneWidth * 3.05,
      isTutorial: false,
    );
  }

  final int missionNumber;
  final double missionDurationSeconds;
  final double finalZoneSeconds;
  final int obstacleCount;
  final double gapMultiplier;
  final double forwardSpeed;
  final double obstacleWidth;
  final double minObstacleSpacing;
  final bool isTutorial;

  double get finalZoneDistance => forwardSpeed * finalZoneSeconds;

  double get obstacleZoneDistance => forwardSpeed * missionDurationSeconds;

  double get missionDistanceMeters => obstacleZoneDistance + finalZoneDistance;

  double get droneStartXRatio => GameConfig.droneStartXRatio;

  double get droneStartYRatio => GameConfig.droneStartYRatio;

  double get droneHeight => GameConfig.droneHeight;

  double get topBoundaryHeight => GameConfig.topBoundaryHeight;

  double get bottomBoundaryHeight => GameConfig.bottomBoundaryHeight;
}
