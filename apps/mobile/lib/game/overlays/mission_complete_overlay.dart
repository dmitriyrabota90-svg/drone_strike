import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../mission_rules.dart';
import '../systems/scoring_system.dart';

class MissionCompleteOverlay extends StatelessWidget {
  const MissionCompleteOverlay({required this.result, super.key});

  final MissionResult? result;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ColoredBox(
        color: const Color(0xE8030711),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 520,
                  maxHeight: constraints.maxHeight - 16,
                ),
                child: _ArcadePanel(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
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
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: const Color(0xFF8EF7FF),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            shadows: const [Shadow(color: Color(0xFF00D9FF), blurRadius: 16)],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          result.backendSubmitted ? l10n.backendSubmitted : l10n.guestResult,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFFFFC857),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xAA071B2C),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0x884BEAFF)),
          ),
          child: Column(
            children: [
              _ScoreRow(label: l10n.baseScore, value: '${result.baseScore}'),
              _ScoreRow(
                label: l10n.flightAccuracy,
                value: '+${result.flightAccuracyBonus}',
              ),
              _ScoreRow(label: l10n.tankHit, value: '+${result.tankHitBonus}'),
              _ScoreRow(
                label: l10n.batteryBonus,
                value: '+${result.batteryBonus}',
                accent: const Color(0xFFFFC857),
              ),
              const Divider(color: Color(0x554BEAFF), height: 14),
              _ScoreRow(
                label: l10n.totalScore,
                value: '${result.totalScore}',
                large: true,
              ),
            ],
          ),
        ),
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
            _ArcadeActionButton(
              onPressed: () {
                if (missionNumber >= MissionRules.maxMissionNumber) {
                  context.go('/levels');
                  return;
                }
                if (result.isGuest && nextMission >= 3) {
                  context.go('/register');
                  return;
                }
                context.go('/game/$nextMission');
              },
              icon: const Icon(Icons.arrow_forward),
              label: l10n.nextMission,
              primary: true,
            ),
            _ArcadeActionButton(
              onPressed: () => context.go('/levels'),
              icon: const Icon(Icons.grid_view),
              label: l10n.levelSelect,
            ),
            _ArcadeActionButton(
              onPressed: () => context.go('/menu'),
              icon: const Icon(Icons.home),
              label: l10n.mainMenu,
            ),
          ],
        ),
      ],
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.label,
    required this.value,
    this.accent,
    this.large = false,
  });

  final String label;
  final String value;
  final Color? accent;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              color: accent ?? const Color(0xFFECFBFF),
              fontWeight: FontWeight.w900,
              fontSize: large ? 18 : null,
              shadows: large
                  ? const [Shadow(color: Color(0xFF00D9FF), blurRadius: 10)]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcadePanel extends StatelessWidget {
  const _ArcadePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xEE081321),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4BEAFF), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x9900D9FF), blurRadius: 18),
          BoxShadow(color: Color(0x66FF7A30), blurRadius: 28),
        ],
      ),
      child: child,
    );
  }
}

class _ArcadeActionButton extends StatelessWidget {
  const _ArcadeActionButton({
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
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: BorderSide(color: accent, width: 1.4),
        backgroundColor: const Color(0xAA061426),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}
