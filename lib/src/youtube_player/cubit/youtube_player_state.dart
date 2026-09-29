/// State class for YouTube player cubit
/// Named with 'Cubit' suffix to avoid conflict with Widget State classes
class PlayerCubitState {
  /// Current playback position
  final Duration position;

  /// Whether the video was playing (for restoring after fullscreen)
  final bool isPlaying;

  /// Whether the video is muted
  final bool isMuted;

  /// Whether the player is in fullscreen mode
  final bool isFullscreen;

  /// Player settings - autoPlay
  final bool autoPlay;

  /// Player settings - loop
  final bool loop;

  /// Player settings - force HD
  final bool forceHD;

  /// Player settings - enable caption
  final bool enableCaption;

  /// Video duration
  final Duration duration;

  /// Whether the player is ready
  final bool isReady;

  /// Error message if any
  final String? errorMessage;

  const PlayerCubitState({
    this.position = Duration.zero,
    this.isPlaying = false,
    this.isMuted = false,
    this.isFullscreen = false,
    this.autoPlay = false,
    this.loop = false,
    this.forceHD = true,
    this.enableCaption = true,
    this.duration = Duration.zero,
    this.isReady = false,
    this.errorMessage,
  });

  PlayerCubitState copyWith({
    Duration? position,
    bool? isPlaying,
    bool? isMuted,
    bool? isFullscreen,
    bool? autoPlay,
    bool? loop,
    bool? forceHD,
    bool? enableCaption,
    Duration? duration,
    bool? isReady,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PlayerCubitState(
      position: position ?? this.position,
      isPlaying: isPlaying ?? this.isPlaying,
      isMuted: isMuted ?? this.isMuted,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      autoPlay: autoPlay ?? this.autoPlay,
      loop: loop ?? this.loop,
      forceHD: forceHD ?? this.forceHD,
      enableCaption: enableCaption ?? this.enableCaption,
      duration: duration ?? this.duration,
      isReady: isReady ?? this.isReady,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerCubitState &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          isPlaying == other.isPlaying &&
          isMuted == other.isMuted &&
          isFullscreen == other.isFullscreen &&
          autoPlay == other.autoPlay &&
          loop == other.loop &&
          forceHD == other.forceHD &&
          enableCaption == other.enableCaption &&
          duration == other.duration &&
          isReady == other.isReady &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(
        position,
        isPlaying,
        isMuted,
        isFullscreen,
        autoPlay,
        loop,
        forceHD,
        enableCaption,
        duration,
        isReady,
        errorMessage,
      );

  @override
  String toString() =>
      'PlayerCubitState(pos: $position, dur: $duration, playing: $isPlaying, muted: $isMuted, ready: $isReady)';
}
