class MissionRules {
  const MissionRules._();

  static const maxMissionNumber = 20;
  static const trainingMissionLimit = 2;
  static const maxGuestMission = 2;

  static bool isFreeMission(int missionNumber) {
    return missionNumber >= 1 && missionNumber <= trainingMissionLimit;
  }

  static bool usesLives(int missionNumber) => !isFreeMission(missionNumber);

  static bool isGuestMissionAvailable({
    required int missionNumber,
    required int unlockedMission,
  }) {
    return missionNumber >= 1 &&
        missionNumber <= maxGuestMission &&
        missionNumber <= unlockedMission;
  }
}
