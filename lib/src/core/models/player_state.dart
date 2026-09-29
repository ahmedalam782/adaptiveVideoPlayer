import 'package:flutter/foundation.dart';
import '../../normal_video_player/models/video_config.dart';

/// Immutable snapshot of the video player state across all player implementations.
@immutable
class PlayerState {
  final Duration position;
  final Duration duration;
  final Duration buffered;
  final bool isPlaying;
  final bool isBuffering;
  final bool isCompleted;
  final bool isReady;
  final bool hasError;
  final String? errorMessage;
  final double volume;
  final bool isMuted;
  final double playbackSpeed;
  final bool isLive;
  final VideoQuality? currentQuality;
  final SubtitleTrack? currentSubtitle;

  const PlayerState({
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.buffered = Duration.zero,
    this.isPlaying = false,
    this.isBuffering = false,
    this.isCompleted = false,
    this.isReady = false,
    this.hasError = false,
    this.errorMessage,
    this.volume = 1.0,
    this.isMuted = false,
    this.playbackSpeed = 1.0,
    this.isLive = false,
    this.currentQuality,
    this.currentSubtitle,
  });

  /// Initial idle state
  factory PlayerState.initial({bool isLive = false}) => PlayerState(
        isLive: isLive,
      );

  PlayerState copyWith({
    Duration? position,
    Duration? duration,
    Duration? buffered,
    bool? isPlaying,
    bool? isBuffering,
    bool? isCompleted,
    bool? isReady,
    bool? hasError,
    String? errorMessage,
    double? volume,
    bool? isMuted,
    double? playbackSpeed,
    bool? isLive,
    VideoQuality? currentQuality,
    SubtitleTrack? currentSubtitle,
  }) {
    return PlayerState(
      position: position ?? this.position,
      duration: duration ?? this.duration,
      buffered: buffered ?? this.buffered,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      isCompleted: isCompleted ?? this.isCompleted,
      isReady: isReady ?? this.isReady,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isLive: isLive ?? this.isLive,
      currentQuality: currentQuality ?? this.currentQuality,
      currentSubtitle: currentSubtitle ?? this.currentSubtitle,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerState &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          duration == other.duration &&
          buffered == other.buffered &&
          isPlaying == other.isPlaying &&
          isBuffering == other.isBuffering &&
          isCompleted == other.isCompleted &&
          isReady == other.isReady &&
          hasError == other.hasError &&
          errorMessage == other.errorMessage &&
          volume == other.volume &&
          isMuted == other.isMuted &&
          playbackSpeed == other.playbackSpeed &&
          isLive == other.isLive &&
          currentQuality == other.currentQuality &&
          currentSubtitle == other.currentSubtitle;

  @override
  int get hashCode => Object.hash(
        position,
        duration,
        buffered,
        isPlaying,
        isBuffering,
        isCompleted,
        isReady,
        hasError,
        errorMessage,
        volume,
        isMuted,
        playbackSpeed,
        isLive,
        currentQuality,
        currentSubtitle,
      );
}
