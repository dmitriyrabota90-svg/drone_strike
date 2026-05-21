import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../drone_game.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({required this.game, super.key});

  final DroneGame game;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _OverlayShell(
      title: l10n.pause,
      children: [
        ElevatedButton.icon(
          onPressed: game.resumeGame,
          icon: const Icon(Icons.play_arrow),
          label: Text(l10n.resume),
        ),
        ElevatedButton.icon(
          onPressed: game.restart,
          icon: const Icon(Icons.replay),
          label: Text(l10n.restartMission),
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
    );
  }
}

class _OverlayShell extends StatelessWidget {
  const _OverlayShell({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xAA020812),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 18),
                  ...children.map(
                    (child) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: child,
                    ),
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
