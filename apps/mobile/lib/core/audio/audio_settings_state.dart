class AudioSettingsState {
  const AudioSettingsState({
    this.masterSoundEnabled = true,
    this.musicEnabled = true,
    this.sfxEnabled = true,
  });

  final bool masterSoundEnabled;
  final bool musicEnabled;
  final bool sfxEnabled;

  AudioSettingsState copyWith({
    bool? masterSoundEnabled,
    bool? musicEnabled,
    bool? sfxEnabled,
  }) {
    return AudioSettingsState(
      masterSoundEnabled: masterSoundEnabled ?? this.masterSoundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
    );
  }
}
