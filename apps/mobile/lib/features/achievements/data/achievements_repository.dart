import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AchievementsRepository {
  static const _unlockedAchievementsKey = 'achievements.unlocked';

  Future<Map<String, DateTime>> loadUnlocked() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_unlockedAchievementsKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return {};
    }

    final unlocked = <String, DateTime>{};
    for (final entry in decoded.entries) {
      final value = entry.value;
      if (entry.key is String && value is String) {
        final unlockedAt = DateTime.tryParse(value);
        if (unlockedAt != null) {
          unlocked[entry.key as String] = unlockedAt;
        }
      }
    }
    return unlocked;
  }

  Future<Map<String, DateTime>> saveUnlocked(
    Map<String, DateTime> unlocked,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      unlocked.map(
        (achievementId, unlockedAt) =>
            MapEntry(achievementId, unlockedAt.toIso8601String()),
      ),
    );
    await preferences.setString(_unlockedAchievementsKey, encoded);
    return unlocked;
  }

  Future<Map<String, DateTime>> unlockAll(
    Iterable<String> achievementIds, {
    DateTime? now,
  }) async {
    final current = await loadUnlocked();
    final unlockedAt = now ?? DateTime.now();
    var changed = false;

    for (final achievementId in achievementIds) {
      if (!current.containsKey(achievementId)) {
        current[achievementId] = unlockedAt;
        changed = true;
      }
    }

    if (!changed) {
      return current;
    }
    return saveUnlocked(current);
  }
}
