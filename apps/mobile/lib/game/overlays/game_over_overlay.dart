import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../drone_game.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({required this.game, super.key});

  final DroneGame game;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ColoredBox(
      color: const Color(0xCC12040A),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ValueListenableBuilder(
                valueListenable: game.stateNotifier,
                builder: (context, state, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.droneDestroyed,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.missionFailed, textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.remainingLives}: ${state.lives}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      if (state.lives > 0) ...[
                        ElevatedButton.icon(
                          onPressed: game.restart,
                          icon: const Icon(Icons.replay),
                          label: Text(l10n.restartMission),
                        ),
                        const SizedBox(height: 10),
                      ],
                      OutlinedButton.icon(
                        onPressed: () => context.go('/levels'),
                        icon: const Icon(Icons.grid_view),
                        label: Text(l10n.backToLevels),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => context.go('/menu'),
                        icon: const Icon(Icons.home),
                        label: Text(l10n.mainMenu),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
