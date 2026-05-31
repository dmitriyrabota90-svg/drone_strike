import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/domain/auth_controller.dart';
import '../../progress/domain/progress_controller.dart';
import '../../../game/mission_rules.dart';
import '../../../game/level_config.dart';
import '../../../game/systems/scoring_system.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/menu_background.dart';

class LevelSelectScreen extends ConsumerStatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  ConsumerState<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen> {
  String? _message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider).asData?.value;
    final isAuthenticated = authState?.isAuthenticated ?? false;
    final progressState = ref.watch(progressControllerProvider).asData?.value;
    final progress = progressState?.progress;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.levelSelect),
        leading: BackButton(onPressed: () => context.go('/menu')),
      ),
      body: MenuBackground(
        child: Column(
          children: [
            if (_message != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: GlassPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(_message!)),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, _) {
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 270,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.85,
                        ),
                    itemCount: MissionRules.maxMissionNumber,
                    itemBuilder: (context, index) {
                      final missionNumber = index + 1;
                      final unlockedMission =
                          progressState?.unlockedMission ?? 1;
                      final unlocked = isAuthenticated
                          ? missionNumber <= unlockedMission
                          : MissionRules.isGuestMissionAvailable(
                              missionNumber: missionNumber,
                              unlockedMission: unlockedMission,
                            );
                      final missionProgress = progress?.missionByNumber(
                        missionNumber,
                      );
                      final completed = missionProgress != null;
                      final freeMission = MissionRules.isFreeMission(
                        missionNumber,
                      );
                      final levelConfig = LevelConfig.forMission(missionNumber);

                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          if (unlocked) {
                            context.go('/game/$missionNumber');
                            return;
                          }
                          setState(() {
                            _message = _lockedMissionMessage(
                              l10n: l10n,
                              isAuthenticated: isAuthenticated,
                              missionNumber: missionNumber,
                            );
                          });
                        },
                        child: Opacity(
                          opacity: unlocked ? 1 : 0.58,
                          child: _MissionCard(
                            missionNumber: missionNumber,
                            unlocked: unlocked,
                            completed: completed,
                            freeMission: freeMission,
                            bestScore: missionProgress?.bestScore,
                            statusLabel: completed
                                ? l10n.completed
                                : unlocked
                                ? l10n.available
                                : _lockedMissionShortLabel(
                                    l10n: l10n,
                                    isAuthenticated: isAuthenticated,
                                    missionNumber: missionNumber,
                                  ),
                            difficulty: _difficultyFor(levelConfig),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _difficultyFor(LevelConfig config) {
    if (config.missionNumber <= 2) {
      return 1;
    }
    if (config.missionNumber <= 4) {
      return 2;
    }
    if (config.missionNumber <= 7) {
      return 3;
    }
    if (config.missionNumber <= 10) {
      return 4;
    }
    return 5;
  }

  String _lockedMissionMessage({
    required AppLocalizations l10n,
    required bool isAuthenticated,
    required int missionNumber,
  }) {
    if (!isAuthenticated && missionNumber > MissionRules.maxGuestMission) {
      return l10n.registrationRequired;
    }
    return l10n.completePreviousMission;
  }

  String _lockedMissionShortLabel({
    required AppLocalizations l10n,
    required bool isAuthenticated,
    required int missionNumber,
  }) {
    if (!isAuthenticated && missionNumber == MissionRules.maxGuestMission) {
      return l10n.completePreviousMission;
    }
    if (!isAuthenticated && missionNumber > MissionRules.maxGuestMission) {
      return l10n.registrationRequired;
    }
    return l10n.locked;
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.missionNumber,
    required this.unlocked,
    required this.completed,
    required this.freeMission,
    required this.bestScore,
    required this.statusLabel,
    required this.difficulty,
  });

  final int missionNumber;
  final bool unlocked;
  final bool completed;
  final bool freeMission;
  final int? bestScore;
  final String statusLabel;
  final int difficulty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accent = completed
        ? const Color(0xFF6EE7D8)
        : unlocked
        ? const Color(0xFFFFB74D)
        : const Color(0xFF667A91);

    return GlassPanel(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0x99071426),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: accent, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: unlocked ? 0.30 : 0.10),
                  blurRadius: 12,
                  spreadRadius: -6,
                ),
              ],
            ),
            child: Text(
              missionNumber.toString().padLeft(2, '0'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      completed
                          ? Icons.check_circle
                          : unlocked
                          ? Icons.play_arrow_rounded
                          : Icons.lock_outline,
                      size: 16,
                      color: accent,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        '${l10n.mission} $missionNumber',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  statusLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: [
                    _TinyBadge(
                      icon: Icons.bolt_rounded,
                      text: 'D$difficulty',
                      color: const Color(0xFF7CE7FF),
                    ),
                    _TinyBadge(
                      icon: Icons.center_focus_strong_rounded,
                      text: '+${ScoringSystem.tankHitBonus}',
                      color: const Color(0xFFFF9F2E),
                    ),
                    if (bestScore != null)
                      _TinyBadge(
                        icon: Icons.emoji_events_rounded,
                        text: '$bestScore',
                        color: const Color(0xFFE6D26B),
                      ),
                    if (freeMission)
                      const _TinyBadge(
                        icon: Icons.all_inclusive_rounded,
                        text: '∞',
                        color: Color(0xFFFF5D73),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0x990A1B2D),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.65)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
