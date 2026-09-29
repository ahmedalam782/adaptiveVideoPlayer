import 'package:flutter/material.dart';

import '../../youtube_player/models/youtube_player_config.dart';
import '../adaptive_controls.dart';
import '../models/video_config.dart';
import '../utils/subtitle_parser.dart';
import '../utils/video_player_web_safe.dart';

/// Renders the base adaptive video player with its controls and overlays.
class NormalPlayerView extends StatelessWidget {
  final VideoPlayerController controller;
  final bool showControls;
  final bool isFullScreen;
  final bool isLive;
  final AdaptiveControlsBuilder? controlsBuilder;
  final SubtitleBuilder? subtitleBuilder;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;
  final List<VideoQuality>? qualities;
  final VideoQuality? currentQuality;
  final ValueChanged<VideoQuality>? onQualitySelected;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final ValueChanged<SubtitleTrack?>? onSubtitleSelected;
  final List<SubtitleItem> parsedSubtitles;
  final String? viewerCount;
  final VoidCallback onEnterFullscreen;
  final VoidCallback onExitFullscreen;

  const NormalPlayerView({
    super.key,
    required this.controller,
    required this.showControls,
    required this.isFullScreen,
    required this.isLive,
    this.controlsBuilder,
    this.subtitleBuilder,
    this.styling,
    this.messages,
    this.onAnalyticsEvent,
    this.qualities,
    this.currentQuality,
    this.onQualitySelected,
    this.subtitles,
    this.currentSubtitleTrack,
    this.onSubtitleSelected,
    required this.parsedSubtitles,
    this.viewerCount,
    required this.onEnterFullscreen,
    required this.onExitFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return BaseAdaptiveVideoPlayer(
      controller: controller,
      showControls: showControls,
      isFullScreen: isFullScreen,
      isLive: isLive,
      controlsBuilder: controlsBuilder,
      subtitleBuilder: subtitleBuilder,
      styling: styling,
      messages: messages,
      onAnalyticsEvent: onAnalyticsEvent,
      qualities: qualities,
      currentQuality: currentQuality,
      onQualitySelected: onQualitySelected,
      subtitles: subtitles,
      currentSubtitleTrack: currentSubtitleTrack,
      onSubtitleSelected: onSubtitleSelected,
      parsedSubtitles: parsedSubtitles,
      viewerCount: viewerCount,
      onEnterFullscreen: onEnterFullscreen,
      onExitFullscreen: onExitFullscreen,
    );
  }
}
