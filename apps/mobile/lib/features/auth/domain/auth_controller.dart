import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers.dart';
import '../../profile/data/profile_dto.dart';
import '../data/auth_dto.dart';
import 'auth_state.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final authRepository = ref.read(authRepositoryProvider);
    final hasTokens = await authRepository.hasTokens().timeout(
      const Duration(milliseconds: 500),
      onTimeout: () => false,
    );
    if (!hasTokens) {
      return const AuthState.guest();
    }

    try {
      final user = await _withRefresh(() {
        return ref.read(profileRepositoryProvider).getMe();
      });
      return AuthState.authenticated(user);
    } on Object {
      await authRepository.clearLocalTokens();
      return const AuthState.guest();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required bool acceptedTerms,
    required bool acceptedPersonalData,
    required bool isAtLeast13,
  }) async {
    await _authenticate(() async {
      await ref
          .read(authRepositoryProvider)
          .register(
            RegisterRequestDto(
              email: email,
              password: password,
              acceptedTerms: acceptedTerms,
              acceptedPersonalData: acceptedPersonalData,
              isAtLeast13: isAtLeast13,
            ),
          );
      return _withRefresh(() => ref.read(profileRepositoryProvider).getMe());
    });
  }

  Future<void> login({required String email, required String password}) async {
    await _authenticate(() async {
      await ref
          .read(authRepositoryProvider)
          .login(LoginRequestDto(email: email, password: password));
      return _withRefresh(() => ref.read(profileRepositoryProvider).getMe());
    });
  }

  Future<void> logout() async {
    final current = _currentState;
    state = AsyncData(current.copyWith(isLoading: true, clearError: true));
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(AuthState.guest());
  }

  Future<void> deleteAccount(String password) async {
    final current = _currentState;
    state = AsyncData(current.copyWith(isLoading: true, clearError: true));

    try {
      await _withRefresh(
        () => ref.read(authRepositoryProvider).deleteAccount(password),
      );
      state = const AsyncData(AuthState.guest());
    } on Object catch (error) {
      state = AsyncData(
        current.copyWith(isLoading: false, errorMessage: _errorMessage(error)),
      );
    }
  }

  Future<void> reloadMe() async {
    final current = _currentState;
    if (!await ref.read(authRepositoryProvider).hasTokens()) {
      state = const AsyncData(AuthState.guest());
      return;
    }

    state = AsyncData(current.copyWith(isLoading: true, clearError: true));
    try {
      final user = await _withRefresh(
        () => ref.read(profileRepositoryProvider).getMe(),
      );
      state = AsyncData(AuthState.authenticated(user));
    } on Object catch (error) {
      state = AsyncData(
        current.copyWith(isLoading: false, errorMessage: _errorMessage(error)),
      );
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    final current = _currentState;
    state = AsyncData(current.copyWith(isLoading: true, clearError: true));

    try {
      final user = await _withRefresh(() {
        return ref
            .read(profileRepositoryProvider)
            .updateDisplayName(displayName);
      });
      state = AsyncData(AuthState.authenticated(user));
    } on Object catch (error) {
      state = AsyncData(
        current.copyWith(isLoading: false, errorMessage: _errorMessage(error)),
      );
    }
  }

  AuthState get _currentState => state.asData?.value ?? const AuthState.guest();

  Future<void> _authenticate(Future<MeDto> Function() request) async {
    final current = _currentState;
    state = AsyncData(current.copyWith(isLoading: true, clearError: true));

    try {
      final user = await request();
      state = AsyncData(AuthState.authenticated(user));
    } on Object catch (error) {
      state = AsyncData(
        current.copyWith(isLoading: false, errorMessage: _errorMessage(error)),
      );
    }
  }

  Future<T> _withRefresh<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on ApiException catch (error) {
      if (!error.isUnauthorized) {
        rethrow;
      }

      final refreshed = await ref
          .read(authRepositoryProvider)
          .tryRefreshAccessToken();
      if (!refreshed) {
        await ref.read(authRepositoryProvider).clearLocalTokens();
        rethrow;
      }

      return request();
    }
  }

  String _errorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Unexpected error.';
  }
}
