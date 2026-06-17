// Copyright 2026 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart'
    as platform_interface;

export 'package:video_player_platform_interface/video_player_platform_interface.dart'
    show VideoFormat, DataSourceType, DurationRange, VideoPlayerOptions;

/// Represents caption metadata.
class Caption {
  /// Constructs a [Caption] instance.
  const Caption({
    required this.number,
    required this.start,
    required this.end,
    required this.text,
  });

  /// Unique identifier for the caption.
  final int number;

  /// Start duration.
  final Duration start;

  /// End duration.
  final Duration end;

  /// The caption text.
  final String text;

  /// Empty caption.
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
  /// Constructs a video with the given values.
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

  /// Returns an instance for a video that hasn't been loaded.
  const VideoPlayerValue.uninitialized()
      : this(duration: Duration.zero, isInitialized: false);

  /// Returns an instance with the given [errorDescription].
  const VideoPlayerValue.erroneous(String errorDescription)
      : this(
          duration: Duration.zero,
          isInitialized: false,
          errorDescription: errorDescription,
        );

  /// The total duration of the video.
  final Duration duration;

  /// The current playback position.
  final Duration position;

  /// The caption overlay.
  final Caption caption;

  /// Offset for captions.
  final Duration captionOffset;

  /// The currently buffered ranges.
  final List<platform_interface.DurationRange> buffered;

  /// True if the video is playing.
  final bool isPlaying;

  /// True if the video is looping.
  final bool isLooping;

  /// True if the video is currently buffering.
  final bool isBuffering;

  /// The current volume of the playback.
  final double volume;

  /// The current speed of the playback.
  final double playbackSpeed;

  /// Degrees to rotate the video.
  final int rotationCorrection;

  /// A description of the error if present.
  final String? errorDescription;

  /// True if video has finished playing to end.
  final bool isCompleted;

  /// The size of the currently loaded video.
  final Size size;

  /// Indicates whether or not the video has been loaded and is ready to play.
  final bool isInitialized;

  /// Indicates whether or not the video is in an error state.
  bool get hasError => errorDescription != null;

  /// Returns [size.width] / [size.height].
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

  /// Returns a new instance with the given overrides.
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

/// Web-safe wrapper around [platform_interface.VideoPlayerPlatform] mimicking [VideoPlayerController].
class VideoPlayerController extends ValueNotifier<VideoPlayerValue> {
  /// The video source path.
  final String dataSource;

  /// The type of data source.
  final platform_interface.DataSourceType dataSourceType;

  /// Format override hint.
  final platform_interface.VideoFormat? formatHint;

  /// HTTP headers for networks requests.
  final Map<String, String> httpHeaders;

  /// Optional configuration options.
  final platform_interface.VideoPlayerOptions? videoPlayerOptions;

  /// The package asset is loaded from.
  final String? package;

  /// Display view mode.
  final platform_interface.VideoViewType viewType;

  int _playerId = -1;
  bool _isDisposed = false;
  StreamSubscription<dynamic>? _eventSubscription;
  Timer? _timer;

  /// The texture / player ID on the platform backend.
  int get playerId => _playerId;

  /// Construct a controller for network URLs.
  VideoPlayerController.networkUrl(
    Uri url, {
    this.formatHint,
    this.videoPlayerOptions,
    this.httpHeaders = const <String, String>{},
    this.viewType = platform_interface.VideoViewType.textureView,
  }) : dataSource = url.toString(),
       dataSourceType = platform_interface.DataSourceType.network,
       package = null,
       super(const VideoPlayerValue(duration: Duration.zero));

  /// Stub construct for assets.
  VideoPlayerController.asset(
    this.dataSource, {
    this.package,
    this.videoPlayerOptions,
    this.viewType = platform_interface.VideoViewType.textureView,
  }) : dataSourceType = platform_interface.DataSourceType.asset,
       formatHint = null,
       httpHeaders = const <String, String>{},
       super(const VideoPlayerValue(duration: Duration.zero));

