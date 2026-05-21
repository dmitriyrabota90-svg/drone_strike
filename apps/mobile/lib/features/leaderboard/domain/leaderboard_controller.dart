import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers.dart';
import '../../auth/domain/auth_controller.dart';
import 'leaderboard_state.dart';

final leaderboardControllerProvider =
    AsyncNotifierProvider<LeaderboardController, LeaderboardState>(
      LeaderboardController.new,
    );

class LeaderboardController extends AsyncNotifier<LeaderboardState> {
  @override
  Future<LeaderboardState> build() async {
    final authState = ref.watch(authControllerProvider).asData?.value;
    if (authState?.isAuthenticated != true) {
      return const LeaderboardState();
    }
    return _load(limit: 50);
  }

  Future<void> loadLeaderboard({int limit = 50}) async {
    final authState = ref.read(authControllerProvider).asData?.value;
    if (authState?.isAuthenticated != true) {
      state = const AsyncData(LeaderboardState());
      return;
    }

    state = AsyncData(_current.copyWith(isLoading: true, clearError: true));
    state = AsyncData(await _load(limit: limit));
  }

  Future<void> refresh() => loadLeaderboard();

  LeaderboardState get _current =>
      state.asData?.value ?? const LeaderboardState();

  Future<LeaderboardState> _load({required int limit}) async {
    try {
      final leaderboard = await ref
          .read(leaderboardRepositoryProvider)
          .getLeaderboard(limit: limit);
      return LeaderboardState(leaderboard: leaderboard);
    } on Object catch (error) {
      return _current.copyWith(
        isLoading: false,
        errorMessage: _errorMessage(error),
      );
    }
  }

  String _errorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Unexpected error.';
  }
}
