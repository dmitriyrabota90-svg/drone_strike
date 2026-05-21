import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import 'auth_dto.dart';

class AuthApi {
  const AuthApi(this._apiClient);

  final ApiClient _apiClient;

  Future<TokenResponseDto> register(RegisterRequestDto request) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/auth/register',
        data: request.toJson(),
      );
      return TokenResponseDto.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<TokenResponseDto> login(LoginRequestDto request) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/auth/login',
        data: request.toJson(),
      );
      return TokenResponseDto.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<TokenResponseDto> refresh(String refreshToken) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/auth/refresh',
        data: RefreshRequestDto(refreshToken: refreshToken).toJson(),
      );
      return TokenResponseDto.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _apiClient.dio.post(
        '/api/v1/auth/logout',
        data: RefreshRequestDto(refreshToken: refreshToken).toJson(),
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<void> deleteAccount(String password) async {
    try {
      await _apiClient.dio.post(
        '/api/v1/auth/delete-account',
        data: DeleteAccountRequestDto(password: password).toJson(),
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}
