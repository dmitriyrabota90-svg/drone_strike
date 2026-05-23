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

    return SizedBox.expand(
      child: SafeArea(
        child: ValueListenableBuilder<DroneGameState>(
          valueListenable: game.stateNotifier,
          builder: (context, state, child) {
            final missionDistance = game.levelConfig.missionDistanceMeters;
            final remaining = state.remainingDistanceMeters.clamp(
              0.0,
              missionDistance,
            );
            final progress = missionDistance <= 0
                ? 0.0
                : (1 - remaining / missionDistance).clamp(0.0, 1.0).toDouble();

            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (_) => game.handleFieldTap(),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 62,
                  right: 10,
                  child: IgnorePointer(
                    child: _HudPanel(
                      child: Row(
                        children: [
                          _MissionBadge(
                            missionNumber: state.missionNumber,
                            label: l10n.mission,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ProgressCluster(
                              progress: progress,
                              remainingMeters: remaining.ceil(),
                              distanceLabel: l10n.distance,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _LivesIndicator(
                            lives: state.lives,
                            label: l10n.lives,
                          ),
                          const SizedBox(width: 8),
                          _StatPill(
                            label: 'SC',
                            value: '${state.score}',
                            accent: const Color(0xFFFF9F2E),
                          ),
                          const SizedBox(width: 6),
                          _StatPill(
                            label: 'LV',
                            value: '${state.playerLevel}',
                            accent: const Color(0xFF7CE7FF),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _PauseButton(
                    tooltip: l10n.pause,
                    onPressed: game.pauseGame,
                  ),
                ),
                if (state.status == DroneMissionStatus.ready)
                  IgnorePointer(
                    child: Center(child: _StartPrompt(text: l10n.tapToStart)),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HudPanel extends StatelessWidget {
  const _HudPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD9061426),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xAA78E8FF), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x6600D7FF), blurRadius: 18, spreadRadius: -8),
          BoxShadow(
            color: Color(0x88000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: child,
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 42,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xE80A1B2D),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFF9F2E), width: 1.4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x88FF7A1A),
              blurRadius: 14,
              spreadRadius: -5,
            ),
          ],
        ),
        child: IconButton(
          key: const ValueKey('hud_pause_button'),
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: const Icon(Icons.pause_rounded, color: Color(0xFFFFC36B)),
        ),
      ),
    );
  }
}

class _MissionBadge extends StatelessWidget {
  const _MissionBadge({required this.missionNumber, required this.label});

  final int missionNumber;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $missionNumber',
      child: Container(
        key: const ValueKey('hud_mission_badge'),
        width: 92,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF102A40),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF34D8FF), width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MISSION',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF7CE7FF),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$missionNumber',
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCluster extends StatelessWidget {
  const _ProgressCluster({
    required this.progress,
    required this.remainingMeters,
    required this.distanceLabel,
  });

  final double progress;
  final int remainingMeters;
  final String distanceLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$distanceLabel: $remainingMeters m',
      child: Column(
        key: const ValueKey('hud_mission_progress'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.speed_rounded,
                color: Color(0xFF7CE7FF),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '${remainingMeters}m',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFFE8F7FF),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Color(0xFF081421)),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF28D7FF), Color(0xFFFF9F2E)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LivesIndicator extends StatelessWidget {
  const _LivesIndicator({required this.lives, required this.label});

  final int lives;
  final String label;

  @override
  Widget build(BuildContext context) {
    final visibleLives = lives.clamp(0, 5).toInt();

    return Semantics(
      label: '$label: $lives',
      child: Row(
        key: const ValueKey('hud_lives_indicator'),
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < 5; index++)
            Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 2),
              child: Icon(
                index < visibleLives
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 16,
                color: index < visibleLives
                    ? const Color(0xFFFF5D73)
                    : const Color(0xFF47657A),
                shadows: index < visibleLives
                    ? const [Shadow(color: Color(0x99FF3355), blurRadius: 8)]
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xB80A1B2D),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: 0.7)),
      ),
      child: Text(
        '$label $value',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFFE8F7FF),
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _StartPrompt extends StatelessWidget {
  const _StartPrompt({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xD9061426),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF7CE7FF), width: 1.4),
        boxShadow: const [
          BoxShadow(color: Color(0x7700D7FF), blurRadius: 18, spreadRadius: -6),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.touch_app_rounded, color: Color(0xFF7CE7FF)),
            const SizedBox(width: 8),
            Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
