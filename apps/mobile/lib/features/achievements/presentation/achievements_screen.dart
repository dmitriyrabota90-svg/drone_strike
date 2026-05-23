import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/menu_background.dart';
import '../../progress/domain/progress_controller.dart';
import '../domain/achievement_definition.dart';
import '../domain/achievement_state.dart';
import '../domain/achievements_controller.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final achievementsValue = ref.watch(achievementsControllerProvider);

    ref.listen(progressControllerProvider, (previous, next) {
      final progress = next.asData?.value.progress;
      if (progress != null) {
        unawaited(
          ref
              .read(achievementsControllerProvider.notifier)
              .evaluateProgress(progress),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.achievements),
        leading: BackButton(onPressed: () => context.go('/menu')),
      ),
      body: MenuBackground(
        child: achievementsValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: GlassPanel(
              child: Text(
                '$error',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          data: (achievementState) =>
              _AchievementsGrid(achievementState: achievementState, l10n: l10n),
        ),
      ),
    );
  }
}

class _AchievementsGrid extends StatelessWidget {
  const _AchievementsGrid({required this.achievementState, required this.l10n});

  final AchievementState achievementState;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 620
            ? 3
            : 2;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: achievementDefinitions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: constraints.maxWidth >= 620 ? 0.9 : 0.78,
          ),
          itemBuilder: (context, index) {
            final definition = achievementDefinitions[index];
            final unlockedAt = achievementState.unlockedById[definition.id];
            return _AchievementCard(
              definition: definition,
              unlockedAt: unlockedAt,
              l10n: l10n,
            );
          },
        );
      },
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.definition,
    required this.unlockedAt,
    required this.l10n,
  });

  final AchievementDefinition definition;
  final DateTime? unlockedAt;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isUnlocked = unlockedAt != null;

    return GlassPanel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: isUnlocked ? 1 : 0.35,
                  child: Image.asset(definition.iconPath, fit: BoxFit.contain),
                ),
                if (!isUnlocked)
                  const DecoratedBox(
                    decoration: BoxDecoration(color: Color(0x99000000)),
                    child: Center(
                      child: Icon(
                        Icons.lock_rounded,
                        color: Color(0xFFE8F7FF),
                        size: 34,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            definition.title(l10n),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: const Color(0xFFE8F7FF),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            definition.description(l10n),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFFC9D8E6)),
          ),
          const SizedBox(height: 8),
          Text(
            isUnlocked
                ? '${l10n.unlocked}: ${_formatDate(unlockedAt!)}'
                : l10n.locked,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isUnlocked
                  ? const Color(0xFF7CE7FF)
                  : const Color(0xFF7C8A99),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final year = local.year.toString().padLeft(4, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
