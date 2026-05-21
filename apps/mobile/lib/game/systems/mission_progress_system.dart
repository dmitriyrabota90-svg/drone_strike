import 'dart:math' as math;

class MissionProgressSystem {
  MissionProgressSystem({required this.missionDistanceMeters});

  final double missionDistanceMeters;
  double currentDistanceMeters = 0;

  void update(double dt, double forwardSpeed) {
    currentDistanceMeters = math.min(
      missionDistanceMeters,
      currentDistanceMeters + forwardSpeed * dt,
    );
  }

  double get remainingDistanceMeters {
    return math.max(0, missionDistanceMeters - currentDistanceMeters);
  }

  void reset() {
    currentDistanceMeters = 0;
  }
}
