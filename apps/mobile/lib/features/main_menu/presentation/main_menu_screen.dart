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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 720;
            final identity = _PilotIdentity(
              displayName: user?.displayName ?? l10n.guestMode,
              isGuest: user == null,
            );
            final actions = _MainActions(
              l10n: l10n,
              showContinue: showContinue,
              isProgressLoading: isProgressLoading,
              onContinue: () {
                final unlockedMission = progressState?.unlockedMission ?? 1;
                if (unlockedMission >= 1 && unlockedMission < 10) {
                  context.go('/game/$unlockedMission');
                  return;
                }
                context.go('/levels');
              },
              onPlay: () => context.go('/levels'),
              onProfile: () => context.go('/profile'),
              onSettings: () => context.go('/settings'),
              onExit: () => _showExitDialog(context, l10n),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: wide
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: identity),
                            const SizedBox(width: 28),
                            SizedBox(width: 360, child: actions),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            identity,
                            const SizedBox(height: 18),
                            actions,
                          ],
                        ),
                ),
              ),
            );
          },
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

class _PilotIdentity extends StatelessWidget {
  const _PilotIdentity({required this.displayName, required this.isGuest});

  final String displayName;
  final bool isGuest;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(AppAssets.logo, height: 150, fit: BoxFit.contain),
        const SizedBox(height: 12),
        GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isGuest ? Icons.person_outline : Icons.radar,
                size: 18,
                color: const Color(0xFF70E7FF),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  displayName,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MainActions extends StatelessWidget {
  const _MainActions({
    required this.l10n,
    required this.showContinue,
    required this.isProgressLoading,
    required this.onContinue,
    required this.onPlay,
    required this.onProfile,
    required this.onSettings,
    required this.onExit,
  });

  final AppLocalizations l10n;
  final bool showContinue;
  final bool isProgressLoading;
  final VoidCallback onContinue;
  final VoidCallback onPlay;
  final VoidCallback onProfile;
  final VoidCallback onSettings;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isProgressLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(),
            ),
          if (showContinue)
            _MenuButton(
              label: l10n.continueGame,
              icon: Icons.play_circle,
              onPressed: onContinue,
            ),
          _MenuButton(
            label: l10n.play,
            icon: Icons.play_arrow_rounded,
            variant: NeonMenuButtonVariant.primary,
            onPressed: onPlay,
          ),
          _MenuButton(
            label: l10n.profile,
            icon: Icons.person,
            onPressed: onProfile,
          ),
          _MenuButton(
            label: l10n.settings,
            icon: Icons.settings,
            onPressed: onSettings,
          ),
          TextButton.icon(
            onPressed: onExit,
            icon: const Icon(Icons.logout),
            label: Text(l10n.exit),
          ),
        ],
      ),
    );
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
