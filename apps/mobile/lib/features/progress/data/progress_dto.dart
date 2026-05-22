class MissionProgressItemDto {
  const MissionProgressItemDto({
    required this.missionNumber,
    required this.bestScore,
    required this.bestFlightAccuracyBonus,
    required this.bestTankHitBonus,
    required this.completedAt,
  });

  final int missionNumber;
  final int bestScore;
  final int bestFlightAccuracyBonus;
  final int bestTankHitBonus;
  final DateTime? completedAt;

  factory MissionProgressItemDto.fromJson(Map<String, dynamic> json) {
    final completedAt = json['completed_at'] as String?;
    return MissionProgressItemDto(
      missionNumber: json['mission_number'] as int,
      bestScore: json['best_score'] as int,
      bestFlightAccuracyBonus: json['best_flight_accuracy_bonus'] as int,
      bestTankHitBonus: json['best_tank_hit_bonus'] as int,
      completedAt: completedAt == null ? null : DateTime.parse(completedAt),
    );
  }
}

class ProgressResponseDto {
  const ProgressResponseDto({
    required this.totalScore,
    required this.playerLevel,
    required this.completedMissionsCount,
    required this.unlockedMission,
    required this.missions,
  });

  const ProgressResponseDto.guest()
    : totalScore = 0,
      playerLevel = 1,
      completedMissionsCount = 0,
      unlockedMission = 2,
      missions = const [];

  final int totalScore;
  final int playerLevel;
  final int completedMissionsCount;
  final int unlockedMission;
  final List<MissionProgressItemDto> missions;

  factory ProgressResponseDto.fromJson(Map<String, dynamic> json) {
    final missions = json['missions'] as List<dynamic>? ?? const [];
    return ProgressResponseDto(
      totalScore: json['total_score'] as int,
      playerLevel: json['player_level'] as int,
      completedMissionsCount: json['completed_missions_count'] as int,
      unlockedMission: json['unlocked_mission'] as int,
      missions: missions
          .map(
            (item) => MissionProgressItemDto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }

  MissionProgressItemDto? missionByNumber(int missionNumber) {
    for (final mission in missions) {
      if (mission.missionNumber == missionNumber) {
        return mission;
      }
    }
    return null;
  }
}

class MissionCompleteRequestDto {
  const MissionCompleteRequestDto({
    required this.missionNumber,
    required this.flightAccuracyBonus,
    required this.tankHitBonus,
  });

  final int missionNumber;
  final int flightAccuracyBonus;
  final int tankHitBonus;

  Map<String, dynamic> toJson() => {
    'mission_number': missionNumber,
    'flight_accuracy_bonus': flightAccuracyBonus,
    'tank_hit_bonus': tankHitBonus,
  };
}

class MissionCompleteResponseDto {
  const MissionCompleteResponseDto({
    required this.missionNumber,
    required this.submittedScore,
    required this.previousBestScore,
    required this.savedBestScore,
    required this.scoreImproved,
    required this.totalScore,
    required this.playerLevel,
    required this.unlockedMission,
  });

  final int missionNumber;
  final int submittedScore;
  final int previousBestScore;
  final int savedBestScore;
  final bool scoreImproved;
  final int totalScore;
  final int playerLevel;
  final int unlockedMission;

  factory MissionCompleteResponseDto.fromJson(Map<String, dynamic> json) {
    return MissionCompleteResponseDto(
      missionNumber: json['mission_number'] as int,
      submittedScore: json['submitted_score'] as int,
      previousBestScore: json['previous_best_score'] as int,
      savedBestScore: json['saved_best_score'] as int,
      scoreImproved: json['score_improved'] as bool,
      totalScore: json['total_score'] as int,
      playerLevel: json['player_level'] as int,
      unlockedMission: json['unlocked_mission'] as int,
    );
  }
}
