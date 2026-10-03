import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/youtube_player_config.dart';
import '../widgets/youtube_controls_overlay.dart';
import '../widgets/youtube_live_badge.dart';
import '../widgets/youtube_replay_overlay.dart';

/// Renders the mobile YouTube player view with controls, live badge, and replay overlay.
class YouTubeMobilePlayerView extends StatelessWidget {
  final YoutubePlayerController controller;
  final YouTubePlayerConfig config;
  final bool isLive;
  final String? viewerCount;
  final bool isMuted;
  final bool videoEnded;
  final VoidCallback onFullscreenTap;
  final VoidCallback onMuteTap;
  final VoidCallback onSettingsTap;
  final VoidCallback? onPipTap;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;
  final VoidCallback onRestartVideo;
  final YouTubeLiveBadgeBuilder? liveBadgeBuilder;
  final YouTubeReplayBuilder? replayBuilder;
  final bool hideChrome;

  const YouTubeMobilePlayerView({
    super.key,
    required this.controller,
    required this.config,
    this.isLive = false,
    this.viewerCount,
    required this.isMuted,
    required this.videoEnded,
    required this.onFullscreenTap,
    required this.onMuteTap,
    required this.onSettingsTap,
    this.onPipTap,
    required this.onSeekBackward,
    required this.onSeekForward,
    required this.onRestartVideo,
    this.liveBadgeBuilder,
    this.replayBuilder,
    this.hideChrome = false,
  });

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: controller,
      autoFullScreen: false,
      enableFullScreenOnVerticalDrag: false,
      builder: (context, player, ctrl) {
        if (hideChrome) return player;
        return YoutubeValueBuilder(
          controller: ctrl,
          buildWhen: (previous, next) =>
              previous.fullScreenOption.enabled !=
              next.fullScreenOption.enabled,
          builder: (context, value) {
            final isFullscreen = value.fullScreenOption.enabled;
            return Stack(
              children: [
                player,
                CustomYoutubeControls(
                  controller: ctrl,
                  config: config,
                  isLive: isLive,
                  isMuted: isMuted,
                  isFullscreen: isFullscreen,
                  onFullscreenTap: onFullscreenTap,
                  onMuteTap: onMuteTap,
                  onSettingsTap: onSettingsTap,
                  onPipTap: onPipTap,
                  onSeekBackward: onSeekBackward,
                  onSeekForward: onSeekForward,
                  topActions: ((isLive || viewerCount != null) &&
                          config.visibility.showLiveBadge)
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: (liveBadgeBuilder ?? config.liveBadgeBuilder)
                                  ?.call(
                                context,
                                isLive: isLive,
                                viewerCount: viewerCount,
                              ) ??
                              YouTubeLiveBadge(
                                isLive: isLive,
                                viewerCount: viewerCount,
                                liveText: config.text.liveText,
                                badgeColor: config.style.progressBarPlayedColor,
                                iconColor: config.style.iconColor,
                                textColor: config.style.textColor,
                              ),
                        )
                      : null,
                ),
                if (videoEnded)
                  (replayBuilder ?? config.replayBuilder)?.call(
                        context,
                        onRestartVideo,
                      ) ??
                      YouTubeReplayOverlay(
                        onRestart: onRestartVideo,
                        iconColor: config.style.iconColor,
                        replayIcon: config.style.icons.replayIcon,
                      ),
              ],
            );
          },
        );
      },
    );
  }
}
