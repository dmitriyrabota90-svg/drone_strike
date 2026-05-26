import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/lives/domain/lives_controller.dart';
import '../../l10n/generated/app_localizations.dart';

class NoLivesOverlay extends ConsumerStatefulWidget {
  const NoLivesOverlay({super.key});

  @override
  ConsumerState<NoLivesOverlay> createState() => _NoLivesOverlayState();
}

class _NoLivesOverlayState extends ConsumerState<NoLivesOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(livesControllerProvider.notifier).refreshTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lives = ref.watch(livesControllerProvider).asData?.value;
    final seconds = lives?.recoverySecondsRemaining ?? 0;

    return ColoredBox(
      color: const Color(0xDD061426),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${l10n.nextLifeIn}: ${_formatCountdown(seconds, l10n)}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/levels'),
                    icon: const Icon(Icons.grid_view),
                    label: Text(l10n.levelSelect),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/menu'),
                    icon: const Icon(Icons.home),
                    label: Text(l10n.mainMenu),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/shop'),
                    icon: const Icon(Icons.storefront),
                    label: Text(l10n.shop),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatCountdown(int seconds, AppLocalizations l10n) {
    if (seconds <= 0) {
      return l10n.aboutFiveMinutes;
    }
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
