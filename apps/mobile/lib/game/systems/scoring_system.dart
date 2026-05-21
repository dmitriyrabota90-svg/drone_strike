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
    this.scoreImproved,
    this.savedBestScore,
    this.totalPlayerScore,
    this.playerLevel,
  });

  final int missionNumber;
  final int baseScore;
  final int flightAccuracyBonus;
  final int tankHitBonus;
  final int totalScore;
  final bool isGuest;
  final bool backendSubmitted;
  final bool? scoreImproved;
  final int? savedBestScore;
  final int? totalPlayerScore;
  final int? playerLevel;

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

  double _accuracyTotal = 0;
  int _accuracySamples = 0;

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
    return MissionResult(
      missionNumber: missionNumber,
      baseScore: baseScore,
      flightAccuracyBonus: flightBonus,
      tankHitBonus: tankHitBonus.clamp(0, 50),
      totalScore: baseScore + flightBonus + tankHitBonus.clamp(0, 50),
      isGuest: isGuest,
      backendSubmitted: false,
    );
  }
}
