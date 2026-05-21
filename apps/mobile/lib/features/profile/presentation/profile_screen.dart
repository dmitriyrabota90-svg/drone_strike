import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/domain/auth_controller.dart';
import '../../progress/domain/progress_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authValue = ref.watch(authControllerProvider);
    final progressValue = ref.watch(progressControllerProvider);
    final progressState = progressValue.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        leading: BackButton(onPressed: () => context.go('/menu')),
      ),
      body: authValue.when(
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
              if (authState.errorMessage != null) ...[
                Text(
                  authState.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
              ],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(label: l10n.email, value: user.email),
                      _InfoRow(
                        label: l10n.emailStatus,
                        value: user.emailVerified
                            ? l10n.emailVerified
                            : l10n.emailNotVerified,
                      ),
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
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
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
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        await ref.read(profileControllerProvider).reloadMe();
                        await ref
                            .read(progressControllerProvider.notifier)
                            .refreshProgress();
                      },
                icon: const Icon(Icons.refresh),
                label: Text(l10n.refresh),
              ),
              const SizedBox(height: 12),
              if (!user.nameChangedOnce)
                OutlinedButton.icon(
                  onPressed: authState.isLoading
                      ? null
                      : () => _showDisplayNameDialog(context, ref, l10n),
                  icon: const Icon(Icons.edit),
                  label: Text(l10n.changeDisplayName),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: authState.isLoading
                    ? null
                    : () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .logout();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.logoutSuccess)),
                          );
                          context.go('/menu');
                        }
                      },
                icon: const Icon(Icons.logout),
                label: Text(l10n.logout),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showDisplayNameDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
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

    if (value == null) {
      return;
    }
    if (!RegExp(r'^[A-Za-z0-9_]{3,20}$').hasMatch(value)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.invalidDisplayName)));
      }
      return;
    }

    await ref.read(profileControllerProvider).updateDisplayName(value);
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
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
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
                Text('${l10n.mission} 1-2: ${l10n.available}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.login),
          label: Text(l10n.login),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.go('/register'),
          icon: const Icon(Icons.person_add),
          label: Text(l10n.register),
        ),
      ],
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
