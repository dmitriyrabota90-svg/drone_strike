import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/domain/auth_controller.dart';
import '../../progress/domain/progress_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/menu_background.dart';
import '../../../shared/widgets/neon_menu_button.dart';
import '../domain/profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? _feedbackMessage;
  bool _feedbackIsError = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authValue = ref.watch(authControllerProvider);
    final progressValue = ref.watch(progressControllerProvider);
    final progressState = progressValue.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        leading: BackButton(onPressed: () => context.go('/menu')),
      ),
      body: MenuBackground(
        child: authValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _GuestProfile(l10n: l10n),
          data: (authState) {
            if (!authState.isAuthenticated || authState.user == null) {
              return _GuestProfile(l10n: l10n);
            }

            final user = authState.user!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_feedbackMessage != null) ...[
                  GlassPanel(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Text(
                      _feedbackMessage!,
                      style: TextStyle(
                        color: _feedbackIsError
                            ? Theme.of(context).colorScheme.error
                            : const Color(0xFF8EF7FF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (authState.errorMessage != null) ...[
                  Text(
                    authState.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(label: l10n.email, value: user.email),
                      _InfoRow(
                        label: l10n.emailStatus,
                        value: user.emailVerified
                            ? l10n.emailVerified
                            : l10n.emailNotVerified,
                      ),
                      if (!user.emailVerified) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: authState.isLoading
                                ? null
                                : () => _requestEmailVerification(l10n),
                            icon: const Icon(Icons.mark_email_unread_outlined),
                            label: Text(l10n.confirmEmail),
                          ),
                        ),
                      ],
                      _InfoRow(
                        label: l10n.totalScore,
                        value:
                            '${progressState?.totalScore ?? user.totalScore}',
                      ),
                      _InfoRow(
                        label: l10n.playerLevel,
                        value:
                            '${progressState?.playerLevel ?? user.playerLevel}',
                      ),
                      _InfoRow(
                        label: l10n.premium,
                        value: user.isPremium
                            ? l10n.premium
                            : l10n.regularAccount,
                      ),
                      _InfoRow(
                        label: l10n.nameChangedOnce,
                        value: user.nameChangedOnce
                            ? l10n.used
                            : l10n.available,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _ProfileNavigationPanel(l10n: l10n),
                const SizedBox(height: 16),
                GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.progress,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: l10n.completedMissions,
                        value: '${progressState?.completedMissionsCount ?? 0}',
                      ),
                      _InfoRow(
                        label: l10n.unlockedMission,
                        value: '${progressState?.unlockedMission ?? 1}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                NeonMenuButton(
                  text: l10n.refresh,
                  icon: Icons.refresh,
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          await ref.read(profileControllerProvider).reloadMe();
                          await ref
                              .read(progressControllerProvider.notifier)
                              .refreshProgress();
                        },
                ),
                const SizedBox(height: 12),
                if (!user.nameChangedOnce)
                  NeonMenuButton(
                    text: l10n.changeDisplayName,
                    icon: Icons.edit,
                    variant: NeonMenuButtonVariant.secondary,
                    onPressed: authState.isLoading
                        ? null
                        : () => _showDisplayNameDialog(l10n),
                  ),
                const SizedBox(height: 12),
                NeonMenuButton(
                  text: l10n.logout,
                  icon: Icons.logout,
                  variant: NeonMenuButtonVariant.secondary,
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          await ref
                              .read(authControllerProvider.notifier)
                              .logout();
                          if (!mounted) {
                            return;
                          }
                          this.context.go('/menu');
                        },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _requestEmailVerification(AppLocalizations l10n) async {
    await ref.read(profileControllerProvider).requestEmailVerification();
    if (!mounted) {
      return;
    }

    final authState = ref.read(authControllerProvider).asData?.value;
    final errorMessage = authState?.errorMessage;
    if (errorMessage != null) {
      _showInlineMessage(errorMessage, isError: true);
      return;
    }
    _showInlineMessage(l10n.emailVerificationSent);
  }

  Future<void> _showDisplayNameDialog(AppLocalizations l10n) async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.changeDisplayName),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: l10n.displayName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.back),
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

    if (!mounted) {
      return;
    }
    if (value == null) {
      return;
    }
    if (!RegExp(r'^[A-Za-zА-Яа-яЁё0-9_]{3,20}$').hasMatch(value)) {
      _showInlineMessage(l10n.invalidDisplayName, isError: true);
      return;
    }

    await ref.read(profileControllerProvider).updateDisplayName(value);
    if (!mounted) {
      return;
    }

    final authState = ref.read(authControllerProvider).asData?.value;
    final errorMessage = authState?.errorMessage;
    if (errorMessage != null) {
      _showInlineMessage(errorMessage, isError: true);
      return;
    }
    _showInlineMessage(l10n.displayNameChangeSuccess);
  }

  void _showInlineMessage(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }
    setState(() {
      _feedbackMessage = message;
      _feedbackIsError = isError;
    });
  }
}

class _GuestProfile extends StatelessWidget {
  const _GuestProfile({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.guestMode,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(l10n.loginRequired),
              const SizedBox(height: 12),
              Text('${l10n.mission} 1: ${l10n.available}'),
              Text('${l10n.mission} 2: ${l10n.completePreviousMission}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ProfileNavigationPanel(l10n: l10n),
        const SizedBox(height: 16),
        NeonMenuButton(
          text: l10n.login,
          icon: Icons.login,
          onPressed: () => context.go('/login'),
        ),
        const SizedBox(height: 12),
        NeonMenuButton(
          text: l10n.register,
          icon: Icons.person_add,
          variant: NeonMenuButtonVariant.secondary,
          onPressed: () => context.go('/register'),
        ),
      ],
    );
  }
}

class _ProfileNavigationPanel extends StatelessWidget {
  const _ProfileNavigationPanel({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 520;
          final buttons = [
            _ProfileNavButton(
              label: l10n.achievements,
              icon: Icons.military_tech,
              route: '/achievements',
            ),
            _ProfileNavButton(
              label: l10n.leaderboard,
              icon: Icons.leaderboard,
              route: '/leaderboard',
            ),
            _ProfileNavButton(
              label: l10n.shop,
              icon: Icons.storefront,
              route: '/shop',
            ),
            _ProfileNavButton(
              label: l10n.settings,
              icon: Icons.settings,
              route: '/settings',
            ),
          ];

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final button in buttons) ...[
                  button,
                  if (button != buttons.last) const SizedBox(height: 10),
                ],
              ],
            );
          }

          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final button in buttons)
                SizedBox(width: (constraints.maxWidth - 10) / 2, child: button),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileNavButton extends StatelessWidget {
  const _ProfileNavButton({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return NeonMenuButton(
      text: label,
      icon: icon,
      variant: NeonMenuButtonVariant.secondary,
      onPressed: () => context.go(route),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
