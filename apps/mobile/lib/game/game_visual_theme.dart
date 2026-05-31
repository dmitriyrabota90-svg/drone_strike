import 'dart:math' as math;

enum GameVisualTheme { night, day }

extension GameVisualThemeX on GameVisualTheme {
  bool get isDay => this == GameVisualTheme.day;

  static GameVisualTheme randomForMission(int missionNumber) {
    final seed = DateTime.now().microsecondsSinceEpoch ^ (missionNumber * 7919);
    return math.Random(seed).nextBool()
        ? GameVisualTheme.day
        : GameVisualTheme.night;
  }
}
