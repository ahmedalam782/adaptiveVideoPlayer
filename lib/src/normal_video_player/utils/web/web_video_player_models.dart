import 'package:flutter/material.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart'
    as platform_interface;

export 'package:video_player_platform_interface/video_player_platform_interface.dart'
    show VideoFormat, DataSourceType, DurationRange, VideoPlayerOptions;

/// Represents caption metadata on Web.
class Caption {
  const Caption({
    required this.number,
    required this.start,
    required this.end,
    required this.text,
  });

  final int number;
  final Duration start;
  final Duration end;
  final String text;

  static const Caption none = Caption(
    number: -1,
    start: Duration.zero,
    end: Duration.zero,
    text: '',
  );
}

/// The duration, current position, buffering state, error state and settings
/// of a [VideoPlayerController] on Web.
@immutable
class VideoPlayerValue {
  const VideoPlayerValue({
    required this.duration,
    this.size = Size.zero,
    this.position = Duration.zero,
    this.caption = Caption.none,
    this.captionOffset = Duration.zero,
    this.buffered = const <platform_interface.DurationRange>[],
    this.isInitialized = false,
    this.isPlaying = false,
    this.isLooping = false,
    this.isBuffering = false,
    this.volume = 1.0,
    this.playbackSpeed = 1.0,
    this.rotationCorrection = 0,
    this.errorDescription,
    this.isCompleted = false,
  });

  const VideoPlayerValue.uninitialized()
      : this(duration: Duration.zero, isInitialized: false);

  const VideoPlayerValue.erroneous(String errorDescription)
      : this(
          duration: Duration.zero,
          isInitialized: false,
          errorDescription: errorDescription,
        );

  final Duration duration;
  final Size size;
  final Duration position;
  final Caption caption;
  final Duration captionOffset;
  final List<platform_interface.DurationRange> buffered;
  final bool isInitialized;
  final bool isPlaying;
  final bool isLooping;
  final bool isBuffering;
  final double volume;
  final double playbackSpeed;
  final int rotationCorrection;
  final String? errorDescription;
  final bool isCompleted;

  bool get hasError => errorDescription != null;

  double get aspectRatio {
    if (!isInitialized || size.width == 0 || size.height == 0) {
      return 1.0;
    }
    final double aspectRatio = size.width / size.height;
    if (aspectRatio <= 0) {
      return 1.0;
    }
    return aspectRatio;
  }

  VideoPlayerValue copyWith({
    Duration? duration,
    Size? size,
    Duration? position,
    Caption? caption,
    Duration? captionOffset,
    List<platform_interface.DurationRange>? buffered,
    bool? isInitialized,
    bool? isPlaying,
    bool? isLooping,
    bool? isBuffering,
    double? volume,
    double? playbackSpeed,
    int? rotationCorrection,
    String? errorDescription,
    bool? isCompleted,
  }) {
    return VideoPlayerValue(
      duration: duration ?? this.duration,
      size: size ?? this.size,
      position: position ?? this.position,
      caption: caption ?? this.caption,
      captionOffset: captionOffset ?? this.captionOffset,
      buffered: buffered ?? this.buffered,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      isLooping: isLooping ?? this.isLooping,
      isBuffering: isBuffering ?? this.isBuffering,
      volume: volume ?? this.volume,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      rotationCorrection: rotationCorrection ?? this.rotationCorrection,
      errorDescription: errorDescription ?? this.errorDescription,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() {
    return 'VideoPlayerValue(duration: $duration, size: $size, position: $position, isInitialized: $isInitialized, isPlaying: $isPlaying, isLooping: $isLooping, isBuffering: $isBuffering, volume: $volume, playbackSpeed: $playbackSpeed, errorDescription: $errorDescription, isCompleted: $isCompleted)';
  }
}
