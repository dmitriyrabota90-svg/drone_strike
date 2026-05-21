import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/lives_repository.dart';
import 'lives_state.dart';

final livesRepositoryProvider = Provider<LivesRepository>((ref) {
  return LivesRepository();
});

final livesControllerProvider =
    AsyncNotifierProvider<LivesController, LivesState>(LivesController.new);

class LivesController extends AsyncNotifier<LivesState> {
  @override
  Future<LivesState> build() {
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

  bool get hasLives => state.asData?.value.hasLives ?? true;
}
