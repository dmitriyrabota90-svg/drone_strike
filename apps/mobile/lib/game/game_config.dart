class GameConfig {
  const GameConfig._();

  // Temporary physics values. They will be balanced after real device testing.
  static const gravity = 650.0;
  static const tapImpulse = -330.0;
  static const droneStartXRatio = 0.23;
  static const droneStartYRatio = 0.48;
  static const droneWidth = 56.0;
  static const droneHeight = 32.0;
  static const forwardSpeed = 140.0;
  static const topBoundaryHeight = 8.0;
  static const bottomBoundaryHeight = 8.0;
  static const missionDistanceMeters = 1000.0;
  static const initialRemainingDistanceMeters = 1000.0;
}
