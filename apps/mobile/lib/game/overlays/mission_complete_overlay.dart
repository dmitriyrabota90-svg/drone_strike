import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../systems/scoring_system.dart';

class MissionCompleteOverlay extends StatelessWidget {
  const MissionCompleteOverlay({required this.result, super.key});

  final MissionResult? result;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ColoredBox(
        color: const Color(0xCC061426),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 520,
                  maxHeight: constraints.maxHeight - 16,
                ),
                child: Card(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(14),
                    child: result == null
                        ? const SizedBox(
                            height: 140,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : _MissionCompleteContent(result: result!),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MissionCompleteContent extends StatelessWidget {
  const _MissionCompleteContent({required this.result});

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
        const SizedBox(height: 4),
        Text(
          result.backendSubmitted ? l10n.backendSubmitted : l10n.guestResult,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
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
            value: result.scoreImproved == true ? l10n.yesLabel : l10n.noLabel,
          ),
        if (result.totalPlayerScore != null)
          _ScoreRow(
            label: l10n.totalScore,
            value: '${result.totalPlayerScore}',
          ),
        if (result.playerLevel != null)
          _ScoreRow(label: l10n.playerLevel, value: '${result.playerLevel}'),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                if (missionNumber >= 10) {
                  context.go('/levels');
                  return;
                }
                if (result.isGuest && nextMission >= 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.registrationRequiredAfterMission),
                    ),
                  );
                  context.go('/register');
                  return;
                }
                context.go('/game/$nextMission');
              },
              icon: const Icon(Icons.arrow_forward),
              label: Text(l10n.nextMission),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/levels'),
              icon: const Icon(Icons.grid_view),
              label: Text(l10n.levelSelect),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/menu'),
              icon: const Icon(Icons.home),
              label: Text(l10n.mainMenu),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
