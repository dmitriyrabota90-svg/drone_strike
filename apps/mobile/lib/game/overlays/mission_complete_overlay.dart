import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../drone_game.dart';
import '../systems/scoring_system.dart';

class MissionCompleteOverlay extends StatelessWidget {
  const MissionCompleteOverlay({required this.game, super.key});

  final DroneGame game;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xCC061426),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ValueListenableBuilder<MissionResult?>(
                valueListenable: game.missionResultNotifier,
                builder: (context, result, child) {
                  if (result == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _MissionCompleteContent(game: game, result: result);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MissionCompleteContent extends StatelessWidget {
  const _MissionCompleteContent({required this.game, required this.result});

  final DroneGame game;
  final MissionResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final missionNumber = result.missionNumber;
    final nextMission = missionNumber + 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.missionComplete,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          result.backendSubmitted ? l10n.backendSubmitted : l10n.guestResult,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 14),
        _ScoreRow(label: l10n.baseScore, value: '${result.baseScore}'),
        _ScoreRow(
          label: l10n.flightAccuracy,
          value: '+${result.flightAccuracyBonus}',
        ),
        _ScoreRow(label: l10n.tankHit, value: '+${result.tankHitBonus}'),
        _ScoreRow(label: l10n.totalScore, value: '${result.totalScore}'),
        if (result.savedBestScore != null)
          _ScoreRow(
            label: l10n.savedBestScore,
            value: '${result.savedBestScore}',
          ),
        if (result.scoreImproved != null)
          _ScoreRow(
            label: result.scoreImproved == true
                ? l10n.scoreImproved
                : l10n.scoreNotImproved,
            value: result.scoreImproved == true ? 'yes' : 'no',
          ),
        if (result.totalPlayerScore != null)
          _ScoreRow(
            label: l10n.totalScore,
            value: '${result.totalPlayerScore}',
          ),
        if (result.playerLevel != null)
          _ScoreRow(label: l10n.playerLevel, value: '${result.playerLevel}'),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          onPressed: () {
            if (missionNumber >= 10) {
              context.go('/levels');
              return;
            }
            if (result.isGuest && nextMission >= 3) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.registrationRequiredAfterMission)),
              );
              context.go('/register');
              return;
            }
            context.go('/game/$nextMission');
          },
          icon: const Icon(Icons.arrow_forward),
          label: Text(l10n.nextMission),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => context.go('/levels'),
          icon: const Icon(Icons.grid_view),
          label: Text(l10n.levelSelect),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => context.go('/menu'),
          icon: const Icon(Icons.home),
          label: Text(l10n.mainMenu),
        ),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value)],
      ),
    );
  }
}
