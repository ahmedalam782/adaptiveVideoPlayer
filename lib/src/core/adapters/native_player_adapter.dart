import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../normal_video_player/models/video_config.dart';
import '../../normal_video_player/utils/video_player_web_safe.dart';
import '../contracts/i_video_player_controller.dart';
import '../models/player_state.dart';

/// Adapter that wraps standard [VideoPlayerController] to conform to [IVideoPlayerController] (Adapter Pattern).
class NativePlayerAdapter implements IVideoPlayerController {
  final VideoPlayerController _controller;
  final ValueNotifier<PlayerState> _stateNotifier;
  final List<VideoQuality>? _qualities;
  VideoQuality? _currentQuality;
  final List<SubtitleTrack>? _subtitles;
  SubtitleTrack? _currentSubtitle;
  final bool _isLive;
  double _lastVolume = 1.0;
  bool _isDisposed = false;

  NativePlayerAdapter({
    required VideoPlayerController controller,
    List<VideoQuality>? qualities,
    VideoQuality? initialQuality,
    List<SubtitleTrack>? subtitles,
    SubtitleTrack? initialSubtitle,
    bool isLive = false,
  })  : _controller = controller,
        _qualities = qualities,
        _currentQuality = initialQuality ??
            (qualities != null && qualities.isNotEmpty ? qualities.first : null),
        _subtitles = subtitles,
        _currentSubtitle = initialSubtitle,
        _isLive = isLive,
        _stateNotifier = ValueNotifier<PlayerState>(
          PlayerState(
            isLive: isLive,
            currentQuality: initialQuality ??
                (qualities != null && qualities.isNotEmpty
                    ? qualities.first
                    : null),
            currentSubtitle: initialSubtitle,
          ),
        ) {
    _controller.addListener(_onControllerUpdate);
    _syncState();
  }

  /// Underlying video player controller instance
  VideoPlayerController get rawController => _controller;

  @override
  ValueListenable<PlayerState> get stateNotifier => _stateNotifier;

  @override
  PlayerState get state => _stateNotifier.value;

  @override
  List<VideoQuality>? get qualities => _qualities;

  @override
  VideoQuality? get currentQuality => _currentQuality;

  @override
  List<SubtitleTrack>? get subtitles => _subtitles;

  @override
  SubtitleTrack? get currentSubtitle => _currentSubtitle;

  void _onControllerUpdate() {
    if (_isDisposed) return;
    _syncState();
  }

  void _syncState() {
    final value = _controller.value;
    Duration bufferedEnd = Duration.zero;
    if (value.buffered.isNotEmpty) {
      bufferedEnd = value.buffered.last.end;
    }

    final isCompleted = value.isInitialized &&
        value.duration > Duration.zero &&
        value.position >= value.duration;

    _stateNotifier.value = _stateNotifier.value.copyWith(
      position: value.position,
      duration: value.duration,
      buffered: bufferedEnd,
      isPlaying: value.isPlaying,
      isBuffering: value.isBuffering,
      isCompleted: isCompleted,
      isReady: value.isInitialized,
      hasError: value.hasError,
      errorMessage: value.errorDescription,
      volume: value.volume,
      isMuted: value.volume == 0.0,
      playbackSpeed: value.playbackSpeed,
      isLive: _isLive || (_currentQuality?.isLive ?? false),
      currentQuality: _currentQuality,
      currentSubtitle: _currentSubtitle,
    );
  }

  @override
  Future<void> initialize() async {
    if (!_controller.value.isInitialized) {
      await _controller.initialize();
    }
    _syncState();
  }

  @override
  Future<void> play() async {
    await _controller.play();
  }

  @override
  Future<void> pause() async {
    await _controller.pause();
  }

  @override
  Future<void> seekTo(Duration position) async {
    await _controller.seekTo(position);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    await _controller.setPlaybackSpeed(speed);
  }

  @override
  Future<void> setVolume(double volume) async {
    final clamped = volume.clamp(0.0, 1.0);
    if (clamped > 0) {
      _lastVolume = clamped;
    }
    await _controller.setVolume(clamped);
  }

  @override
  Future<void> toggleMute() async {
    if (_controller.value.volume > 0.0) {
      _lastVolume = _controller.value.volume;
      await _controller.setVolume(0.0);
    } else {
      await _controller.setVolume(_lastVolume > 0 ? _lastVolume : 1.0);
    }
  }

  @override
  Future<void> setMute(bool mute) async {
    if (mute) {
      if (_controller.value.volume > 0.0) {
        _lastVolume = _controller.value.volume;
      }
      await _controller.setVolume(0.0);
    } else {
      await _controller.setVolume(_lastVolume > 0 ? _lastVolume : 1.0);
    }
  }

  @override
  Future<void> changeQuality(VideoQuality quality) async {
    _currentQuality = quality;
    _stateNotifier.value = _stateNotifier.value.copyWith(currentQuality: quality);
  }

  @override
  Future<void> changeSubtitle(SubtitleTrack? track) async {
    _currentSubtitle = track;
    _stateNotifier.value = _stateNotifier.value.copyWith(currentSubtitle: track);
  }

  @override
  Widget buildVideoView(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio > 0
          ? _controller.value.aspectRatio
          : 16 / 9,
      child: VideoPlayer(_controller),
    );
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    _controller.removeListener(_onControllerUpdate);
    _stateNotifier.dispose();
  }
}
