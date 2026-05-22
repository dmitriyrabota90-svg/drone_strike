class GameConfig {
  const GameConfig._();

  // Temporary physics values tuned after early manual tests.
  // The goal is FPV-glide correction rather than hard Flappy-style snapping.
  static const gravity = 460.0;
  static const tapImpulse = -235.0;
  static const startTapImpulse = -135.0;
  static const startGraceSeconds = 0.45;
  static const maxFallSpeed = 390.0;
  static const maxRiseSpeed = -285.0;
  static const droneStartXRatio = 0.22;
  static const droneStartYRatio = 0.50;
  static const droneWidth = 84.0;
  static const droneHeight = 48.0;
  static const droneHitboxInsetX = 12.0;
  static const droneHitboxInsetY = 10.5;
  static const forwardSpeed = 140.0;
  static const topBoundaryHeight = 8.0;
  static const bottomBoundaryHeight = 8.0;
  static const missionDistanceMeters = 1000.0;
  static const initialRemainingDistanceMeters = 1000.0;
}
