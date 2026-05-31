import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/lives_repository.dart';
import 'lives_state.dart';

final livesRepositoryProvider = Provider<LivesRepository>((ref) {
  return LivesRepository();
});

final livesControllerProvider =
    AsyncNotifierProvider<LivesController, LivesState>(LivesController.new);

class LivesController extends AsyncNotifier<LivesState> {
  Timer? _timer;
  bool _refreshInFlight = false;

  @override
  Future<LivesState> build() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(_refreshFromTimer());
    });
    ref.onDispose(() {
      _timer?.cancel();
      _timer = null;
    });
    return ref.read(livesRepositoryProvider).load();
  }

  Future<void> load() async {
    state = AsyncData(await ref.read(livesRepositoryProvider).load());
  }

  Future<LivesState> spendLife() async {
    final next = await ref.read(livesRepositoryProvider).spendLife();
    state = AsyncData(next);
    return next;
  }

  Future<void> recover() async {
    state = AsyncData(
      await ref.read(livesRepositoryProvider).recoverLivesIfNeeded(),
    );
  }

  Future<void> refreshTimer() => recover();

  Future<void> resetToFull() async {
    final full = LivesState.full();
    await ref.read(livesRepositoryProvider).save(full);
    state = AsyncData(full);
  }

  bool get hasLives => state.asData?.value.hasLives ?? true;

  Future<void> _refreshFromTimer() async {
    if (_refreshInFlight) {
      return;
    }
    _refreshInFlight = true;
    try {
      await recover();
    } finally {
      _refreshInFlight = false;
    }
  }
}
