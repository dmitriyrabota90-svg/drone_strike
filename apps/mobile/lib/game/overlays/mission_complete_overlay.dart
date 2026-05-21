import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../drone_game.dart';

class MissionCompleteOverlay extends StatelessWidget {
  const MissionCompleteOverlay({required this.game, super.key});

  final DroneGame game;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final missionNumber = game.levelConfig.missionNumber;

    return ColoredBox(
      color: const Color(0xCC061426),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.missionComplete,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 14),
                  _ScoreRow(label: l10n.baseScore, value: '100'),
                  _ScoreRow(label: l10n.flightAccuracy, value: 'TODO'),
                  _ScoreRow(label: l10n.tankHit, value: 'TODO'),
                  _ScoreRow(label: l10n.total, value: 'TODO'),
                  const SizedBox(height: 6),
                  Text(
                    'TODO: call progressController.completeMission after real scoring system is implemented.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (missionNumber < 10) {
                        context.go('/game/${missionNumber + 1}');
                        return;
                      }
                      context.go('/levels');
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
              ),
            ),
          ),
        ),
      ),
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
