import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sections = [
      (l10n.lives, Icons.favorite),
      (l10n.premium, Icons.workspace_premium),
      (l10n.drones, Icons.flight),
      (l10n.flightTrails, Icons.auto_awesome),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shop),
        leading: BackButton(onPressed: () => context.go('/menu')),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final section = sections[index];
          return Card(
            child: ListTile(
              leading: Icon(section.$2),
              title: Text(section.$1),
              subtitle: Text(l10n.comingSoon),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemCount: sections.length,
      ),
    );
  }
}
