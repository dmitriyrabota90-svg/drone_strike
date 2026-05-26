class GameConfig {
  const GameConfig._();

  // Temporary physics values tuned after early manual tests.
  // The goal is FPV-glide correction rather than hard Flappy-style snapping.
  static const gravity = 460.0;
  static const tapImpulse = -235.0;
  static const startTapImpulse = -135.0;
  static const startGraceSeconds = 1.25;
  static const maxFallSpeed = 390.0;
  static const maxRiseSpeed = -285.0;
  static const droneStartXRatio = 0.22;
  static const droneStartYRatio = 0.50;
  static const droneWidth = 84.0;
  static const droneHeight = 48.0;
  static const droneHitboxInsetX = 16.0;
  static const droneHitboxInsetY = 12.0;
  static const forwardSpeed = 140.0;
  // Reserved top strip for the Flutter HUD. Gameplay hazards start below it so
  // ceiling nets and the top death boundary are never hidden by the overlay.
  static const gameplayTopSafeInset = 76.0;
  static const topBoundaryHeight = 8.0;
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
}
