import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../drone_game.dart';
import '../game_state.dart';
import '../mission_rules.dart';

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
            final missionDistance = game.missionDistanceMeters;
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
                  top: 6,
                  left: 46,
                  right: 6,
                  child: IgnorePointer(
                    child: _HudPanel(
                      child: Row(
                        children: [
                          _MissionBadge(
                            missionNumber: state.missionNumber,
                            label: l10n.mission,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: _ProgressCluster(
                              progress: progress,
                              remainingMeters: remaining.ceil(),
                              distanceLabel: l10n.distance,
                            ),
                          ),
                          const SizedBox(width: 5),
                          _LivesIndicator(
                            lives: state.lives,
                            label: l10n.lives,
                            unlimited: MissionRules.isFreeMission(
                              state.missionNumber,
                            ),
                          ),
                          const SizedBox(width: 5),
                          _StatPill(
                            label: 'PTS',
                            value: '${state.score}',
                            accent: const Color(0xFFFF9F2E),
                          ),
                          const SizedBox(width: 4),
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
                  top: 6,
                  left: 6,
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
        gradient: const LinearGradient(
          colors: [Color(0xE0051424), Color(0xCC0B2033)],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xCC6EF4FF), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x7700D7FF), blurRadius: 15, spreadRadius: -8),
          BoxShadow(
            color: Color(0x77FF3355),
            blurRadius: 12,
            spreadRadius: -9,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
      dimension: 34,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xE80A1B2D),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFFF5D73), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x88FF3355),
              blurRadius: 14,
              spreadRadius: -5,
            ),
          ],
        ),
        child: IconButton(
          key: const ValueKey('hud_pause_button'),
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          iconSize: 21,
          onPressed: onPressed,
          icon: const Icon(Icons.pause_rounded, color: Color(0xFFFF8DA0)),
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
        width: 54,
        height: 27,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF102A40),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF34D8FF), width: 1),
        ),
        child: Text(
          'M$missionNumber',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
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
                  color: Color(0xFF34D8FF),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '${(progress * 100).floor()}% · ${remainingMeters}m',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFFE8F7FF),
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Color(0xFF081421)),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0x6645F0FF),
                          width: 0.8,
                        ),
                      ),
                    ),
                  ),
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
  const _LivesIndicator({
    required this.lives,
    required this.label,
    required this.unlimited,
  });

  final int lives;
  final String label;
  final bool unlimited;

  @override
  Widget build(BuildContext context) {
    final visibleLives = lives.clamp(0, 5).toInt();

    return Semantics(
      label: unlimited ? '$label: unlimited' : '$label: $lives',
      child: Container(
        key: const ValueKey('hud_lives_indicator'),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: unlimited
            ? BoxDecoration(
                color: const Color(0xB80A1B2D),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFF5D73)),
              )
            : null,
        child: unlimited
            ? Text(
                '∞',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: const Color(0xFFFF8DA0),
                  fontWeight: FontWeight.w900,
                  height: 1,
                  shadows: const [
                    Shadow(color: Color(0x99FF3355), blurRadius: 8),
                  ],
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var index = 0; index < 5; index++)
                    Padding(
                      padding: EdgeInsets.only(left: index == 0 ? 0 : 2),
                      child: Icon(
                        index < visibleLives
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 14,
                        color: index < visibleLives
                            ? const Color(0xFFFF5D73)
                            : const Color(0xFF47657A),
                        shadows: index < visibleLives
                            ? const [
                                Shadow(color: Color(0x99FF3355), blurRadius: 8),
                              ]
                            : null,
                      ),
                    ),
                ],
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
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
          height: 1,
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
