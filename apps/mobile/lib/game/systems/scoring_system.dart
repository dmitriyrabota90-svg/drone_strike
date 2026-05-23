import 'dart:math' as math;
import 'dart:ui';

class MissionResult {
  const MissionResult({
    required this.missionNumber,
    required this.baseScore,
    required this.flightAccuracyBonus,
    required this.tankHitBonus,
    required this.totalScore,
    required this.isGuest,
    required this.backendSubmitted,
    this.batteriesCollected = 0,
    this.batteryBonus = 0,
    this.scoreImproved,
    this.savedBestScore,
    this.totalPlayerScore,
    this.playerLevel,
  });

  final int missionNumber;
  final int baseScore;
  final int flightAccuracyBonus;
  final int tankHitBonus;
  final int batteriesCollected;
  final int batteryBonus;
  final int totalScore;
  final bool isGuest;
  final bool backendSubmitted;
  final bool? scoreImproved;
  final int? savedBestScore;
  final int? totalPlayerScore;
  final int? playerLevel;

  int get coreScore => baseScore + flightAccuracyBonus + tankHitBonus;

  MissionResult copyWith({
    bool? isGuest,
    bool? backendSubmitted,
    bool? scoreImproved,
    int? savedBestScore,
    int? totalPlayerScore,
    int? playerLevel,
  }) {
    return MissionResult(
      missionNumber: missionNumber,
      baseScore: baseScore,
      flightAccuracyBonus: flightAccuracyBonus,
      tankHitBonus: tankHitBonus,
      batteriesCollected: batteriesCollected,
      batteryBonus: batteryBonus,
      totalScore: totalScore,
      isGuest: isGuest ?? this.isGuest,
      backendSubmitted: backendSubmitted ?? this.backendSubmitted,
      scoreImproved: scoreImproved ?? this.scoreImproved,
      savedBestScore: savedBestScore ?? this.savedBestScore,
      totalPlayerScore: totalPlayerScore ?? this.totalPlayerScore,
      playerLevel: playerLevel ?? this.playerLevel,
    );
  }
}

class ScoringSystem {
  static const baseScore = 100;
  static const maxScore = baseScore + 50 + 50;
  static const batteryPoints = 5;
  static const maxBatteryBonus = 40;
  static const maxTotalScoreWithBattery = maxScore + maxBatteryBonus;

  double _accuracyTotal = 0;
  int _accuracySamples = 0;
  final Set<int> _collectedBatteryIds = <int>{};

  void recordAccuracySample({
    required double droneCenterY,
    required double gapCenterY,
    required double gapHeight,
  }) {
    final halfGap = math.max(1, gapHeight / 2);
    final distanceFromCenter = (droneCenterY - gapCenterY).abs();
    final normalized = (1 - distanceFromCenter / halfGap).clamp(0.0, 1.0);
    _accuracyTotal += normalized;
    _accuracySamples += 1;
  }

  int get flightAccuracyBonus {
    if (_accuracySamples == 0) {
      return 25;
    }
    final average = _accuracyTotal / _accuracySamples;
    return (25 + average * 25).round().clamp(0, 50);
  }

  int get batteriesCollected => _collectedBatteryIds.length;

  int get batteryBonus =>
      math.min(maxBatteryBonus, batteriesCollected * batteryPoints);

  bool collectBattery(int batteryId) {
    if (batteryBonus >= maxBatteryBonus) {
      return false;
    }
    return _collectedBatteryIds.add(batteryId);
  }

  int calculateTankHitBonus({
    required Offset droneCenter,
    required Rect tankRect,
  }) {
    final tankCenter = tankRect.center;
    final dx = (droneCenter.dx - tankCenter.dx).abs();
    final dy = (droneCenter.dy - tankCenter.dy).abs();
    final normalizedX = 1 - dx / math.max(1, tankRect.width / 2);
    final normalizedY = 1 - dy / math.max(1, tankRect.height / 2);
    final normalized = ((normalizedX + normalizedY) / 2).clamp(0.0, 1.0);
    return (normalized * 50).round().clamp(0, 50);
  }

  MissionResult buildMissionResult({
    required int missionNumber,
    required int tankHitBonus,
    required bool isGuest,
  }) {
    final flightBonus = flightAccuracyBonus;
    final clampedTankHitBonus = tankHitBonus.clamp(0, 50);
    final clampedBatteryBonus = batteryBonus.clamp(0, maxBatteryBonus);
    return MissionResult(
      missionNumber: missionNumber,
      baseScore: baseScore,
      flightAccuracyBonus: flightBonus,
      tankHitBonus: clampedTankHitBonus,
      batteriesCollected: batteriesCollected,
      batteryBonus: clampedBatteryBonus,
      totalScore:
          baseScore + flightBonus + clampedTankHitBonus + clampedBatteryBonus,
      isGuest: isGuest,
      backendSubmitted: false,
    );
  }
}
