// Copyright 2026 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart'
    as platform_interface;
import 'hls_web_helper.dart';
import 'web/web_video_player_models.dart';

export 'package:video_player_platform_interface/video_player_platform_interface.dart'
    show VideoFormat, DataSourceType, DurationRange, VideoPlayerOptions;
export 'web/web_video_player_models.dart';
export 'web/web_video_player_view.dart';

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
  })  : dataSource = url.toString(),
        dataSourceType = platform_interface.DataSourceType.network,
        package = null,
        super(const VideoPlayerValue(duration: Duration.zero));

  /// Stub construct for assets.
  VideoPlayerController.asset(
    this.dataSource, {
    this.package,
    this.videoPlayerOptions,
    this.viewType = platform_interface.VideoViewType.textureView,
  })  : dataSourceType = platform_interface.DataSourceType.asset,
        formatHint = null,
        httpHeaders = const <String, String>{},
        super(const VideoPlayerValue(duration: Duration.zero));

  /// Web-stub for local file constructor. Throws [UnsupportedError].
  VideoPlayerController.file(
    dynamic file, {
    this.videoPlayerOptions,
    this.httpHeaders = const <String, String>{},
    this.viewType = platform_interface.VideoViewType.textureView,
  })  : dataSource = '',
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

    setupHlsForWeb(dataSource, _playerId);

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
