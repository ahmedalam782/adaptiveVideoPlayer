import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../normal_video_player/models/video_config.dart';
import '../../youtube_player/cubit/youtube_player_cubit.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../../youtube_player/youtube_video_player.dart';
import '../contracts/i_video_player_controller.dart';
import '../models/player_state.dart';

/// Adapter that wraps YouTube player / cubit to conform to [IVideoPlayerController] (Adapter Pattern).
class YouTubePlayerAdapter implements IVideoPlayerController {
  final String videoId;
  final YouTubePlayerConfig config;
  final bool isLiveStream;
  final String? viewerCount;
  final YoutubePlayerNotifier _notifier;
  final ValueNotifier<PlayerState> _stateNotifier;
  final GlobalKey<YouTubeVideoPlayerState> _playerKey = GlobalKey<YouTubeVideoPlayerState>();
  bool _isDisposed = false;

  YouTubePlayerAdapter({
    required this.videoId,
    this.config = const YouTubePlayerConfig(),
    this.isLiveStream = false,
    this.viewerCount,
    YoutubePlayerNotifier? notifier,
  })  : _notifier = notifier ?? YoutubePlayerNotifier(),
        _stateNotifier = ValueNotifier<PlayerState>(
          PlayerState(isLive: isLiveStream),
        ) {
    _notifier.addListener(_onNotifierUpdate);
    _syncState();
  }

  @override
  ValueListenable<PlayerState> get stateNotifier => _stateNotifier;

  @override
  PlayerState get state => _stateNotifier.value;

  @override
  List<VideoQuality>? get qualities => null; // Managed inside YouTube player internally

  @override
  VideoQuality? get currentQuality => null;

  @override
  List<SubtitleTrack>? get subtitles => null;

  @override
  SubtitleTrack? get currentSubtitle => null;

  void _onNotifierUpdate() {
    if (_isDisposed) return;
    _syncState();
  }

  void _syncState() {
    final s = _notifier.state;
    _stateNotifier.value = _stateNotifier.value.copyWith(
      position: s.position,
      duration: s.duration,
      isPlaying: s.isPlaying,
      isReady: s.isReady,
      isMuted: s.isMuted,
      volume: s.isMuted ? 0.0 : 1.0,
      hasError: s.errorMessage != null,
      errorMessage: s.errorMessage,
      isLive: isLiveStream,
    );
  }

  @override
  Future<void> initialize() async {
    _syncState();
  }

  @override
  Future<void> play() async {
    _notifier.setPlaying(true);
  }

  @override
  Future<void> pause() async {
    _notifier.setPlaying(false);
  }

  @override
  Future<void> seekTo(Duration position) async {
    _notifier.updatePosition(position);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    // Handled by YouTube player UI settings
  }

  @override
  Future<void> setVolume(double volume) async {
    if (volume <= 0) {
      _notifier.setMuted(true);
    } else {
      _notifier.setMuted(false);
    }
  }

  @override
  Future<void> toggleMute() async {
    _notifier.toggleMute();
  }

  @override
  Future<void> setMute(bool mute) async {
    _notifier.setMuted(mute);
  }

  @override
  Future<void> changeQuality(VideoQuality quality) async {
    // Quality is selected via YouTube sheet
  }

  @override
  Future<void> changeSubtitle(SubtitleTrack? track) async {
    // Subtitles are toggled via YouTube caption settings
  }

  @override
  Widget buildVideoView(BuildContext context) {
    return YouTubeVideoPlayer(
      key: _playerKey,
      videoSource: videoId,
      config: config,
      isLive: isLiveStream,
      viewerCount: viewerCount,
    );
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    _notifier.removeListener(_onNotifierUpdate);
    _stateNotifier.dispose();
  }
}
