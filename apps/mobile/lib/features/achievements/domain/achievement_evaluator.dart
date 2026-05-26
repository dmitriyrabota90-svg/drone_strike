import '../../../game/systems/scoring_system.dart';
import '../../progress/data/progress_dto.dart';
import 'achievement_definition.dart';

class AchievementEvaluator {
  const AchievementEvaluator._();

  static const highBonusThreshold = 45;

  static Set<String> evaluate({
    MissionResult? missionResult,
    ProgressResponseDto? progress,
  }) {
    final unlocked = <String>{};

    if (missionResult != null) {
      if (missionResult.missionNumber == 1) {
        unlocked.add(AchievementIds.firstRun);
      }
      if (missionResult.tankHitBonus >= highBonusThreshold) {
        unlocked.add(AchievementIds.cleanHit);
      }
      if (missionResult.tankHitBonus == ScoringSystem.tankHitBonus) {
        unlocked.add(AchievementIds.bullseye);
      }
      if (missionResult.flightAccuracyBonus >= highBonusThreshold) {
        unlocked.add(AchievementIds.stableFlight);
      }
      if (missionResult.coreScore == ScoringSystem.maxScore) {
        unlocked.add(AchievementIds.perfectScore);
      }
    }

    if (progress != null) {
      final completedMissions = progress.missions
          .map((mission) => mission.missionNumber)
          .toSet();
      if (completedMissions.contains(1)) {
        unlocked.add(AchievementIds.firstRun);
      }
      if ((completedMissions.contains(1) && completedMissions.contains(2)) ||
          progress.unlockedMission >= 3) {
        unlocked.add(AchievementIds.trainingComplete);
      }
      if (progress.unlockedMission >= 5) {
        unlocked.add(AchievementIds.fifthTarget);
      }
      if (progress.completedMissionsCount >= 10) {
        unlocked.add(AchievementIds.mvpCampaign);
      }
      for (final mission in progress.missions) {
        if (mission.bestTankHitBonus >= highBonusThreshold) {
          unlocked.add(AchievementIds.cleanHit);
        }
        if (mission.bestTankHitBonus == ScoringSystem.tankHitBonus) {
          unlocked.add(AchievementIds.bullseye);
        }
        if (mission.bestFlightAccuracyBonus >= highBonusThreshold) {
          unlocked.add(AchievementIds.stableFlight);
        }
        if (mission.bestScore >= ScoringSystem.maxScore) {
          unlocked.add(AchievementIds.perfectScore);
        }
      }
    }

    return unlocked;
  }
}
