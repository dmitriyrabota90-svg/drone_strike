import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/domain/auth_controller.dart';
import '../../progress/domain/progress_controller.dart';
import '../../progress/data/progress_dto.dart';
import '../../../l10n/generated/app_localizations.dart';

class GamePlaceholderScreen extends ConsumerWidget {
  const GamePlaceholderScreen({required this.missionNumber, super.key});

  final int missionNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider).asData?.value;
    final progressState = ref.watch(progressControllerProvider).asData?.value;
    final isAuthenticated = authState?.isAuthenticated ?? false;
    final isLoading = progressState?.isLoading ?? false;
    final playerLevel =
        progressState?.playerLevel ?? authState?.user?.playerLevel ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.mission} $missionNumber'),
        leading: BackButton(onPressed: () => context.go('/levels')),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.pause))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _HudItem(label: l10n.lives, value: '3'),
                _HudItem(label: l10n.mission, value: '$missionNumber'),
                _HudItem(label: l10n.distance, value: '820 m'),
                _HudItem(label: l10n.score, value: '0'),
                _HudItem(label: l10n.playerLevel, value: '$playerLevel'),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                l10n.gamePlaceholder,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ElevatedButton.icon(
              // TODO: Replace with real Flame result after gameplay is implemented.
              onPressed: isLoading
                  ? null
                  : () => _simulateMissionComplete(
                      context: context,
                      ref: ref,
                      l10n: l10n,
                      isAuthenticated: isAuthenticated,
                    ),
              icon: const Icon(Icons.task_alt),
              label: Text(l10n.simulateMissionComplete),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: OutlinedButton.icon(
              onPressed: () => context.go('/menu'),
              icon: const Icon(Icons.home),
              label: Text(l10n.backToMenu),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _simulateMissionComplete({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    required bool isAuthenticated,
  }) async {
    if (!isAuthenticated) {
      final message = missionNumber <= 2
          ? l10n.guestMissionCompletePlaceholder
          : l10n.registrationRequired;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    await ref
        .read(progressControllerProvider.notifier)
        .completeMission(
          missionNumber: missionNumber,
          flightAccuracyBonus: 25,
          tankHitBonus: 25,
        );
    final result = ref
        .read(progressControllerProvider)
        .asData
        ?.value
        .lastMissionResult;

    if (!context.mounted || result == null) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => _MissionResultDialog(result: result),
    );

    if (context.mounted) {
      context.go('/levels');
    }
  }
}

class _MissionResultDialog extends StatelessWidget {
  const _MissionResultDialog({required this.result});

  final MissionCompleteResponseDto result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.missionResult),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${l10n.submittedScore}: ${result.submittedScore}'),
          Text('${l10n.savedBestScore}: ${result.savedBestScore}'),
          Text('${l10n.scoreImproved}: ${result.scoreImproved}'),
          Text('${l10n.totalScore}: ${result.totalScore}'),
          Text('${l10n.playerLevel}: ${result.playerLevel}'),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.goToLevels),
        ),
      ],
    );
  }
}

class _HudItem extends StatelessWidget {
  const _HudItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF263A55)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text('$label: $value'),
      ),
    );
  }
}
