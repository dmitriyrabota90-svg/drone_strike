class GameConfig {
  const GameConfig._();

  // Main physics profile used after onboarding. Early missions blend into this
  // profile so new players get a softer first contact without losing the
  // skill-based FPV correction feel later.
  static const gravity = 460.0;
  static const tapImpulse = -235.0;
  static const startTapImpulse = -135.0;
  static const startGraceSeconds = 1.25;
  static const maxFallSpeed = 390.0;
  static const maxRiseSpeed = -285.0;
  static const droneStartXRatio = 0.22;
  static const droneStartYRatio = 0.62;
  static const droneWidth = 84.0;
  static const droneHeight = 48.0;
  static const droneHitboxInsetX = 16.0;
  static const droneHitboxInsetY = 12.0;
  static const forwardSpeed = 140.0;
  // Reserved top strip for the Flutter HUD. Gameplay hazards start below it so
  // ceiling nets and the top death boundary are never hidden by the overlay.
  static const gameplayTopSafeInset = 42.0;
  static const topBoundaryHeight = 6.0;
  static const bottomBoundaryHeight = 8.0;
  static const topBoundaryY = gameplayTopSafeInset;
  static const playableTopY = topBoundaryY + topBoundaryHeight;
  static const treeHitboxInsetXRatio = 0.22;
  static const treeHitboxTopInset = 8.0;
  static const treeHitboxBottomInset = 8.0;
  static const netHitboxInsetXRatio = 0.12;
  static const netHitboxTopInset = 4.0;
  static const netHitboxBottomInset = 8.0;
  static const tankGroundSink = 20.0;
  static const batteryWidth = 40.8;
  static const batteryHeight = 26.4;
  static const batteryCollectRadius = 24.0;
  static const tankExplosionDelaySeconds = 1.2;
  static const missionDistanceMeters = 1000.0;
  static const initialRemainingDistanceMeters = 1000.0;

  static DronePhysicsProfile physicsForMission(int missionNumber) {
    final progress = ((missionNumber.clamp(1, 10) - 1) / 9).toDouble();
    final eased = progress * progress * (3 - 2 * progress);
    return DronePhysicsProfile(
      gravity: _lerp(395.0, gravity, eased),
      tapImpulse: _lerp(-205.0, tapImpulse, eased),
      startTapImpulse: _lerp(-105.0, startTapImpulse, eased),
      maxFallSpeed: _lerp(330.0, maxFallSpeed, eased),
      maxRiseSpeed: _lerp(-245.0, maxRiseSpeed, eased),
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}

class DronePhysicsProfile {
  const DronePhysicsProfile({
    required this.gravity,
    required this.tapImpulse,
    required this.startTapImpulse,
    required this.maxFallSpeed,
    required this.maxRiseSpeed,
  });

  final double gravity;
  final double tapImpulse;
  final double startTapImpulse;
  final double maxFallSpeed;
  final double maxRiseSpeed;
}
