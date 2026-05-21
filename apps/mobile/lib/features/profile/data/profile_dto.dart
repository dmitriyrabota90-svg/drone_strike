class MeDto {
  const MeDto({
    required this.id,
    required this.email,
    required this.emailVerified,
    required this.displayName,
    required this.nameChangedOnce,
    required this.totalScore,
    required this.playerLevel,
    required this.isPremium,
  });

  final String id;
  final String email;
  final bool emailVerified;
  final String displayName;
  final bool nameChangedOnce;
  final int totalScore;
  final int playerLevel;
  final bool isPremium;

  factory MeDto.fromJson(Map<String, dynamic> json) {
    return MeDto(
      id: json['id'] as String,
      email: json['email'] as String,
      emailVerified: json['email_verified'] as bool,
      displayName: json['display_name'] as String,
      nameChangedOnce: json['name_changed_once'] as bool,
      totalScore: json['total_score'] as int,
      playerLevel: json['player_level'] as int,
      isPremium: json['is_premium'] as bool,
    );
  }
}

class UpdateDisplayNameRequestDto {
  const UpdateDisplayNameRequestDto({required this.displayName});

  final String displayName;

  Map<String, dynamic> toJson() => {'display_name': displayName};
}
