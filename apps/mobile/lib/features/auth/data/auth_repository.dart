import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_token_storage.dart';
import 'auth_api.dart';
import 'auth_dto.dart';

class AuthRepository {
  const AuthRepository({
    required AuthApi authApi,
    required SecureTokenStorage tokenStorage,
    required ApiClient apiClient,
  }) : _authApi = authApi,
       _tokenStorage = tokenStorage,
       _apiClient = apiClient;

  final AuthApi _authApi;
  final SecureTokenStorage _tokenStorage;
  final ApiClient _apiClient;

  Future<void> register(RegisterRequestDto request) async {
    final tokens = await _authApi.register(request);
    await _saveTokens(tokens);
  }

  Future<void> login(LoginRequestDto request) async {
    final tokens = await _authApi.login(request);
    await _saveTokens(tokens);
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _authApi.logout(refreshToken);
      }
    } on Object {
      // Local logout must still succeed when the backend is unreachable.
    } finally {
      await _clearTokens();
    }
  }

  Future<void> deleteAccount(String password) async {
    await _authApi.deleteAccount(password);
    await _clearTokens();
  }

  Future<bool> tryRefreshAccessToken() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final tokens = await _authApi.refresh(refreshToken);
      await _saveTokens(tokens);
      return true;
    } on Object {
      await _clearTokens();
      return false;
    }
  }

  Future<bool> hasTokens() async {
    final accessToken = await _tokenStorage.readAccessToken();
    final refreshToken = await _tokenStorage.readRefreshToken();
    return accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty;
  }

  Future<void> clearLocalTokens() => _clearTokens();

  Future<void> _saveTokens(TokenResponseDto tokens) async {
    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    _apiClient.setAccessToken(tokens.accessToken);
  }

  Future<void> _clearTokens() async {
    await _tokenStorage.clearTokens();
    _apiClient.setAccessToken(null);
  }
}
