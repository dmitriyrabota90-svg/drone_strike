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
      color: const Color(0xE812040A),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xEE160911),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFF5A3D), width: 1.5),
              boxShadow: const [
                BoxShadow(color: Color(0xAAFF3D21), blurRadius: 22),
                BoxShadow(color: Color(0x5500D9FF), blurRadius: 18),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
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
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: const Color(0xFFFFB199),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              shadows: const [
                                Shadow(
                                  color: Color(0xFFFF3D21),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.missionFailed,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFFFC857),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (state.lives > 0) ...[
                        _GameOverButton(
                          onPressed: game.restart,
                          icon: const Icon(Icons.replay),
                          label: l10n.restartMission,
                          primary: true,
                        ),
                        const SizedBox(height: 10),
                      ],
                      _GameOverButton(
                        onPressed: () => context.go('/levels'),
                        icon: const Icon(Icons.grid_view),
                        label: l10n.backToLevels,
                      ),
                      const SizedBox(height: 10),
                      _GameOverButton(
                        onPressed: () => context.go('/menu'),
                        icon: const Icon(Icons.home),
                        label: l10n.mainMenu,
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

class _GameOverButton extends StatelessWidget {
  const _GameOverButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.primary = false,
  });

  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final accent = primary ? const Color(0xFFFF9E2C) : const Color(0xFF4BEAFF);
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: BorderSide(color: accent, width: 1.4),
        backgroundColor: const Color(0xAA061426),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}
