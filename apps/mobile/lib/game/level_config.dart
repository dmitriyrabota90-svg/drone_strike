import 'game_config.dart';

class LevelConfig {
  const LevelConfig({
    required this.missionNumber,
    required this.missionDurationSeconds,
    required this.finalZoneSeconds,
    required this.obstacleCount,
    required this.batteryCount,
    required this.gapMultiplier,
    required this.minGapMultiplier,
    required this.maxGapMultiplier,
    required this.forwardSpeed,
    required this.obstacleWidth,
    required this.minObstacleSpacing,
    required this.maxObstacleSpacing,
    required this.isTutorial,
  });

  factory LevelConfig.forMission(int missionNumber) {
    final clampedMission = missionNumber < 1 ? 1 : missionNumber;
    final balance = _MissionBalance.forMission(clampedMission);

    return LevelConfig(
      missionNumber: clampedMission,
      missionDurationSeconds: 60,
      finalZoneSeconds: 2.75,
      obstacleCount: balance.obstacleCount,
      batteryCount: balance.batteryCount,
      gapMultiplier: balance.maxGapMultiplier,
      minGapMultiplier: balance.minGapMultiplier,
      maxGapMultiplier: balance.maxGapMultiplier,
      forwardSpeed: balance.forwardSpeed,
      obstacleWidth: balance.obstacleWidth,
      minObstacleSpacing: balance.minObstacleSpacing,
      maxObstacleSpacing: balance.maxObstacleSpacing,
      isTutorial: clampedMission <= 2,
    );
  }

  final int missionNumber;
  final double missionDurationSeconds;
  final double finalZoneSeconds;
  final int obstacleCount;
  final int batteryCount;
  final double gapMultiplier;
  final double minGapMultiplier;
  final double maxGapMultiplier;
  final double forwardSpeed;
  final double obstacleWidth;
  final double minObstacleSpacing;
  final double maxObstacleSpacing;
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

class _MissionBalance {
  const _MissionBalance({
    required this.minGapMultiplier,
    required this.maxGapMultiplier,
    required this.forwardSpeed,
    required this.obstacleCount,
    required this.batteryCount,
    required this.minObstacleSpacing,
    required this.maxObstacleSpacing,
    required this.obstacleWidth,
  });

  final double minGapMultiplier;
  final double maxGapMultiplier;
  final double forwardSpeed;
  final int obstacleCount;
  final int batteryCount;
  final double minObstacleSpacing;
  final double maxObstacleSpacing;
  final double obstacleWidth;

  static _MissionBalance forMission(int missionNumber) {
    // Focused gameplay tuning: obstacle count and spacing ranges are explicit
    // so later missions become visibly denser without relying on old long-zone
    // distribution. Gap 2.3 is the MVP floor.
    return switch (missionNumber) {
      1 => const _MissionBalance(
        minGapMultiplier: 4.1,
        maxGapMultiplier: 6.5,
        forwardSpeed: 110.0,
        obstacleCount: 8,
        batteryCount: 3,
        minObstacleSpacing: 320.0,
        maxObstacleSpacing: 520.0,
        obstacleWidth: 70.0,
      ),
      2 => const _MissionBalance(
        minGapMultiplier: 3.7,
        maxGapMultiplier: 6.0,
        forwardSpeed: 120.0,
        obstacleCount: 10,
        batteryCount: 4,
        minObstacleSpacing: 300.0,
        maxObstacleSpacing: 500.0,
        obstacleWidth: 72.0,
      ),
      3 => const _MissionBalance(
        minGapMultiplier: 3.2,
        maxGapMultiplier: 5.4,
        forwardSpeed: 130.0,
        obstacleCount: 12,
        batteryCount: 5,
        minObstacleSpacing: 280.0,
        maxObstacleSpacing: 470.0,
        obstacleWidth: 74.0,
      ),
      4 => const _MissionBalance(
        minGapMultiplier: 3.0,
        maxGapMultiplier: 5.0,
        forwardSpeed: 140.0,
        obstacleCount: 14,
        batteryCount: 6,
        minObstacleSpacing: 260.0,
        maxObstacleSpacing: 450.0,
        obstacleWidth: 74.0,
      ),
      5 => const _MissionBalance(
        minGapMultiplier: 2.8,
        maxGapMultiplier: 4.6,
        forwardSpeed: 150.0,
        obstacleCount: 16,
        batteryCount: 6,
        minObstacleSpacing: 240.0,
        maxObstacleSpacing: 430.0,
        obstacleWidth: 76.0,
      ),
      6 => const _MissionBalance(
        minGapMultiplier: 2.6,
        maxGapMultiplier: 4.2,
        forwardSpeed: 158.0,
        obstacleCount: 18,
        batteryCount: 7,
        minObstacleSpacing: 230.0,
        maxObstacleSpacing: 410.0,
        obstacleWidth: 76.0,
      ),
      7 => const _MissionBalance(
        minGapMultiplier: 2.4,
        maxGapMultiplier: 3.9,
        forwardSpeed: 166.0,
        obstacleCount: 20,
        batteryCount: 7,
        minObstacleSpacing: 220.0,
        maxObstacleSpacing: 390.0,
        obstacleWidth: 76.0,
      ),
      _ => const _MissionBalance(
        minGapMultiplier: 2.3,
        maxGapMultiplier: 3.6,
        forwardSpeed: 174.0,
        obstacleCount: 22,
        batteryCount: 8,
        minObstacleSpacing: 210.0,
        maxObstacleSpacing: 370.0,
        obstacleWidth: 78.0,
      ),
    };
  }
}
