import 'dart:typed_data';
import 'package:flutter/widgets.dart';

import '../../core/contracts/i_analytics_service.dart';
import '../../core/contracts/i_fullscreen_service.dart';
import '../../core/mixins/volume_feedback_mixin.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../../youtube_player/utils/player_utils.dart';
import '../adaptive_controls.dart';
import 'subtitle_track.dart';
import 'video_chapter.dart';
import 'video_file_extension.dart';
import 'video_quality.dart';
import 'video_source_type.dart';

export 'subtitle_track.dart';
export 'video_chapter.dart';
export 'video_file_extension.dart';
export 'video_quality.dart';
export 'video_source_type.dart';

/// Configuration model for the adaptive video player
class VideoConfig {
  /// Video source URL
  final String videoUrl;

  /// Whether the video is a local file
  final bool isFile;

  /// Whether the video is a live stream (disables seek controls and shows LIVE indicator)
  final bool isLive;

  /// Video bytes for in-memory videos
  final Uint8List? videoBytes;

  /// External list of qualities / sources for resolution picker
  final List<VideoQuality>? qualities;

  /// Initial quality if qualities list is provided
  final VideoQuality? initialQuality;

  /// External list of subtitle tracks
  final List<SubtitleTrack>? subtitles;

  /// Initial subtitle track to activate
  final SubtitleTrack? initialSubtitle;

  /// Optional list of timeline chapters (similar to YouTube chapters)
  final List<VideoChapter>? chapters;

  /// Custom ui builder for rendering over the video
  final AdaptiveControlsBuilder? controlsBuilder;

  /// Custom builder for subtitles layer
  final SubtitleBuilder? subtitleBuilder;

  /// Custom builder for volume feedback overlay HUD
  final VolumeFeedbackBuilder? volumeFeedbackBuilder;

  /// Custom loading widget builder
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Custom error widget builder
  final Widget Function(BuildContext context, String errorMessage)? errorBuilder;

  /// Optional custom fullscreen service injection (DIP)
  final IFullscreenService? fullscreenService;

  /// Optional custom analytics service injection (DIP)
  final IAnalyticsService? analyticsService;

  /// Optional viewer count to display when stream is live
  final String? viewerCount;

  /// Analytics hook for external tracking of video events
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;

  /// Optional explicit video file extension (e.g. VideoFileExtension.hls for extensionless streams)
  final VideoFileExtension? extension;

  /// Optional explicit video source type (e.g. VideoSourceType.network)
  final VideoSourceType? sourceType;

  /// Optional aspect ratio override for the video player (e.g. 16/9, 9/16).
  /// If null, automatically uses the video's natural aspect ratio.
  final double? aspectRatio;

  /// Complete player configuration using YouTube models
  final YouTubePlayerConfig playerConfig;

  const VideoConfig({
    required this.videoUrl,
    this.isFile = false,
    this.isLive = false,
    this.videoBytes,
    this.qualities,
    this.initialQuality,
    this.subtitles,
    this.initialSubtitle,
    this.chapters,
    this.controlsBuilder,
    this.subtitleBuilder,
    this.volumeFeedbackBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.fullscreenService,
    this.analyticsService,
    this.viewerCount,
    this.onAnalyticsEvent,
    this.extension,
    this.sourceType,
    this.aspectRatio,
    this.playerConfig = const YouTubePlayerConfig(),
  });

  // Convenience getters
  PlayerStyleConfig get styling => playerConfig.style;
  PlayerIconConfig get icons => playerConfig.style.icons;
  PlayerTextConfig get messages => playerConfig.text;
  PlayerVisibilityConfig get visibility => playerConfig.visibility;
  PlayerPlaybackConfig get playback => playerConfig.playback;

  /// Whether this video configuration targets a YouTube video URL
  bool get isYouTube => PlayerUtils.isYouTubeUrl(videoUrl);

  VideoConfig copyWith({
    String? videoUrl,
    bool? isFile,
    bool? isLive,
    Uint8List? videoBytes,
    List<VideoQuality>? qualities,
    VideoQuality? initialQuality,
    List<SubtitleTrack>? subtitles,
    SubtitleTrack? initialSubtitle,
    List<VideoChapter>? chapters,
    AdaptiveControlsBuilder? controlsBuilder,
    SubtitleBuilder? subtitleBuilder,
    VolumeFeedbackBuilder? volumeFeedbackBuilder,
    Widget Function(BuildContext context)? loadingBuilder,
    Widget Function(BuildContext context, String errorMessage)? errorBuilder,
    IFullscreenService? fullscreenService,
    IAnalyticsService? analyticsService,
    String? viewerCount,
    void Function(String event, Map<String, dynamic> data)? onAnalyticsEvent,
    VideoFileExtension? extension,
    VideoSourceType? sourceType,
    double? aspectRatio,
    YouTubePlayerConfig? playerConfig,
  }) {
    return VideoConfig(
      videoUrl: videoUrl ?? this.videoUrl,
      isFile: isFile ?? this.isFile,
      isLive: isLive ?? this.isLive,
      videoBytes: videoBytes ?? this.videoBytes,
      qualities: qualities ?? this.qualities,
      initialQuality: initialQuality ?? this.initialQuality,
      subtitles: subtitles ?? this.subtitles,
      initialSubtitle: initialSubtitle ?? this.initialSubtitle,
      chapters: chapters ?? this.chapters,
      controlsBuilder: controlsBuilder ?? this.controlsBuilder,
      subtitleBuilder: subtitleBuilder ?? this.subtitleBuilder,
      volumeFeedbackBuilder:
          volumeFeedbackBuilder ?? this.volumeFeedbackBuilder,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      fullscreenService: fullscreenService ?? this.fullscreenService,
      analyticsService: analyticsService ?? this.analyticsService,
      viewerCount: viewerCount ?? this.viewerCount,
      onAnalyticsEvent: onAnalyticsEvent ?? this.onAnalyticsEvent,
      extension: extension ?? this.extension,
      sourceType: sourceType ?? this.sourceType,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      playerConfig: playerConfig ?? this.playerConfig,
    );
  }
}
