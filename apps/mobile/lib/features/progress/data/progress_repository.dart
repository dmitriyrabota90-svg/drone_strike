import '../../../core/network/api_exception.dart';
import '../../auth/data/auth_repository.dart';
import 'progress_api.dart';
import 'progress_dto.dart';

class ProgressRepository {
  const ProgressRepository({
    required ProgressApi progressApi,
    required AuthRepository authRepository,
  }) : _progressApi = progressApi,
       _authRepository = authRepository;

  final ProgressApi _progressApi;
  final AuthRepository _authRepository;

  Future<ProgressResponseDto> getProgress() {
    return _withRefresh(_progressApi.getProgress);
  }

  Future<MissionCompleteResponseDto> completeMission({
    required int missionNumber,
    required int flightAccuracyBonus,
    required int tankHitBonus,
  }) {
    return _withRefresh(
      () => _progressApi.completeMission(
        MissionCompleteRequestDto(
          missionNumber: missionNumber,
          flightAccuracyBonus: flightAccuracyBonus,
          tankHitBonus: tankHitBonus,
        ),
      ),
    );
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
