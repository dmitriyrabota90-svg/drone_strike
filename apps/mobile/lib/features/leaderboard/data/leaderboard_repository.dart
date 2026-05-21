import '../../../core/network/api_exception.dart';
import '../../auth/data/auth_repository.dart';
import 'leaderboard_api.dart';
import 'leaderboard_dto.dart';

class LeaderboardRepository {
  const LeaderboardRepository({
    required LeaderboardApi leaderboardApi,
    required AuthRepository authRepository,
  }) : _leaderboardApi = leaderboardApi,
       _authRepository = authRepository;

  final LeaderboardApi _leaderboardApi;
  final AuthRepository _authRepository;

  Future<LeaderboardResponseDto> getLeaderboard({int limit = 50}) {
    return _withRefresh(() => _leaderboardApi.getLeaderboard(limit: limit));
  }

  Future<LeaderboardMeResponseDto> getMyLeaderboardPlace() {
    return _withRefresh(_leaderboardApi.getMyLeaderboardPlace);
  }

  Future<T> _withRefresh<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on ApiException catch (error) {
      if (!error.isUnauthorized) {
        rethrow;
      }
      final refreshed = await _authRepository.tryRefreshAccessToken();
      if (!refreshed) {
        rethrow;
      }
      return request();
    }
  }
}
