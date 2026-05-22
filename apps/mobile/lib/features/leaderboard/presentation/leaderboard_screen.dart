import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/domain/auth_controller.dart';
import '../data/leaderboard_dto.dart';
import '../domain/leaderboard_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/glass_panel.dart';
import '../../../shared/widgets/menu_background.dart';
import '../../../shared/widgets/neon_menu_button.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider).asData?.value;
    final isAuthenticated = authState?.isAuthenticated ?? false;
    final leaderboardValue = ref.watch(leaderboardControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.leaderboard),
        leading: BackButton(onPressed: () => context.go('/menu')),
        actions: [
          if (isAuthenticated)
            IconButton(
              onPressed: () =>
                  ref.read(leaderboardControllerProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: MenuBackground(
        child: !isAuthenticated
            ? _GuestLeaderboard(l10n: l10n)
            : leaderboardValue.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => _ErrorState(
                  message: error.toString(),
                  onRetry: () => ref
                      .read(leaderboardControllerProvider.notifier)
                      .refresh(),
                ),
                data: (state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.errorMessage != null) {
                    return _ErrorState(
                      message: state.errorMessage!,
                      onRetry: () => ref
                          .read(leaderboardControllerProvider.notifier)
                          .refresh(),
                    );
                  }
                  final leaderboard = state.leaderboard;
                  if (leaderboard == null) {
                    return _ErrorState(
                      message: l10n.error,
                      onRetry: () => ref
                          .read(leaderboardControllerProvider.notifier)
                          .refresh(),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(leaderboardControllerProvider.notifier)
                        .refresh(),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (leaderboard.me != null) ...[
                          _CurrentPlayerCard(
                            me: leaderboard.me!,
                            totalCount: leaderboard.totalCount,
                          ),
                          const SizedBox(height: 12),
                        ],
                        for (final entry in leaderboard.entries) ...[
                          _LeaderboardEntryTile(entry: entry),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _GuestLeaderboard extends StatelessWidget {
  const _GuestLeaderboard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.loginRequiredToViewLeaderboard,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            NeonMenuButton(
              text: l10n.login,
              icon: Icons.login,
              onPressed: () => context.go('/login'),
            ),
            const SizedBox(height: 8),
            NeonMenuButton(
              text: l10n.register,
              icon: Icons.person_add,
              variant: NeonMenuButtonVariant.secondary,
              onPressed: () => context.go('/register'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentPlayerCard extends StatelessWidget {
  const _CurrentPlayerCard({required this.me, required this.totalCount});

  final CurrentPlayerLeaderboardEntryDto me;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.yourPlace, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('${l10n.rank}: ${me.rank} / $totalCount'),
          Text('${l10n.displayName}: ${me.displayName}'),
          Text('${l10n.playerLevel}: ${me.playerLevel}'),
          Text('${l10n.totalScore}: ${me.totalScore}'),
        ],
      ),
    );
  }
}

class _LeaderboardEntryTile extends StatelessWidget {
  const _LeaderboardEntryTile({required this.entry});

  final LeaderboardEntryDto entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GlassPanel(
      padding: EdgeInsets.zero,
      child: ListTile(
        tileColor: entry.isCurrentUser
            ? const Color(0x553AA7C9)
            : Colors.transparent,
        leading: CircleAvatar(child: Text('${entry.rank}')),
        title: Text(entry.displayName),
        subtitle: Text('${l10n.playerLevel}: ${entry.playerLevel}'),
        trailing: Text('${entry.totalScore}'),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            NeonMenuButton(
              text: l10n.refresh,
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
