import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/menu_background.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sections = [
      (l10n.lives, Icons.favorite, l10n.comingSoon),
      (l10n.premium, Icons.workspace_premium, l10n.comingSoon),
      (l10n.drones, Icons.flight, l10n.comingSoon),
      (l10n.flightTrails, Icons.auto_awesome, l10n.comingSoon),
      (l10n.nicknameChange, Icons.badge_outlined, l10n.comingSoon),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shop),
        leading: BackButton(onPressed: () => context.go('/menu')),
      ),
      body: MenuBackground(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final section = sections[index];
            return GlassPanel(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(section.$2),
                title: Text(section.$1),
                subtitle: Text(section.$3),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: sections.length,
        ),
      ),
    );
  }
}
