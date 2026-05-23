import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../game/systems/scoring_system.dart';
import '../../progress/data/progress_dto.dart';
import '../data/achievements_repository.dart';
import 'achievement_definition.dart';
import 'achievement_evaluator.dart';
import 'achievement_state.dart';

final achievementsRepositoryProvider = Provider<AchievementsRepository>((ref) {
  return AchievementsRepository();
});

final achievementsControllerProvider =
    AsyncNotifierProvider<AchievementsController, AchievementState>(
      AchievementsController.new,
    );

class AchievementsController extends AsyncNotifier<AchievementState> {
  @override
  Future<AchievementState> build() async {
    final unlocked = await ref
        .read(achievementsRepositoryProvider)
        .loadUnlocked();
    return AchievementState(unlockedById: unlocked);
  }

  Future<List<UnlockedAchievement>> evaluateMissionResult({
    required MissionResult missionResult,
    ProgressResponseDto? progress,
  }) async {
    final achievementIds = AchievementEvaluator.evaluate(
      missionResult: missionResult,
      progress: progress,
    );
    return _unlockNew(achievementIds);
  }

  Future<List<UnlockedAchievement>> evaluateProgress(
    ProgressResponseDto progress,
  ) async {
    final achievementIds = AchievementEvaluator.evaluate(progress: progress);
    return _unlockNew(achievementIds);
  }

  Future<List<UnlockedAchievement>> _unlockNew(
    Set<String> achievementIds,
  ) async {
    if (achievementIds.isEmpty) {
      return const [];
    }

    final current = await _currentState();
    final newIds = achievementIds
        .where((achievementId) => !current.isUnlocked(achievementId))
        .toList();
    if (newIds.isEmpty) {
      return const [];
    }

    final updated = await ref
        .read(achievementsRepositoryProvider)
        .unlockAll(newIds);
    state = AsyncData(AchievementState(unlockedById: updated));

    return [
      for (final achievementId in newIds)
        UnlockedAchievement(
          definition: achievementDefinitionById(achievementId),
          unlockedAt: updated[achievementId]!,
        ),
    ];
  }

  Future<AchievementState> _currentState() async {
    final current = state.asData?.value;
    if (current != null) {
      return current;
    }
    final unlocked = await ref
        .read(achievementsRepositoryProvider)
        .loadUnlocked();
    return AchievementState(unlockedById: unlocked);
  }
}
