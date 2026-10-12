import 'package:flutter/material.dart';

import '../../../youtube_player/models/youtube_player_config.dart';
import '../../models/video_config.dart';
import '../../utils/video_player_web_safe.dart';
import '../responsive/responsive_filled_panels.dart';
import 'mobile_player_chrome.dart';
import 'mobile_screen_lock_badge.dart';

/// Phone surface: lock badge, filled panels, then [MobilePlayerChrome].
class MobileControlsSurface extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isFullScreen;
  final bool isLive;
  final bool screenLocked;
  final bool isRtl;
  final bool showAudioSubtitles;
  final bool showEpisodes;
  final bool showSpeed;
  final bool showSettings;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final PlayerVisibilityConfig? visibility;
  final PlayerPlaybackConfig? playback;
  final List<VideoChapter>? chapters;
  final void Function(String event, Map<String, dynamic> data)? onAnalyticsEvent;
  final String? title;
  final VideoEpisode? currentEpisode;
  final List<VideoEpisode>? episodes;
  final List<AudioTrack>? audioTracks;
  final AudioTrack? currentAudioTrack;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final List<VideoQuality>? qualities;
  final VideoQuality? currentQuality;
  final double? dragPosition;
  final ValueNotifier<double>? brightnessListenable;
  final ValueChanged<double>? onDragChanged;
  final ValueChanged<double>? onDragEnd;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onExitFullscreen;
  final VoidCallback? onMiniPlayerPressed;
  final VoidCallback? onNextEpisode;
  final VoidCallback? onEpisodesPressed;
  final VoidCallback? onAudioSubtitlesPressed;
  final VoidCallback? onSpeedPressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onLockPressed;
  final VoidCallback? onUnlock;
  final VoidCallback? onHideControls;
  final ValueChanged<AudioTrack>? onAudioTrackSelected;
  final ValueChanged<SubtitleTrack?>? onSubtitleSelected;
  final ValueChanged<VideoEpisode>? onEpisodeSelected;
  final ValueChanged<VideoQuality>? onQualitySelected;
  final VoidCallback? onCloseAudioSubtitles;
  final VoidCallback? onCloseEpisodes;
  final VoidCallback? onCloseSpeed;
  final VoidCallback? onCloseSettings;

  const MobileControlsSurface({
    super.key,
    required this.controller,
    required this.isFullScreen,
    required this.screenLocked,
    required this.isRtl,
    this.isLive = false,
    this.showAudioSubtitles = false,
    this.showEpisodes = false,
    this.showSpeed = false,
    this.showSettings = false,
    this.styling,
    this.messages,
    this.visibility,
    this.playback,
    this.chapters,
    this.onAnalyticsEvent,
    this.title,
    this.currentEpisode,
    this.episodes,
    this.audioTracks,
    this.currentAudioTrack,
    this.subtitles,
    this.currentSubtitleTrack,
    this.qualities,
    this.currentQuality,
    this.dragPosition,
    this.brightnessListenable,
    this.onDragChanged,
    this.onDragEnd,
    this.onEnterFullscreen,
    this.onExitFullscreen,
    this.onMiniPlayerPressed,
    this.onNextEpisode,
    this.onEpisodesPressed,
    this.onAudioSubtitlesPressed,
    this.onSpeedPressed,
    this.onSettingsPressed,
    this.onLockPressed,
    this.onUnlock,
    this.onHideControls,
    this.onAudioTrackSelected,
    this.onSubtitleSelected,
    this.onEpisodeSelected,
    this.onQualitySelected,
    this.onCloseAudioSubtitles,
    this.onCloseEpisodes,
    this.onCloseSpeed,
    this.onCloseSettings,
  });

  @override
  Widget build(BuildContext context) {
    if (screenLocked) {
      return MobileScreenLockBadge(
        isRtl: isRtl,
        onUnlock: onUnlock ?? () {},
        onDismiss: onHideControls,
      );
    }

    final panels = ResponsiveFilledPanels(
      showAudioSubtitles: showAudioSubtitles,
      showEpisodes: showEpisodes,
      showSpeed: showSpeed,
      showSettings: showSettings,
      controller: controller,
      audioTracks: audioTracks,
      currentAudioTrack: currentAudioTrack,
      onAudioTrackSelected: onAudioTrackSelected,
      subtitles: subtitles,
      currentSubtitleTrack: currentSubtitleTrack,
      onSubtitleSelected: onSubtitleSelected,
      episodes: episodes,
      currentEpisode: currentEpisode,
      onEpisodeSelected: onEpisodeSelected,
      qualities: qualities,
      currentQuality: currentQuality,
      onQualitySelected: onQualitySelected,
      styling: styling,
      messages: messages,
      visibility: visibility,
      onAnalyticsEvent: onAnalyticsEvent,
      onCloseAudioSubtitles: onCloseAudioSubtitles,
      onCloseEpisodes: onCloseEpisodes,
      onCloseSpeed: onCloseSpeed,
      onCloseSettings: onCloseSettings,
    );
    if (panels.isOpen) return panels;

    return MobilePlayerChrome(
      controller: controller,
      isFullScreen: isFullScreen,
      isLive: isLive,
      styling: styling,
      messages: messages,
      visibility: visibility,
      playback: playback,
      chapters: chapters,
      onAnalyticsEvent: onAnalyticsEvent,
      title: title,
      currentEpisode: currentEpisode,
      episodes: episodes,
      audioTracks: audioTracks,
      subtitles: subtitles,
      dragPosition: dragPosition,
      brightnessListenable: brightnessListenable,
      onDragChanged: onDragChanged,
      onDragEnd: onDragEnd,
      onEnterFullscreen: onEnterFullscreen,
      onExitFullscreen: onExitFullscreen,
      onMiniPlayerPressed: onMiniPlayerPressed,
      onNextEpisode: onNextEpisode,
      onEpisodesPressed: onEpisodesPressed,
      onAudioSubtitlesPressed: onAudioSubtitlesPressed,
      onSpeedPressed: onSpeedPressed,
      onSettingsPressed: onSettingsPressed,
      onLockPressed: onLockPressed,
    );
  }
}
