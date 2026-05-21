import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/domain/auth_controller.dart';
import '../../progress/domain/progress_controller.dart';
import '../../../l10n/generated/app_localizations.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider).asData?.value;
    final user = authState?.user;
    final progressValue = ref.watch(progressControllerProvider);
    final progressState = progressValue.asData?.value;
    final showContinue = progressState?.hasCompletedAnyMission ?? false;
    final isProgressLoading =
        progressState?.isLoading == true || progressValue.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                const Icon(Icons.flight_takeoff, size: 56),
                const SizedBox(height: 16),
                Text(
                  l10n.appTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.displayName ?? l10n.guestMode,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 28),
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
                  onPressed: null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
