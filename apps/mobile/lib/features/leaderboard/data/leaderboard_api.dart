import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'leaderboard_dto.dart';

class LeaderboardApi {
  const LeaderboardApi(this._apiClient);

  final ApiClient _apiClient;

  Future<LeaderboardResponseDto> getLeaderboard({int limit = 50}) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/leaderboard',
        queryParameters: {'limit': limit},
      );
      return LeaderboardResponseDto.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<LeaderboardMeResponseDto> getMyLeaderboardPlace() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/leaderboard/me');
      return LeaderboardMeResponseDto.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}
