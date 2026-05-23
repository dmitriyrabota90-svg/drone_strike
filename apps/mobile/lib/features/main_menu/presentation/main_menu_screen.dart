import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/assets/app_assets.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/menu_background.dart';
import '../../../shared/widgets/neon_menu_button.dart';
import '../../auth/domain/auth_controller.dart';
import '../../progress/domain/progress_controller.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({super.key});

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> {
  bool _menuMusicRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_menuMusicRequested) {
      return;
    }
    _menuMusicRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(audioServiceProvider).playMenuMusic();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider).asData?.value;
    final user = authState?.user;
    final progressValue = ref.watch(progressControllerProvider);
    final progressState = progressValue.asData?.value;
    final showContinue = progressState?.hasCompletedAnyMission ?? false;
    final isProgressLoading =
        progressState?.isLoading == true || progressValue.isLoading;

    return Scaffold(
      body: MenuBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Image.asset(AppAssets.logo, height: 166, fit: BoxFit.contain),
                const SizedBox(height: 10),
                GlassPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        user == null ? Icons.person_outline : Icons.radar,
                        size: 18,
                        color: const Color(0xFF70E7FF),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          user?.displayName ?? l10n.guestMode,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (isProgressLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(),
                  ),
                if (showContinue)
                  _MenuButton(
                    label: l10n.continueGame,
                    icon: Icons.play_circle,
                    onPressed: () {
                      final unlockedMission =
                          progressState?.unlockedMission ?? 1;
                      if (unlockedMission >= 1 && unlockedMission < 10) {
                        context.go('/game/$unlockedMission');
                        return;
                      }
                      context.go('/levels');
                    },
                  ),
                if (user == null)
                  _MenuButton(
                    label: l10n.login,
                    icon: Icons.login,
                    onPressed: () => context.go('/login'),
                  ),
                _MenuButton(
                  label: l10n.levelSelect,
                  icon: Icons.grid_view,
                  variant: NeonMenuButtonVariant.primary,
                  onPressed: () => context.go('/levels'),
                ),
                _MenuButton(
                  label: l10n.profile,
                  icon: Icons.person,
                  onPressed: () => context.go('/profile'),
                ),
                _MenuButton(
                  label: l10n.achievements,
                  icon: Icons.military_tech,
                  onPressed: () => context.go('/achievements'),
                ),
                _MenuButton(
                  label: l10n.leaderboard,
                  icon: Icons.leaderboard,
                  onPressed: () => context.go('/leaderboard'),
                ),
                _MenuButton(
                  label: l10n.shop,
                  icon: Icons.storefront,
                  onPressed: () => context.go('/shop'),
                ),
                _MenuButton(
                  label: l10n.settings,
                  icon: Icons.settings,
                  onPressed: () => context.go('/settings'),
                ),
                _MenuButton(
                  label: l10n.exit,
                  icon: Icons.logout,
                  variant: NeonMenuButtonVariant.danger,
                  onPressed: () => _showExitDialog(context, l10n),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showExitDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.exitGameTitle),
          content: Text(l10n.exitGameMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.exitConfirm),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.variant = NeonMenuButtonVariant.secondary,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final NeonMenuButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeonMenuButton(
        text: label,
        icon: icon,
        onPressed: onPressed,
        variant: variant,
      ),
    );
  }
}
