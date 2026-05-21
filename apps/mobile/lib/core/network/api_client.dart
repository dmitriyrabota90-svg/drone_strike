import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/secure_token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({Dio? dio, SecureTokenStorage? tokenStorage})
    : _tokenStorage = tokenStorage,
      dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              headers: const {
                Headers.acceptHeader: Headers.jsonContentType,
                Headers.contentTypeHeader: Headers.jsonContentType,
              },
            ),
          ) {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _accessToken ?? await _tokenStorage?.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio dio;
  final SecureTokenStorage? _tokenStorage;
  String? _accessToken;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  // Keep this client aligned with docs/technical/mobile_api_contract.md.
  Future<Response<dynamic>> getHealth() async {
    try {
      return await dio.get('/api/v1/health');
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}
