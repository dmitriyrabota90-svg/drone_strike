class LeaderboardEntryDto {
  const LeaderboardEntryDto({
    required this.rank,
    required this.displayName,
    required this.totalScore,
    required this.playerLevel,
    required this.isCurrentUser,
  });

  final int rank;
  final String displayName;
  final int totalScore;
  final int playerLevel;
  final bool isCurrentUser;

  factory LeaderboardEntryDto.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryDto(
      rank: json['rank'] as int,
      displayName: json['display_name'] as String,
      totalScore: json['total_score'] as int,
      playerLevel: json['player_level'] as int,
      isCurrentUser: json['is_current_user'] as bool? ?? false,
    );
  }
}

class CurrentPlayerLeaderboardEntryDto {
  const CurrentPlayerLeaderboardEntryDto({
    required this.rank,
    required this.displayName,
    required this.totalScore,
    required this.playerLevel,
  });

  final int rank;
  final String displayName;
  final int totalScore;
  final int playerLevel;

  factory CurrentPlayerLeaderboardEntryDto.fromJson(Map<String, dynamic> json) {
    return CurrentPlayerLeaderboardEntryDto(
      rank: json['rank'] as int,
      displayName: json['display_name'] as String,
      totalScore: json['total_score'] as int,
      playerLevel: json['player_level'] as int,
    );
  }
}

class LeaderboardResponseDto {
  const LeaderboardResponseDto({
    required this.entries,
    required this.me,
    required this.totalCount,
  });

  final List<LeaderboardEntryDto> entries;
  final CurrentPlayerLeaderboardEntryDto? me;
  final int totalCount;

  factory LeaderboardResponseDto.fromJson(Map<String, dynamic> json) {
    final entries = json['entries'] as List<dynamic>? ?? const [];
    final me = json['me'];
    return LeaderboardResponseDto(
      entries: entries
          .map(
            (item) => LeaderboardEntryDto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      me: me == null
          ? null
          : CurrentPlayerLeaderboardEntryDto.fromJson(
              Map<String, dynamic>.from(me as Map),
            ),
      totalCount: json['total_count'] as int,
    );
  }
}

class LeaderboardMeResponseDto {
  const LeaderboardMeResponseDto({
    required this.rank,
    required this.displayName,
    required this.totalScore,
    required this.playerLevel,
    required this.totalCount,
  });

  final int rank;
  final String displayName;
  final int totalScore;
  final int playerLevel;
  final int totalCount;

  factory LeaderboardMeResponseDto.fromJson(Map<String, dynamic> json) {
    return LeaderboardMeResponseDto(
      rank: json['rank'] as int,
      displayName: json['display_name'] as String,
      totalScore: json['total_score'] as int,
      playerLevel: json['player_level'] as int,
      totalCount: json['total_count'] as int,
    );
  }
}
