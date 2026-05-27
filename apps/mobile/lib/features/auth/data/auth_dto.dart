class RegisterRequestDto {
  const RegisterRequestDto({
    required this.email,
    required this.password,
    required this.acceptedTerms,
    required this.acceptedPersonalData,
    required this.isAtLeast13,
  });

  final String email;
  final String password;
  final bool acceptedTerms;
  final bool acceptedPersonalData;
  final bool isAtLeast13;

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'accepted_terms': acceptedTerms,
    'accepted_personal_data': acceptedPersonalData,
    'is_at_least_13': isAtLeast13,
  };
}

class LoginRequestDto {
  const LoginRequestDto({required this.email, required this.password});

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RefreshRequestDto {
  const RefreshRequestDto({required this.refreshToken});

  final String refreshToken;

  Map<String, dynamic> toJson() => {'refresh_token': refreshToken};
}

class DeleteAccountRequestDto {
  const DeleteAccountRequestDto({required this.password});

  final String password;

  Map<String, dynamic> toJson() => {'password': password};
}

class PasswordResetRequestDto {
  const PasswordResetRequestDto({required this.email});

  final String email;

  Map<String, dynamic> toJson() => {'email': email};
}

class TokenResponseDto {
  const TokenResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;

  factory TokenResponseDto.fromJson(Map<String, dynamic> json) {
    return TokenResponseDto(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
    );
  }
}
