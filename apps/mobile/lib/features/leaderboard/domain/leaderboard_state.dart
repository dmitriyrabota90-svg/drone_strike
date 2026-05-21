import '../data/leaderboard_dto.dart';

class LeaderboardState {
  const LeaderboardState({
    this.isLoading = false,
    this.leaderboard,
    this.errorMessage,
  });

  final bool isLoading;
  final LeaderboardResponseDto? leaderboard;
  final String? errorMessage;

  LeaderboardState copyWith({
    bool? isLoading,
    LeaderboardResponseDto? leaderboard,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LeaderboardState(
      isLoading: isLoading ?? this.isLoading,
      leaderboard: leaderboard ?? this.leaderboard,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
