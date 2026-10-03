import 'package:flutter/material.dart';

import 'src/core/contracts/i_analytics_service.dart';
import 'src/core/contracts/i_fullscreen_service.dart';
import 'src/core/contracts/i_video_player_controller.dart';
import 'src/core/di/player_scope.dart';
import 'src/core/factory/player_controller_factory.dart';
import 'src/core/services/analytics_service.dart';
import 'src/core/services/fullscreen_service.dart';
import 'src/normal_video_player/models/video_config.dart';
import 'src/normal_video_player/normal_video_player.dart';
import 'src/youtube_player/utils/player_utils.dart';
import 'src/youtube_player/youtube_video_player.dart';

// Public API Exports for SOLID, OOP, and Design Patterns architecture
export 'src/core/adapters/native_player_adapter.dart';
export 'src/core/adapters/youtube_player_adapter.dart';
export 'src/core/contracts/i_analytics_service.dart';
export 'src/core/contracts/i_fullscreen_service.dart';
export 'src/core/contracts/i_playback_controls.dart';
export 'src/core/contracts/i_quality_manageable.dart';
export 'src/core/contracts/i_subtitle_manageable.dart';
export 'src/core/contracts/i_video_player_controller.dart';
export 'src/core/contracts/i_volume_controls.dart';
export 'src/core/di/player_scope.dart';
export 'src/core/di/service_locator.dart';
export 'src/core/factory/player_controller_factory.dart';
export 'src/core/models/player_state.dart';
export 'src/core/extensions/player_context_extensions.dart';
export 'src/core/extensions/player_duration_extensions.dart';
export 'src/core/extensions/player_state_extensions.dart';
export 'src/core/mixins/controls_visibility_mixin.dart';
export 'src/core/mixins/volume_feedback_mixin.dart';
export 'src/core/services/analytics_service.dart';
export 'src/core/services/fullscreen_service.dart';
export 'src/core/services/native_pip_service.dart';
export 'src/normal_video_player/adaptive_controls.dart'
    show AdaptiveControlsBuilder, SubtitleBuilder;
export 'src/normal_video_player/models/video_config.dart';
export 'src/normal_video_player/widgets/adaptive_inline_bottom_bar.dart';
export 'src/platform_init.dart';
export 'src/youtube_player/cubit/youtube_player_cubit.dart';
export 'src/youtube_player/models/player_icon_config.dart';
export 'src/youtube_player/models/youtube_player_config.dart';
export 'src/youtube_player/utils/player_utils.dart';
export 'src/youtube_player/widgets/fullscreen_player_page.dart';
export 'src/youtube_player/widgets/player_controls.dart';
export 'src/youtube_player/widgets/player_error_widget.dart';
export 'src/youtube_player/widgets/player_loading_widget.dart';
export 'src/youtube_player/widgets/youtube_controls_overlay.dart';
export 'src/youtube_player/widgets/youtube_live_badge.dart';
export 'src/youtube_player/widgets/youtube_replay_overlay.dart';
export 'src/youtube_player/youtube_video_player.dart';

/// Adaptive video player that detects and plays both YouTube and normal videos (OCP, DIP, LSP).
///
/// Supports automatic strategy detection via [PlayerControllerFactory] and
/// Dependency Injection via [PlayerScope].
class AdaptiveVideoPlayer extends StatefulWidget {
  final VideoConfig config;
  final IVideoPlayerController? customController;
  final IFullscreenService? fullscreenService;
  final IAnalyticsService? analyticsService;
  final double? aspectRatio;

  const AdaptiveVideoPlayer({
    super.key,
    required this.config,
    this.customController,
    this.fullscreenService,
    this.analyticsService,
    this.aspectRatio,
  });

  @override
  State<AdaptiveVideoPlayer> createState() => _AdaptiveVideoPlayerState();
}

class _AdaptiveVideoPlayerState extends State<AdaptiveVideoPlayer> {
  bool _isYouTubeVideo = false;
  String? _youtubeVideoId;
  late final IFullscreenService _fullscreenService;
  late final IAnalyticsService _analyticsService;

  @override
  void initState() {
    super.initState();
    _fullscreenService = widget.fullscreenService ??
        widget.config.fullscreenService ??
        PlatformFullscreenService();
    _analyticsService = widget.analyticsService ??
        widget.config.analyticsService ??
        CallbackAnalyticsService(widget.config.onAnalyticsEvent);
    _detectVideoType();
  }

  @override
  void dispose() {
    _fullscreenService.dispose();
    super.dispose();
  }

  /// Detects if the video URL is a YouTube video
  void _detectVideoType() {
    final videoId = PlayerUtils.extractVideoId(widget.config.videoUrl);
    if (videoId != null && videoId.isNotEmpty) {
      setState(() {
        _isYouTubeVideo = true;
        _youtubeVideoId = videoId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If a custom polymorphic controller is injected, render it directly
    if (widget.customController != null) {
      return PlayerScope(
        controller: widget.customController!,
        fullscreenService: _fullscreenService,
        analyticsService: _analyticsService,
        child: widget.customController!.buildVideoView(context),
      );
    }

    if (_isYouTubeVideo && _youtubeVideoId != null) {
      // Use YouTubeVideoPlayer for YouTube videos
      return YouTubeVideoPlayer(
        videoSource: _youtubeVideoId!,
        config: widget.config.playerConfig,
        viewerCount: widget.config.viewerCount,
        isLive: widget.config.isLive,
        loadingBuilder: widget.config.loadingBuilder,
        errorBuilder: widget.config.errorBuilder,
        aspectRatio: widget.aspectRatio ?? widget.config.aspectRatio,
      );
    }

    // For normal videos, use NormalVideoPlayer
    return NormalVideoPlayer(
      videoSource: widget.config.videoUrl,
      isFile: widget.config.isFile,
      videoBytes: widget.config.videoBytes,
      isLive: widget.config.isLive,
      qualities: widget.config.qualities,
      initialQuality: widget.config.initialQuality,
      subtitles: widget.config.subtitles,
      initialSubtitle: widget.config.initialSubtitle,
      chapters: widget.config.chapters,
      viewerCount: widget.config.viewerCount,
      styling: widget.config.styling,
      messages: widget.config.messages,
      visibility: widget.config.visibility,
      playback: widget.config.playback,
      controlsBuilder: widget.config.controlsBuilder,
      subtitleBuilder: widget.config.subtitleBuilder,
      loadingBuilder: widget.config.loadingBuilder,
      errorBuilder: widget.config.errorBuilder,
      onAnalyticsEvent: widget.config.onAnalyticsEvent,
      extension: widget.config.extension,
      sourceType: widget.config.sourceType,
      aspectRatio: widget.config.aspectRatio,
    );
  }
}
