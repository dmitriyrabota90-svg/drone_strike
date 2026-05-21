import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';

class GamePlaceholderScreen extends StatelessWidget {
  const GamePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.mission} 1'),
        leading: BackButton(onPressed: () => context.go('/levels')),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.pause))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _HudItem(label: l10n.lives, value: '3'),
                _HudItem(label: l10n.mission, value: '1'),
                _HudItem(label: l10n.distance, value: '820 m'),
                _HudItem(label: l10n.score, value: '0'),
                _HudItem(label: l10n.playerLevel, value: '1'),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                l10n.gamePlaceholder,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => context.go('/menu'),
              icon: const Icon(Icons.home),
              label: Text(l10n.backToMenu),
            ),
          ),
        ],
      ),
    );
  }
}

class _HudItem extends StatelessWidget {
  const _HudItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF263A55)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text('$label: $value'),
      ),
    );
  }
}
