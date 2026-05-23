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

  static const normalMaxLives = 5;
  static const premiumMaxLives = 5;
  static const normalRecovery = Duration(seconds: 90);
  static const premiumRecovery = normalRecovery;

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
