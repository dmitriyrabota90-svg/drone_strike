import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../drone_game.dart';
import '../game_state.dart';

class GameHud extends StatelessWidget {
  const GameHud({required this.game, super.key});

  final DroneGame game;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ValueListenableBuilder<DroneGameState>(
          valueListenable: game.stateNotifier,
          builder: (context, state, child) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xCC061426),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF29476A)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _HudChip(label: l10n.lives, value: '${state.lives}'),
                      _HudChip(
                        label: l10n.mission,
                        value: '${state.missionNumber}',
                      ),
                      _HudChip(
                        label: l10n.distance,
                        value: '${state.remainingDistanceMeters.ceil()} m',
                      ),
                      _HudChip(label: l10n.score, value: '${state.score}'),
                      _HudChip(
                        label: l10n.playerLevel,
                        value: '${state.playerLevel}',
                      ),
                      if (state.status == DroneMissionStatus.ready)
                        Text(
                          l10n.tapToStart,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      IconButton.filledTonal(
                        tooltip: l10n.pause,
                        onPressed: game.pauseGame,
                        icon: const Icon(Icons.pause),
                      ),
                    ],
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

class _HudChip extends StatelessWidget {
  const _HudChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF10243A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF31516F)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text('$label: $value'),
      ),
    );
  }
}
