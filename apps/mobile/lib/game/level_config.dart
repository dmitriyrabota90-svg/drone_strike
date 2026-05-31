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

  DronePhysicsProfile get physics => GameConfig.physicsForMission(missionNumber);

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
    // Long campaign tuning: speed grows slowly for the first 20-30 missions
    // and then tapers toward a high-level cap. Density, gaps and obstacle
    // variety carry difficulty so level 8 is still readable while level 150
    // can feel meaningfully faster.
    final forwardSpeed = _forwardSpeedForMission(missionNumber);
    return switch (missionNumber) {
      1 => _MissionBalance(
        minGapMultiplier: 4.1,
        maxGapMultiplier: 6.5,
        forwardSpeed: forwardSpeed,
        obstacleCount: 8,
        batteryCount: 3,
        minObstacleSpacing: 320.0,
        maxObstacleSpacing: 520.0,
        obstacleWidth: 70.0,
      ),
      2 => _MissionBalance(
        minGapMultiplier: 3.7,
        maxGapMultiplier: 6.0,
        forwardSpeed: forwardSpeed,
        obstacleCount: 10,
        batteryCount: 4,
        minObstacleSpacing: 300.0,
        maxObstacleSpacing: 500.0,
        obstacleWidth: 72.0,
      ),
      3 => _MissionBalance(
        minGapMultiplier: 3.2,
        maxGapMultiplier: 5.4,
        forwardSpeed: forwardSpeed,
        obstacleCount: 12,
        batteryCount: 5,
        minObstacleSpacing: 280.0,
        maxObstacleSpacing: 470.0,
        obstacleWidth: 74.0,
      ),
      4 => _MissionBalance(
        minGapMultiplier: 3.0,
        maxGapMultiplier: 5.0,
        forwardSpeed: forwardSpeed,
        obstacleCount: 14,
        batteryCount: 6,
        minObstacleSpacing: 260.0,
        maxObstacleSpacing: 450.0,
        obstacleWidth: 74.0,
      ),
      5 => _MissionBalance(
        minGapMultiplier: 2.8,
        maxGapMultiplier: 4.6,
        forwardSpeed: forwardSpeed,
        obstacleCount: 16,
        batteryCount: 6,
        minObstacleSpacing: 240.0,
        maxObstacleSpacing: 430.0,
        obstacleWidth: 76.0,
      ),
      6 => _MissionBalance(
        minGapMultiplier: 2.6,
        maxGapMultiplier: 4.2,
        forwardSpeed: forwardSpeed,
        obstacleCount: 18,
        batteryCount: 7,
        minObstacleSpacing: 230.0,
        maxObstacleSpacing: 410.0,
        obstacleWidth: 76.0,
      ),
      7 => _MissionBalance(
        minGapMultiplier: 2.4,
        maxGapMultiplier: 3.9,
        forwardSpeed: forwardSpeed,
        obstacleCount: 20,
        batteryCount: 7,
        minObstacleSpacing: 220.0,
        maxObstacleSpacing: 390.0,
        obstacleWidth: 76.0,
      ),
      _ => _MissionBalance(
        minGapMultiplier: 2.3,
        maxGapMultiplier: 3.6,
        forwardSpeed: forwardSpeed,
        obstacleCount: 22,
        batteryCount: 8,
        minObstacleSpacing: 210.0,
        maxObstacleSpacing: 370.0,
        obstacleWidth: 78.0,
      ),
    };
  }

  static double _forwardSpeedForMission(int missionNumber) {
    if (missionNumber <= 1) {
      return 108.0;
    }
    if (missionNumber <= 10) {
      return 108.0 + (missionNumber - 1) * 4.2;
    }
    if (missionNumber <= 30) {
      return 145.8 + (missionNumber - 10) * 1.7;
    }
    if (missionNumber <= 80) {
      return 179.8 + (missionNumber - 30) * 0.62;
    }
    return (210.8 + (missionNumber - 80) * 0.26)
        .clamp(210.8, 232.0)
        .toDouble();
  }
}
