import 'package:flutter/material.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../models/video_config.dart';
import '../utils/video_player_web_safe.dart';
import 'adaptive_fullscreen_button.dart';
import 'adaptive_settings_button.dart';
import 'adaptive_volume_control.dart';

/// Bottom bar for normal player with play/pause, volume, time, settings, and fullscreen.
class AdaptiveBottomBar extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isFullScreen;
  final bool isLive;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final List<VideoQuality>? qualities;
  final VideoQuality? currentQuality;
  final void Function(VideoQuality)? onQualitySelected;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final void Function(SubtitleTrack?)? onSubtitleSelected;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onExitFullscreen;
  final VoidCallback? onSettingsPressed;

  const AdaptiveBottomBar({
    super.key,
    required this.controller,
    required this.isFullScreen,
    this.isLive = false,
    this.styling,
    this.messages,
    this.qualities,
    this.currentQuality,
    this.onQualitySelected,
    this.subtitles,
    this.currentSubtitleTrack,
    this.onSubtitleSelected,
    this.onAnalyticsEvent,
    this.onEnterFullscreen,
    this.onExitFullscreen,
    this.onSettingsPressed,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, VideoPlayerValue value, child) {
          final isPlaying = value.isPlaying;
          final position = value.position;
          final duration = value.duration;

          return Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (isPlaying) {
                    controller.pause();
                    onAnalyticsEvent?.call('video_paused',
                        {'position': controller.value.position.inSeconds});
                  } else {
                    controller.play();
                    onAnalyticsEvent?.call('video_played',
                        {'position': controller.value.position.inSeconds});
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: styling?.iconColor ?? Colors.white,
                    size: 20,
                  ),
                ),
              ),
              AdaptiveVolumeControl(
                controller: controller,
                styling: styling,
              ),
              const SizedBox(width: 8),
              if (!isLive)
                Text(
                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                  style: styling?.settingItemTextStyle ??
                      const TextStyle(color: Colors.white, fontSize: 12),
                ),
              const Spacer(),
              AdaptiveSettingsButton(
                isFullScreen: isFullScreen,
                styling: styling,
                messages: messages,
                qualities: qualities,
                currentQuality: currentQuality,
                onQualitySelected: onQualitySelected,
                subtitles: subtitles,
                currentSubtitleTrack: currentSubtitleTrack,
                onSubtitleSelected: onSubtitleSelected,
                onAnalyticsEvent: onAnalyticsEvent,
                onPressed: onSettingsPressed,
              ),
              const SizedBox(width: 4),
              AdaptiveFullscreenButton(
                isFullScreen: isFullScreen,
                styling: styling,
                onEnterFullscreen: onEnterFullscreen,
                onExitFullscreen: onExitFullscreen,
              ),
            ],
          );
        },
      ),
    );
  }
}