  /// Web-stub for local file constructor. Throws [UnsupportedError].
  VideoPlayerController.file(
    dynamic file, {
    this.videoPlayerOptions,
    this.httpHeaders = const <String, String>{},
    this.viewType = platform_interface.VideoViewType.textureView,
  }) : dataSource = '',
       dataSourceType = platform_interface.DataSourceType.file,
       package = null,
       formatHint = null,
       super(const VideoPlayerValue(duration: Duration.zero)) {
    throw UnsupportedError('Local file playback is not supported on Web');
  }

  /// Initializes the video player on the platform backend.
  Future<void> initialize() async {
    final platform_interface.DataSource dataSourceDescription;
    switch (dataSourceType) {
      case platform_interface.DataSourceType.asset:
        dataSourceDescription = platform_interface.DataSource(
          sourceType: platform_interface.DataSourceType.asset,
          asset: dataSource,
          package: package,
        );
        break;
      case platform_interface.DataSourceType.network:
        dataSourceDescription = platform_interface.DataSource(
          sourceType: platform_interface.DataSourceType.network,
          uri: dataSource,
          formatHint: formatHint,
          httpHeaders: httpHeaders,
        );
        break;
      case platform_interface.DataSourceType.file:
        dataSourceDescription = platform_interface.DataSource(
          sourceType: platform_interface.DataSourceType.file,
          uri: dataSource,
          httpHeaders: httpHeaders,
        );
        break;
      default:
        throw UnimplementedError('Unsupported data source type');
    }

    final creationOptions = platform_interface.VideoCreationOptions(
      dataSource: dataSourceDescription,
      viewType: viewType,
    );

    _playerId = (await platform_interface.VideoPlayerPlatform.instance
            .createWithOptions(creationOptions)) ??
        -1;

    final initializingCompleter = Completer<void>();

    if (videoPlayerOptions?.webOptions != null) {
      await platform_interface.VideoPlayerPlatform.instance.setWebOptions(
        _playerId,
        videoPlayerOptions!.webOptions!,
      );
    }

    void eventListener(platform_interface.VideoEvent event) {
      if (_isDisposed) return;

      switch (event.eventType) {
        case platform_interface.VideoEventType.initialized:
          value = value.copyWith(
            duration: event.duration,
            size: event.size,
            rotationCorrection: event.rotationCorrection,
            isInitialized: event.duration != null,
            errorDescription: null,
            isCompleted: false,
          );
          if (!initializingCompleter.isCompleted) {
            initializingCompleter.complete();
          }
          _applyLooping();
          _applyVolume();
          _applyPlayPause();
          break;
        case platform_interface.VideoEventType.completed:
          pause().then((_) => seekTo(value.duration));
          value = value.copyWith(isCompleted: true);
          break;
        case platform_interface.VideoEventType.bufferingUpdate:
          value = value.copyWith(buffered: event.buffered);
          break;
        case platform_interface.VideoEventType.bufferingStart:
          value = value.copyWith(isBuffering: true);
          break;
        case platform_interface.VideoEventType.bufferingEnd:
          value = value.copyWith(isBuffering: false);
          break;
        case platform_interface.VideoEventType.isPlayingStateUpdate:
          if (event.isPlaying ?? false) {
            value = value.copyWith(
              isPlaying: event.isPlaying,
              isCompleted: false,
            );
          } else {
            value = value.copyWith(isPlaying: event.isPlaying);
          }
          break;
        case platform_interface.VideoEventType.unknown:
          break;
      }
    }

    void errorListener(Object obj) {
      final message = obj is PlatformException ? obj.message : obj.toString();
      value = VideoPlayerValue.erroneous(message ?? 'Unknown error');
      _timer?.cancel();
      if (!initializingCompleter.isCompleted) {
        initializingCompleter.completeError(obj);
      }
    }

    _eventSubscription = platform_interface.VideoPlayerPlatform.instance
        .videoEventsFor(_playerId)
        .listen(eventListener, onError: errorListener);

    return initializingCompleter.future;
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _timer?.cancel();
    await _eventSubscription?.cancel();
    if (_playerId != -1) {
      await platform_interface.VideoPlayerPlatform.instance.dispose(_playerId);
    }
    super.dispose();
  }

