enum DroneMissionStatus { ready, running, paused, gameOver, completed }

class DroneGameState {
  const DroneGameState({
    required this.missionNumber,
    required this.lives,
    required this.score,
    required this.batteryBonus,
    required this.playerLevel,
    required this.remainingDistanceMeters,
    required this.status,
  });

  final int missionNumber;
  final int lives;
  final int score;
  final int batteryBonus;
  final int playerLevel;
  final double remainingDistanceMeters;
  final DroneMissionStatus status;

  DroneGameState copyWith({
    int? missionNumber,
    int? lives,
    int? score,
    int? batteryBonus,
    int? playerLevel,
    double? remainingDistanceMeters,
    DroneMissionStatus? status,
  }) {
    return DroneGameState(
      missionNumber: missionNumber ?? this.missionNumber,
      lives: lives ?? this.lives,
      score: score ?? this.score,
      batteryBonus: batteryBonus ?? this.batteryBonus,
      playerLevel: playerLevel ?? this.playerLevel,
      remainingDistanceMeters:
          remainingDistanceMeters ?? this.remainingDistanceMeters,
      status: status ?? this.status,
    );
  }
}
