import 'achievement_definition.dart';

class UnlockedAchievement {
  const UnlockedAchievement({
    required this.definition,
    required this.unlockedAt,
  });

  final AchievementDefinition definition;
  final DateTime unlockedAt;
}

class AchievementState {
  const AchievementState({required this.unlockedById});

  const AchievementState.empty() : unlockedById = const {};

  final Map<String, DateTime> unlockedById;

  bool isUnlocked(String achievementId) {
    return unlockedById.containsKey(achievementId);
  }

  AchievementState copyWith({Map<String, DateTime>? unlockedById}) {
    return AchievementState(unlockedById: unlockedById ?? this.unlockedById);
  }
}
