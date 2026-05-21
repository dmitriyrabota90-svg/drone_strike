import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.levelSelect),
        leading: BackButton(onPressed: () => context.go('/menu')),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 170,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.15,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          final missionNumber = index + 1;
          final unlocked = missionNumber <= 2;

          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (unlocked) {
                context.go('/game');
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.registrationRequired)),
              );
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(unlocked ? Icons.play_arrow : Icons.lock, size: 34),
                    const SizedBox(height: 10),
                    Text('${l10n.mission} $missionNumber'),
                    const SizedBox(height: 4),
                    Text(unlocked ? l10n.splashSubtitle : l10n.locked),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
