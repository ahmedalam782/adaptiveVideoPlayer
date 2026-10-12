import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../youtube_player/models/youtube_player_config.dart';
import '../../models/video_config.dart';
import '../../utils/video_player_web_safe.dart';
import '../adaptive_audio_subtitles_popup.dart';
import '../adaptive_episodes_drawer.dart';
import '../adaptive_player_settings_sheet.dart';
import '../adaptive_speed_stepper_popup.dart';

/// Edge-to-edge panels shared by the phone design and a tablet-sized window.
///
/// Wide desktop keeps the floating popups in the controls layer.
class ResponsiveFilledPanels extends StatelessWidget {
  final bool showAudioSubtitles;
  final bool showEpisodes;
  final bool showSpeed;
  final bool showSettings;
  final VideoPlayerController? controller;
  final List<AudioTrack>? audioTracks;
  final AudioTrack? currentAudioTrack;
  final ValueChanged<AudioTrack>? onAudioTrackSelected;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final ValueChanged<SubtitleTrack?>? onSubtitleSelected;
  final List<VideoEpisode>? episodes;
  final VideoEpisode? currentEpisode;
  final ValueChanged<VideoEpisode>? onEpisodeSelected;
  final List<VideoQuality>? qualities;
  final VideoQuality? currentQuality;
  final ValueChanged<VideoQuality>? onQualitySelected;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final PlayerVisibilityConfig? visibility;
  final void Function(String event, Map<String, dynamic> data)? onAnalyticsEvent;
  final VoidCallback? onCloseAudioSubtitles;
  final VoidCallback? onCloseEpisodes;
  final VoidCallback? onCloseSpeed;
  final VoidCallback? onCloseSettings;

  const ResponsiveFilledPanels({
    super.key,
    this.showAudioSubtitles = false,
    this.showEpisodes = false,
    this.showSpeed = false,
    this.showSettings = false,
    this.controller,
    this.audioTracks,
    this.currentAudioTrack,
    this.onAudioTrackSelected,
    this.subtitles,
    this.currentSubtitleTrack,
    this.onSubtitleSelected,
    this.episodes,
    this.currentEpisode,
    this.onEpisodeSelected,
    this.qualities,
    this.currentQuality,
    this.onQualitySelected,
    this.styling,
    this.messages,
    this.visibility,
    this.onAnalyticsEvent,
    this.onCloseAudioSubtitles,
    this.onCloseEpisodes,
    this.onCloseSpeed,
    this.onCloseSettings,
  });

  bool get isOpen =>
      showAudioSubtitles ||
      (showEpisodes && episodes != null) ||
      showSpeed ||
      showSettings;

  @override
  Widget build(BuildContext context) {
    if (showAudioSubtitles) {
      return ResponsiveAudioSubtitlesPanel(
        immersive: true,
        audioTracks: audioTracks,
        currentAudioTrack: currentAudioTrack,
        onAudioTrackSelected: onAudioTrackSelected,
        subtitles: subtitles,
        currentSubtitleTrack: currentSubtitleTrack,
        onSubtitleSelected: onSubtitleSelected,
        styling: styling,
        messages: messages,
        onClose: onCloseAudioSubtitles,
      );
    }

    if (showEpisodes && episodes != null) {
      return ResponsiveEpisodesPanel(
        horizontal: true,
        episodes: episodes!,
        currentEpisode: currentEpisode,
        onEpisodeSelected: onEpisodeSelected,
        styling: styling,
        messages: messages,
        onClose: onCloseEpisodes,
      );
    }

    if (showSpeed && controller != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onCloseSpeed,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: ResponsiveSpeedPanel(
              asSheet: true,
              controller: controller!,
              styling: styling,
              messages: messages,
              onClose: onCloseSpeed,
            ),
          ),
        ),
      );
    }

    if (showSettings) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = math.min(320.0, constraints.maxHeight * 0.62);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onCloseSettings,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {},
                child: Material(
                  color: styling?.settingsBackgroundColor ?? const Color(0xF21F1F1F),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth,
                      maxHeight: maxHeight,
                    ),
                    child: AdaptivePlayerSettingsSheet(
                      styling: styling,
                      messages: messages,
                      visibility: visibility,
                      qualities: qualities,
                      currentQuality: currentQuality,
                      onQualitySelected: (quality) {
                        onQualitySelected?.call(quality);
                        onCloseSettings?.call();
                      },
                      subtitles: subtitles,
                      currentSubtitleTrack: currentSubtitleTrack,
                      onSubtitleSelected: (track) {
                        onSubtitleSelected?.call(track);
                        onCloseSettings?.call();
                      },
                      onDismiss: onCloseSettings,
                      onAnalyticsEvent: onAnalyticsEvent,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}
