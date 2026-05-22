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
    final balance = _MissionBalance.forMission(clampedMission);

    return LevelConfig(
      missionNumber: clampedMission,
      missionDurationSeconds: 60,
      finalZoneSeconds: 2.75,
      obstacleCount: balance.obstacleCount,
      gapMultiplier: balance.gapMultiplier,
      forwardSpeed: balance.forwardSpeed,
      obstacleWidth: balance.obstacleWidth,
      minObstacleSpacing: GameConfig.droneWidth * balance.spacingMultiplier,
      isTutorial: clampedMission <= 2,
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

class _MissionBalance {
  const _MissionBalance({
    required this.gapMultiplier,
    required this.forwardSpeed,
    required this.obstacleCount,
    required this.spacingMultiplier,
    required this.obstacleWidth,
  });

  final double gapMultiplier;
  final double forwardSpeed;
  final int obstacleCount;
  final double spacingMultiplier;
  final double obstacleWidth;

  static _MissionBalance forMission(int missionNumber) {
    // First 10 missions are deliberately introductory for a 100+ mission plan.
    // Gap 1.4 is reserved as a TODO for later level 30+ difficulty, not MVP.
    return switch (missionNumber) {
      1 => const _MissionBalance(
        gapMultiplier: 2.8,
        forwardSpeed: 110.0,
        obstacleCount: 7,
        spacingMultiplier: 4.1,
        obstacleWidth: 70.0,
      ),
      2 => const _MissionBalance(
        gapMultiplier: 2.6,
        forwardSpeed: 120.0,
        obstacleCount: 9,
        spacingMultiplier: 4.0,
        obstacleWidth: 72.0,
      ),
      3 => const _MissionBalance(
        gapMultiplier: 2.4,
        forwardSpeed: 130.0,
        obstacleCount: 10,
        spacingMultiplier: 4.0,
        obstacleWidth: 74.0,
      ),
      4 => const _MissionBalance(
        gapMultiplier: 2.3,
        forwardSpeed: 140.0,
        obstacleCount: 11,
        spacingMultiplier: 3.85,
        obstacleWidth: 74.0,
      ),
      5 => const _MissionBalance(
        gapMultiplier: 2.2,
        forwardSpeed: 150.0,
        obstacleCount: 11,
        spacingMultiplier: 3.75,
        obstacleWidth: 76.0,
      ),
      6 => const _MissionBalance(
        gapMultiplier: 2.15,
        forwardSpeed: 158.0,
        obstacleCount: 12,
        spacingMultiplier: 3.65,
        obstacleWidth: 76.0,
      ),
      7 => const _MissionBalance(
        gapMultiplier: 2.1,
        forwardSpeed: 166.0,
        obstacleCount: 12,
        spacingMultiplier: 3.6,
        obstacleWidth: 76.0,
      ),
      8 => const _MissionBalance(
        gapMultiplier: 2.05,
        forwardSpeed: 174.0,
        obstacleCount: 13,
        spacingMultiplier: 3.55,
        obstacleWidth: 78.0,
      ),
      9 => const _MissionBalance(
        gapMultiplier: 2.0,
        forwardSpeed: 182.0,
        obstacleCount: 14,
        spacingMultiplier: 3.5,
        obstacleWidth: 78.0,
      ),
      _ => const _MissionBalance(
        gapMultiplier: 2.0,
        forwardSpeed: 188.0,
        obstacleCount: 15,
        spacingMultiplier: 3.5,
        obstacleWidth: 78.0,
      ),
    };
  }
}
