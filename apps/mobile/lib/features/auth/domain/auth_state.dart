import '../../profile/data/profile_dto.dart';

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
  });

  const AuthState.guest({String? errorMessage})
    : this(errorMessage: errorMessage);

  factory AuthState.authenticated(MeDto user) {
    return AuthState(isAuthenticated: true, user: user);
  }

  final bool isLoading;
  final bool isAuthenticated;
  final MeDto? user;
  final String? errorMessage;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    MeDto? user,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
