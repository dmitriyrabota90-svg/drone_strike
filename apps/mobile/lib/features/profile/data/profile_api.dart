import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'profile_dto.dart';

class ProfileApi {
  const ProfileApi(this._apiClient);

  final ApiClient _apiClient;

  Future<MeDto> getMe() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/me');
      return MeDto.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<MeDto> updateDisplayName(String displayName) async {
    try {
      final response = await _apiClient.dio.patch(
        '/api/v1/me/display-name',
        data: UpdateDisplayNameRequestDto(displayName: displayName).toJson(),
      );
      return MeDto.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}
