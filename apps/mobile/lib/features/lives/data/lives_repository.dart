import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/local_storage.dart';
import '../domain/lives_state.dart';

class LivesRepository {
  static const _currentLivesKey = 'lives.current_lives';
  static const _nextLifeAtKey = 'lives.next_life_at';

  Future<LivesState> load({DateTime? now}) async {
    final storage = await _storage();
    final currentNow = now ?? DateTime.now();
    final isPremium = false; // TODO: wire premium status when shop exists.
    final maxLives = LivesState.normalMaxLives;
    final storedLives = storage.getInt(_currentLivesKey) ?? maxLives;
    final nextLifeAtRaw = storage.getString(_nextLifeAtKey);
    final nextLifeAt = nextLifeAtRaw == null
        ? null
        : DateTime.tryParse(nextLifeAtRaw);

    final recovered = _recover(
      currentLives: storedLives.clamp(0, maxLives).toInt(),
      maxLives: maxLives,
      nextLifeAt: nextLifeAt,
      isPremium: isPremium,
      now: currentNow,
    );
    await save(recovered);
    return recovered;
  }

  Future<LivesState> spendLife({DateTime? now}) async {
    final current = await load(now: now);
    if (!current.hasLives) {
      return current;
    }

    final nextLives = current.currentLives - 1;
    final nextLifeAt = nextLives < current.maxLives
        ? current.nextLifeAt ??
              (now ?? DateTime.now()).add(current.recoveryDuration)
        : null;
    final next = _withTimer(
      current.copyWith(
        currentLives: nextLives,
        nextLifeAt: nextLifeAt,
        clearNextLifeAt: nextLifeAt == null,
      ),
      now ?? DateTime.now(),
    );
    await save(next);
    return next;
  }

  Future<LivesState> recoverLivesIfNeeded({DateTime? now}) => load(now: now);

  Future<DateTime?> getNextLifeAt() async {
    final state = await load();
    return state.nextLifeAt;
  }

  Future<void> save(LivesState state) async {
    final storage = await _storage();
    await storage.setInt(_currentLivesKey, state.currentLives);
    if (state.nextLifeAt == null) {
      await storage.remove(_nextLifeAtKey);
    } else {
      await storage.setString(
        _nextLifeAtKey,
        state.nextLifeAt!.toIso8601String(),
      );
    }
  }

  LivesState _recover({
    required int currentLives,
    required int maxLives,
    required DateTime? nextLifeAt,
    required bool isPremium,
    required DateTime now,
  }) {
    var lives = currentLives;
    var nextAt = nextLifeAt;
    final recoveryDuration = isPremium
        ? LivesState.premiumRecovery
        : LivesState.normalRecovery;

    while (lives < maxLives && nextAt != null && !nextAt.isAfter(now)) {
      lives += 1;
      nextAt = lives < maxLives ? nextAt.add(recoveryDuration) : null;
    }

    if (lives >= maxLives) {
      nextAt = null;
    } else {
      nextAt ??= now.add(recoveryDuration);
    }

    return _withTimer(
      LivesState(
        currentLives: lives,
        maxLives: maxLives,
        nextLifeAt: nextAt,
        recoverySecondsRemaining: 0,
        isPremium: isPremium,
      ),
      now,
    );
  }

  LivesState _withTimer(LivesState state, DateTime now) {
    final nextLifeAt = state.nextLifeAt;
    final remaining = nextLifeAt == null
        ? 0
        : nextLifeAt.difference(now).inSeconds.clamp(0, 999999).toInt();
    return state.copyWith(recoverySecondsRemaining: remaining);
  }

  Future<LocalStorage> _storage() async {
    final preferences = await SharedPreferences.getInstance();
    return LocalStorage(preferences);
  }
}
