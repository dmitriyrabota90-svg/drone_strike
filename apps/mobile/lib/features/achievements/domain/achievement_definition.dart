import '../../../core/assets/app_assets.dart';
import '../../../l10n/generated/app_localizations.dart';

enum AchievementCategory { progress, skill }

class AchievementIds {
  const AchievementIds._();

  static const firstRun = 'first_run';
  static const trainingComplete = 'training_complete';
  static const fifthTarget = 'fifth_target';
  static const mvpCampaign = 'mvp_campaign';
  static const cleanHit = 'clean_hit';
  static const bullseye = 'bullseye';
  static const stableFlight = 'stable_flight';
  static const perfectScore = 'perfect_score';
}

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.iconPath,
    required this.category,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final String iconPath;
  final AchievementCategory category;

  String title(AppLocalizations l10n) => switch (id) {
    AchievementIds.firstRun => l10n.achievementFirstRunTitle,
    AchievementIds.trainingComplete => l10n.achievementTrainingCompleteTitle,
    AchievementIds.fifthTarget => l10n.achievementFifthTargetTitle,
    AchievementIds.mvpCampaign => l10n.achievementMvpCampaignTitle,
    AchievementIds.cleanHit => l10n.achievementCleanHitTitle,
    AchievementIds.bullseye => l10n.achievementBullseyeTitle,
    AchievementIds.stableFlight => l10n.achievementStableFlightTitle,
    AchievementIds.perfectScore => l10n.achievementPerfectScoreTitle,
    _ => id,
  };

  String description(AppLocalizations l10n) => switch (id) {
    AchievementIds.firstRun => l10n.achievementFirstRunDescription,
    AchievementIds.trainingComplete =>
      l10n.achievementTrainingCompleteDescription,
    AchievementIds.fifthTarget => l10n.achievementFifthTargetDescription,
    AchievementIds.mvpCampaign => l10n.achievementMvpCampaignDescription,
    AchievementIds.cleanHit => l10n.achievementCleanHitDescription,
    AchievementIds.bullseye => l10n.achievementBullseyeDescription,
    AchievementIds.stableFlight => l10n.achievementStableFlightDescription,
    AchievementIds.perfectScore => l10n.achievementPerfectScoreDescription,
    _ => id,
  };
}

const achievementDefinitions = <AchievementDefinition>[
  AchievementDefinition(
    id: AchievementIds.firstRun,
    titleKey: 'achievementFirstRunTitle',
    descriptionKey: 'achievementFirstRunDescription',
    iconPath: AppAssets.achievementFirstRun,
    category: AchievementCategory.progress,
  ),
  AchievementDefinition(
    id: AchievementIds.trainingComplete,
    titleKey: 'achievementTrainingCompleteTitle',
    descriptionKey: 'achievementTrainingCompleteDescription',
    iconPath: AppAssets.achievementTrainingComplete,
    category: AchievementCategory.progress,
  ),
  AchievementDefinition(
    id: AchievementIds.fifthTarget,
    titleKey: 'achievementFifthTargetTitle',
    descriptionKey: 'achievementFifthTargetDescription',
    iconPath: AppAssets.achievementFifthTarget,
    category: AchievementCategory.progress,
  ),
  AchievementDefinition(
    id: AchievementIds.mvpCampaign,
    titleKey: 'achievementMvpCampaignTitle',
    descriptionKey: 'achievementMvpCampaignDescription',
    iconPath: AppAssets.achievementMvpCampaign,
    category: AchievementCategory.progress,
  ),
  AchievementDefinition(
    id: AchievementIds.cleanHit,
    titleKey: 'achievementCleanHitTitle',
    descriptionKey: 'achievementCleanHitDescription',
    iconPath: AppAssets.achievementCleanHit,
    category: AchievementCategory.skill,
  ),
  AchievementDefinition(
    id: AchievementIds.bullseye,
    titleKey: 'achievementBullseyeTitle',
    descriptionKey: 'achievementBullseyeDescription',
    iconPath: AppAssets.achievementBullseye,
    category: AchievementCategory.skill,
  ),
  AchievementDefinition(
    id: AchievementIds.stableFlight,
    titleKey: 'achievementStableFlightTitle',
    descriptionKey: 'achievementStableFlightDescription',
    iconPath: AppAssets.achievementStableFlight,
    category: AchievementCategory.skill,
  ),
  AchievementDefinition(
    id: AchievementIds.perfectScore,
    titleKey: 'achievementPerfectScoreTitle',
    descriptionKey: 'achievementPerfectScoreDescription',
    iconPath: AppAssets.achievementPerfectScore,
    category: AchievementCategory.skill,
  ),
];

AchievementDefinition achievementDefinitionById(String id) {
  return achievementDefinitions.firstWhere(
    (definition) => definition.id == id,
    orElse: () => throw ArgumentError.value(id, 'id', 'Unknown achievement'),
  );
}
