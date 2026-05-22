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
                  top: 8,
                  left: 54,
                  right: 8,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xD9061426),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF355E83)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _HudChip(
                              label: l10n.lives,
                              value: '${state.lives}',
                            ),
                            _HudChip(
                              label: l10n.mission,
                              value: '${state.missionNumber}',
                            ),
                            _HudChip(
                              label: l10n.distance,
                              value:
                                  '${state.remainingDistanceMeters.ceil()} m',
                            ),
                            _HudChip(
                              label: l10n.score,
                              value: '${state.score}',
                            ),
                            _HudChip(
                              label: l10n.playerLevel,
                              value: '${state.playerLevel}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: SizedBox.square(
                    dimension: 36,
                    child: IconButton.filledTonal(
                      tooltip: l10n.pause,
                      padding: EdgeInsets.zero,
                      onPressed: game.pauseGame,
                      icon: const Icon(Icons.pause, size: 18),
                    ),
                  ),
                ),
                if (state.status == DroneMissionStatus.ready)
                  IgnorePointer(
                    child: Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xC9061426),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF89D8FF)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.touch_app,
                                color: Color(0xFF89D8FF),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.tapToStart,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
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
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Text(
          '$label: $value',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFFE8F7FF),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
