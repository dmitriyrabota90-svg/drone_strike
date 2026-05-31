import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/app_assets.dart';
import '../../../features/auth/domain/auth_controller.dart';
import '../../../features/profile/domain/profile_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/menu_background.dart';
import '../domain/test_entitlements.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String? _message;
  bool _messageIsError = false;
  bool _renaming = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider).asData?.value;
    final user = authState?.user;
    final testUnlocked = TestEntitlements.unlocksShopForEmail(user?.email);
    final items = _shopItems(l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shop),
        leading: BackButton(onPressed: () => context.go('/menu')),
      ),
      body: MenuBackground(
        child: Column(
          children: [
            if (_message != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: GlassPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  child: Text(
                    _message!,
                    style: TextStyle(
                      color: _messageIsError
                          ? Theme.of(context).colorScheme.error
                          : const Color(0xFF8EF7FF),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(14),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 270,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.55,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final unlocked = testUnlocked || item.isNicknameAction;
                  return _ShopItemCard(
                    item: item,
                    unlocked: unlocked,
                    loading: item.isNicknameAction && _renaming,
                    onTap: item.isNicknameAction
                        ? () => _openNicknameChange(l10n, user?.displayName)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_ShopItem> _shopItems(AppLocalizations l10n) {
    return [
      _ShopItem(
        title: 'Blue Steel',
        subtitle: l10n.drones,
        assetPath: AppAssets.shopDroneSkinBlueSteel,
      ),
      _ShopItem(
        title: 'Desert Sand',
        subtitle: l10n.drones,
        assetPath: AppAssets.shopDroneSkinDesertSand,
      ),
      _ShopItem(
        title: 'Rocket Sand',
        subtitle: l10n.drones,
        assetPath: AppAssets.shopDroneSkinRocketSand,
      ),
      _ShopItem(
        title: 'Blue Spark',
        subtitle: l10n.flightTrails,
        assetPath: AppAssets.shopTrailParticleBlueSpark,
      ),
      _ShopItem(
        title: 'Smoke Exhaust',
        subtitle: l10n.flightTrails,
        assetPath: AppAssets.shopTrailParticleSmokeExhaust,
      ),
      _ShopItem(
        title: 'Steel Blue Frame',
        subtitle: l10n.profile,
        assetPath: AppAssets.shopProfileFrameSteelBlue,
      ),
      _ShopItem(
        title: 'Blue Steel Badge',
        subtitle: l10n.leaderboard,
        assetPath: AppAssets.shopLeaderboardBadgeBlueSteel,
      ),
      _ShopItem(
        title: l10n.nicknameChange,
        subtitle: l10n.nicknameChangeDescription,
        icon: Icons.badge_outlined,
        isNicknameAction: true,
      ),
      _ShopItem(
        title: l10n.premium,
        subtitle: l10n.comingSoon,
        icon: Icons.workspace_premium,
      ),
      _ShopItem(
        title: l10n.lives,
        subtitle: l10n.comingSoon,
        icon: Icons.favorite,
      ),
    ];
  }

  Future<void> _openNicknameChange(
    AppLocalizations l10n,
    String? currentDisplayName,
  ) async {
    final authState = ref.read(authControllerProvider).asData?.value;
    if (!(authState?.isAuthenticated ?? false)) {
      _showMessage(l10n.loginRequired, isError: true);
      return;
    }

    final controller = TextEditingController(text: currentDisplayName ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.nicknameChange),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.displayName,
              helperText: l10n.nicknameChangeDescription,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(l10n.accept),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (!mounted || value == null) {
      return;
    }
    if (!RegExp(r'^[A-Za-zА-Яа-яЁё0-9_]{3,20}$').hasMatch(value)) {
      _showMessage(l10n.invalidDisplayName, isError: true);
      return;
    }

    setState(() {
      _renaming = true;
      _message = null;
      _messageIsError = false;
    });
    await ref.read(profileControllerProvider).updateDisplayName(value);
    if (!mounted) {
      return;
    }
    setState(() {
      _renaming = false;
    });

    final errorMessage = ref
        .read(authControllerProvider)
        .asData
        ?.value
        .errorMessage;
    if (errorMessage != null) {
      _showMessage(errorMessage, isError: true);
      return;
    }
    _showMessage(l10n.displayNameChangeSuccess);
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }
    setState(() {
      _message = message;
      _messageIsError = isError;
    });
  }
}

class _ShopItem {
  const _ShopItem({
    required this.title,
    required this.subtitle,
    this.assetPath,
    this.icon,
    this.isNicknameAction = false,
  });

  final String title;
  final String subtitle;
  final String? assetPath;
  final IconData? icon;
  final bool isNicknameAction;
}

class _ShopItemCard extends StatelessWidget {
  const _ShopItemCard({
    required this.item,
    required this.unlocked,
    required this.loading,
    this.onTap,
  });

  final _ShopItem item;
  final bool unlocked;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusText = unlocked ? l10n.unlocked : l10n.comingSoon;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: loading ? null : onTap,
      child: GlassPanel(
        padding: const EdgeInsets.all(9),
        child: Row(
          children: [
            _ShopPreview(item: item, unlocked: unlocked),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(height: 1.05),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (loading) ...[
                        const SizedBox.square(
                          dimension: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: unlocked
                              ? const Color(0xFF6EE7D8)
                              : const Color(0xFF7CE7FF),
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF7CE7FF)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShopPreview extends StatelessWidget {
  const _ShopPreview({required this.item, required this.unlocked});

  final _ShopItem item;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final assetPath = item.assetPath;

    return Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x99071426),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: unlocked ? const Color(0xFF6EE7D8) : const Color(0x886EE7D8),
        ),
      ),
      child: assetPath == null
          ? Icon(
              item.icon ?? Icons.auto_awesome,
              color: const Color(0xFF7CE7FF),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(assetPath, fit: BoxFit.contain),
            ),
    );
  }
}
