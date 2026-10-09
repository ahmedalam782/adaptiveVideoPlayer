/// Model representing an audio track (e.g. English Original, Arabic, Audio Description).
class AudioTrack {
  /// Unique identifier of the audio track
  final String id;

  /// Display label (e.g., 'الإنجليزية [أصلي]', 'العربية', 'English (Original)')
  final String label;

  /// Language code (e.g., 'en', 'ar', 'de')
  final String? language;

  /// Whether this track is the original audio of the media
  final bool isOriginal;

  /// Whether this track is an Audio Description (الوصف الصوتي) for visually impaired
  final bool isAudioDescription;

  /// Whether this is the default audio track
  final bool isDefault;

  /// Additional metadata or stream identifier
  final Map<String, dynamic>? extra;

  const AudioTrack({
    required this.id,
    required this.label,
    this.language,
    this.isOriginal = false,
    this.isAudioDescription = false,
    this.isDefault = false,
    this.extra,
  });

  AudioTrack copyWith({
    String? id,
    String? label,
    String? language,
    bool? isOriginal,
    bool? isAudioDescription,
    bool? isDefault,
    Map<String, dynamic>? extra,
  }) {
    return AudioTrack(
      id: id ?? this.id,
      label: label ?? this.label,
      language: language ?? this.language,
      isOriginal: isOriginal ?? this.isOriginal,
      isAudioDescription: isAudioDescription ?? this.isAudioDescription,
      isDefault: isDefault ?? this.isDefault,
      extra: extra ?? this.extra,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioTrack &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
