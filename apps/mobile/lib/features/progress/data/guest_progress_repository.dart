import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/local_storage.dart';
import 'progress_dto.dart';

class GuestProgressRepository {
  static const _completedMissionsKey = 'guest_progress.completed_missions';
  static const _bestScorePrefix = 'guest_progress.best_score_';
  static const _bestFlightPrefix = 'guest_progress.best_flight_';
  static const _bestTankPrefix = 'guest_progress.best_tank_';

  Future<ProgressResponseDto> loadProgress() async {
    final storage = await _storage();
    final completed = _decodeCompleted(
      storage.getString(_completedMissionsKey),
    );
    final missions = <MissionProgressItemDto>[];
    var totalScore = 0;

    for (final missionNumber in completed.toList()..sort()) {
      final bestScore = storage.getInt('$_bestScorePrefix$missionNumber') ?? 0;
      totalScore += bestScore;
      missions.add(
        MissionProgressItemDto(
          missionNumber: missionNumber,
          bestScore: bestScore,
          bestFlightAccuracyBonus:
              storage.getInt('$_bestFlightPrefix$missionNumber') ?? 0,
          bestTankHitBonus:
              storage.getInt('$_bestTankPrefix$missionNumber') ?? 0,
          completedAt: null,
        ),
      );
    }

    return ProgressResponseDto(
      totalScore: totalScore,
      playerLevel: 1,
      completedMissionsCount: completed.length,
      unlockedMission: 2,
      missions: missions,
    );
  }

  Future<ProgressResponseDto> saveMissionResult({
    required int missionNumber,
    required int bestScore,
    required int flightAccuracyBonus,
    required int tankHitBonus,
  }) async {
    if (missionNumber < 1 || missionNumber > 2) {
      return loadProgress();
    }

    final storage = await _storage();
    final completed = _decodeCompleted(
      storage.getString(_completedMissionsKey),
    );
    final currentBest = storage.getInt('$_bestScorePrefix$missionNumber') ?? 0;
    completed.add(missionNumber);
    await storage.setString(_completedMissionsKey, _encodeCompleted(completed));
    if (bestScore > currentBest) {
      await storage.setInt('$_bestScorePrefix$missionNumber', bestScore);
      await storage.setInt(
        '$_bestFlightPrefix$missionNumber',
        flightAccuracyBonus,
      );
      await storage.setInt('$_bestTankPrefix$missionNumber', tankHitBonus);
    }

    // TODO: merge guest progress with server progress after registration.
    return loadProgress();
  }

  Set<int> _decodeCompleted(String? value) {
    if (value == null || value.isEmpty) {
      return <int>{};
    }
    return value
        .split(',')
        .map(int.tryParse)
        .whereType<int>()
        .where((mission) => mission >= 1 && mission <= 2)
        .toSet();
  }

  String _encodeCompleted(Set<int> completed) {
    final sorted = completed.toList()..sort();
    return sorted.join(',');
  }

  Future<LocalStorage> _storage() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalStorage(preferences);
  }
}
