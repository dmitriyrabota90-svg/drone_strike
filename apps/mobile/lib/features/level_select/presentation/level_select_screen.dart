import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../lives/domain/lives_controller.dart';
import '../../auth/domain/auth_controller.dart';
import '../../progress/domain/progress_controller.dart';
import '../../../l10n/generated/app_localizations.dart';

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider).asData?.value;
    final isAuthenticated = authState?.isAuthenticated ?? false;
    final progressState = ref.watch(progressControllerProvider).asData?.value;
    final progress = progressState?.progress;
    final livesState = ref.watch(livesControllerProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.levelSelect),
        leading: BackButton(onPressed: () => context.go('/menu')),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 170,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          final missionNumber = index + 1;
          final unlocked = isAuthenticated
              ? missionNumber <= (progressState?.unlockedMission ?? 1)
              : missionNumber <= 2;
          final missionProgress = progress?.missionByNumber(missionNumber);
          final completed = missionProgress != null;

          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (unlocked) {
                if (livesState?.hasLives == false) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.noLives)));
                }
                context.go('/game/$missionNumber');
                return;
              }
              final message = isAuthenticated
                  ? l10n.completePreviousMission
                  : l10n.registrationRequired;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            },
            child: Card(
              color: unlocked
                  ? null
                  : Theme.of(context).disabledColor.withValues(alpha: 0.12),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      completed
                          ? Icons.check_circle
                          : unlocked
                          ? Icons.play_arrow
                          : Icons.lock,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text('${l10n.mission} $missionNumber'),
                    const SizedBox(height: 2),
                    if (completed)
                      Text('${l10n.bestScore}: ${missionProgress.bestScore}')
                    else
                      Text(
                        unlocked ? l10n.available : l10n.locked,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
