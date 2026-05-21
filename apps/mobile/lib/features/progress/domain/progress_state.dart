import '../data/progress_dto.dart';

class ProgressState {
  const ProgressState({
    this.isLoading = false,
    this.progress,
    this.errorMessage,
    this.lastMissionResult,
  });

  const ProgressState.guest()
    : isLoading = false,
      progress = const ProgressResponseDto.guest(),
      errorMessage = null,
      lastMissionResult = null;

  final bool isLoading;
  final ProgressResponseDto? progress;
  final String? errorMessage;
  final MissionCompleteResponseDto? lastMissionResult;

  bool get hasCompletedAnyMission => completedMissionsCount > 0;
  int get completedMissionsCount => progress?.completedMissionsCount ?? 0;
  int get unlockedMission => progress?.unlockedMission ?? 1;
  int get totalScore => progress?.totalScore ?? 0;
  int get playerLevel => progress?.playerLevel ?? 1;

  ProgressState copyWith({
    bool? isLoading,
    ProgressResponseDto? progress,
    String? errorMessage,
    MissionCompleteResponseDto? lastMissionResult,
    bool clearError = false,
    bool clearLastMissionResult = false,
  }) {
    return ProgressState(
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      lastMissionResult: clearLastMissionResult
          ? null
          : lastMissionResult ?? this.lastMissionResult,
    );
  }
}