  /// Plays the video.
  Future<void> play() async {
    if (value.position == value.duration) {
      await seekTo(Duration.zero);
    }
    value = value.copyWith(isPlaying: true);
    await _applyPlayPause();
  }

  /// Pauses the video.
  Future<void> pause() async {
    value = value.copyWith(isPlaying: false);
    await _applyPlayPause();
  }

  /// Seeks to a position in the video.
  Future<void> seekTo(Duration position) async {
    if (_playerId == -1) return;
    await platform_interface.VideoPlayerPlatform.instance
        .seekTo(_playerId, position);
    _updatePosition(position);
  }

  /// Sets video playback volume.
  Future<void> setVolume(double volume) async {
    value = value.copyWith(volume: volume);
    await _applyVolume();
  }

  /// Enables or disables loop playback.
  Future<void> setLooping(bool looping) async {
    value = value.copyWith(isLooping: looping);
    await _applyLooping();
  }

  /// Changes the playback speed.
  Future<void> setPlaybackSpeed(double speed) async {
    value = value.copyWith(playbackSpeed: speed);
    if (value.isPlaying) {
      await platform_interface.VideoPlayerPlatform.instance
          .setPlaybackSpeed(_playerId, speed);
    }
  }

  Future<void> _applyLooping() async {
    if (_playerId == -1) return;
    await platform_interface.VideoPlayerPlatform.instance
        .setLooping(_playerId, value.isLooping);
  }

  Future<void> _applyVolume() async {
    if (_playerId == -1) return;
    await platform_interface.VideoPlayerPlatform.instance
        .setVolume(_playerId, value.volume);
  }

  Future<void> _applyPlayPause() async {
    if (_playerId == -1) return;
    if (value.isPlaying) {
      await platform_interface.VideoPlayerPlatform.instance.play(_playerId);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        if (_isDisposed) return;
        final pos = await platform_interface.VideoPlayerPlatform.instance
            .getPosition(_playerId);
        _updatePosition(pos);
      });
      await platform_interface.VideoPlayerPlatform.instance
          .setPlaybackSpeed(_playerId, value.playbackSpeed);
    } else {
      _timer?.cancel();
      await platform_interface.VideoPlayerPlatform.instance.pause(_playerId);
    }
  }

  void _updatePosition(Duration position) {
    if (_isDisposed) return;
    value = value.copyWith(position: position);
  }
}

/// A web-safe widget to render the video player.
class VideoPlayer extends StatefulWidget {
  /// Creates a [VideoPlayer] widget.
  const VideoPlayer(this.controller, {super.key});

  /// The controller driving this player widget.
  final VideoPlayerController controller;

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late int _playerId;

  void _controllerDidUpdateValue() {
    final int newPlayerId = widget.controller.playerId;
    if (newPlayerId != _playerId) {
      setState(() {
        _playerId = newPlayerId;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _playerId = widget.controller.playerId;
    widget.controller.addListener(_controllerDidUpdateValue);
  }

  @override
  void didUpdateWidget(VideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller.removeListener(_controllerDidUpdateValue);
    _playerId = widget.controller.playerId;
    widget.controller.addListener(_controllerDidUpdateValue);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerDidUpdateValue);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_playerId == -1) return Container();
    final rotation = widget.controller.value.rotationCorrection;
    final view = platform_interface.VideoPlayerPlatform.instance
        .buildViewWithOptions(
      platform_interface.VideoViewOptions(playerId: _playerId),
    );
    if (rotation == 0) return view;
    return RotatedBox(
      quarterTurns: (rotation / 90).round(),
      child: view,
    );
  }
}
