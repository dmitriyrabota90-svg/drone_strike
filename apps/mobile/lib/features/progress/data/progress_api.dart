import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'progress_dto.dart';

class ProgressApi {
  const ProgressApi(this._apiClient);

  final ApiClient _apiClient;

  Future<ProgressResponseDto> getProgress() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/progress');
      return ProgressResponseDto.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<MissionCompleteResponseDto> completeMission(
    MissionCompleteRequestDto request,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/progress/mission-complete',
        data: request.toJson(),
      );
      return MissionCompleteResponseDto.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}
