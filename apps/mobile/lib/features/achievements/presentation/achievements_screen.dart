import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.achievements),
        leading: BackButton(onPressed: () => context.go('/menu')),
      ),
      body: Center(
        child: Text(
          l10n.comingSoon,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
