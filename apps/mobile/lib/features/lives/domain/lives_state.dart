class LivesState {
  const LivesState({
    required this.currentLives,
    required this.maxLives,
    required this.nextLifeAt,
    required this.recoverySecondsRemaining,
    required this.isPremium,
  });

  factory LivesState.full({bool isPremium = false}) {
    return LivesState(
      currentLives: isPremium ? premiumMaxLives : normalMaxLives,
      maxLives: isPremium ? premiumMaxLives : normalMaxLives,
      nextLifeAt: null,
      recoverySecondsRemaining: 0,
      isPremium: isPremium,
    );
  }

  static const normalMaxLives = 3;
  static const premiumMaxLives = 5;
  static const normalRecovery = Duration(minutes: 5);
  static const premiumRecovery = Duration(minutes: 4);

  final int currentLives;
  final int maxLives;
  final DateTime? nextLifeAt;
  final int recoverySecondsRemaining;
  final bool isPremium;

  bool get isFull => currentLives >= maxLives;
  bool get hasLives => currentLives > 0;
  Duration get recoveryDuration => isPremium ? premiumRecovery : normalRecovery;

  LivesState copyWith({
    int? currentLives,
    int? maxLives,
    DateTime? nextLifeAt,
    int? recoverySecondsRemaining,
    bool? isPremium,
    bool clearNextLifeAt = false,
  }) {
    return LivesState(
      currentLives: currentLives ?? this.currentLives,
      maxLives: maxLives ?? this.maxLives,
      nextLifeAt: clearNextLifeAt ? null : nextLifeAt ?? this.nextLifeAt,
      recoverySecondsRemaining:
          recoverySecondsRemaining ?? this.recoverySecondsRemaining,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
