import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/providers.dart';
import '../../auth/domain/auth_controller.dart';
import '../data/progress_dto.dart';
import 'progress_state.dart';

final progressControllerProvider =
    AsyncNotifierProvider<ProgressController, ProgressState>(
      ProgressController.new,
    );

class ProgressController extends AsyncNotifier<ProgressState> {
  @override
  Future<ProgressState> build() async {
    final authState = ref.watch(authControllerProvider).asData?.value;
    if (authState?.isAuthenticated != true) {
      return _loadGuest();
    }
    return _load();
  }

  Future<void> loadProgress() async {
    final authState = ref.read(authControllerProvider).asData?.value;
    if (authState?.isAuthenticated != true) {
      state = AsyncData(await _loadGuest());
      return;
    }

    state = AsyncData(_current.copyWith(isLoading: true, clearError: true));
    state = AsyncData(await _load());
  }

  Future<void> refreshProgress() => loadProgress();

  Future<MissionCompleteResponseDto?> completeMission({
    required int missionNumber,
    required int flightAccuracyBonus,
    required int tankHitBonus,
  }) async {
    final authState = ref.read(authControllerProvider).asData?.value;
    if (authState?.isAuthenticated != true) {
      state = AsyncData(await _loadGuest());
      return null;
    }

    state = AsyncData(_current.copyWith(isLoading: true, clearError: true));
    try {
      final result = await ref
          .read(progressRepositoryProvider)
          .completeMission(
            missionNumber: missionNumber,
            flightAccuracyBonus: flightAccuracyBonus,
            tankHitBonus: tankHitBonus,
          );
      final progress = await ref.read(progressRepositoryProvider).getProgress();
      state = AsyncData(
        ProgressState(progress: progress, lastMissionResult: result),
      );
      await ref.read(authControllerProvider.notifier).reloadMe();
      return result;
    } on Object catch (error) {
      state = AsyncData(
        _current.copyWith(isLoading: false, errorMessage: _errorMessage(error)),
      );
      return null;
    }
  }

  Future<void> saveGuestMissionResult({
    required int missionNumber,
    required int bestScore,
    required int flightAccuracyBonus,
    required int tankHitBonus,
  }) async {
    final progress = await ref
        .read(guestProgressRepositoryProvider)
        .saveMissionResult(
          missionNumber: missionNumber,
          bestScore: bestScore,
          flightAccuracyBonus: flightAccuracyBonus,
          tankHitBonus: tankHitBonus,
        );
    state = AsyncData(ProgressState(progress: progress));
  }

  void clear() {
    state = const AsyncData(ProgressState.guest());
  }

  ProgressState get _current =>
      state.asData?.value ?? const ProgressState.guest();

  Future<ProgressState> _load() async {
    try {
      final progress = await ref.read(progressRepositoryProvider).getProgress();
      return ProgressState(progress: progress);
    } on Object catch (error) {
      return _current.copyWith(
        isLoading: false,
        errorMessage: _errorMessage(error),
      );
    }
  }

  Future<ProgressState> _loadGuest() async {
    try {
      final progress = await ref
          .read(guestProgressRepositoryProvider)
          .loadProgress();
      return ProgressState(progress: progress);
    } on Object catch (error) {
      return const ProgressState.guest().copyWith(
        errorMessage: _errorMessage(error),
      );
    }
  }

  String _errorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Unexpected error.';
  }
}
