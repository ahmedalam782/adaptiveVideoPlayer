/// Configuration model for player playback behaviors (SRP)
class PlayerPlaybackConfig {
  /// Whether to auto-play the video
  final bool autoPlay;

  /// Whether to loop the video
  final bool loop;

  /// Whether to mute the video initially
  final bool mute;

  /// Whether to force HD quality
  final bool forceHD;

  /// Whether to enable captions
  final bool enableCaption;

  /// Whether to force desktop mode on mobile
  final bool forceDesktopMode;

  /// Whether to allow opening external links
  final bool allowExternalLinks;

  /// Optional initial playback speed (e.g. 1.0, 1.5, 2.0)
  final double? playbackSpeed;

  const PlayerPlaybackConfig({
    this.autoPlay = false,
    this.loop = false,
    this.mute = false,
    this.forceHD = false,
    this.enableCaption = false,
    this.forceDesktopMode = false,
    this.allowExternalLinks = true,
    this.playbackSpeed,
  });

  /// Convenience getter for mute state
  bool get isMuted => mute;

  /// Creates a copy with updated values
  PlayerPlaybackConfig copyWith({
    bool? autoPlay,
    bool? loop,
    bool? mute,
    bool? forceHD,
    bool? enableCaption,
    bool? forceDesktopMode,
    bool? allowExternalLinks,
    double? playbackSpeed,
  }) {
    return PlayerPlaybackConfig(
      autoPlay: autoPlay ?? this.autoPlay,
      loop: loop ?? this.loop,
      mute: mute ?? this.mute,
      forceHD: forceHD ?? this.forceHD,
      enableCaption: enableCaption ?? this.enableCaption,
      forceDesktopMode: forceDesktopMode ?? this.forceDesktopMode,
      allowExternalLinks: allowExternalLinks ?? this.allowExternalLinks,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }
}
