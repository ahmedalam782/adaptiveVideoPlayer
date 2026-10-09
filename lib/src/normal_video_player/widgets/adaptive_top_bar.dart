import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/player_strings.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../models/video_config.dart';
import 'adaptive_circle_pill_button.dart';
import 'adaptive_live_indicator.dart';

/// Top bar overlay displaying back button, live status, viewer count, and top-end actions.
class AdaptiveTopBar extends StatelessWidget {
  final bool isFullScreen;
  final VoidCallback? onExitFullscreen;
  final bool isLive;
  final String? viewerCount;
  final List<VideoQuality>? qualities;
  final void Function(VideoQuality)? onQualitySelected;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;
  final bool? showBackButton;
  final PlayerTextConfig? messages;
  final PlayerStyleConfig? styling;
  final PlayerVisibilityConfig? visibility;
  final String? title;
  final String? subtitle;

  /// Optional episodes list
  final List<VideoEpisode>? episodes;

  /// Callback when Episodes button is pressed
  final VoidCallback? onEpisodesPressed;

  /// Optional audio tracks
  final List<AudioTrack>? audioTracks;

  /// Optional subtitles
  final List<SubtitleTrack>? subtitles;

  /// Current subtitle track
  final SubtitleTrack? currentSubtitleTrack;

  /// Callback when subtitle track is selected
  final void Function(SubtitleTrack?)? onSubtitleSelected;

  /// Callback when Audio & Subtitles button is pressed
  final VoidCallback? onAudioSubtitlesPressed;

  /// Callback when Speed button is pressed
  final VoidCallback? onSpeedPressed;

  /// Callback when Settings button is pressed
  final VoidCallback? onSettingsPressed;

  /// Callback when MiniPlayer / PiP button is pressed
  final VoidCallback? onMiniPlayerPressed;

  /// Whether to show action buttons in the top bar (overrides visibility.showActionsInTopBar if specified)
  final bool? showActions;

  const AdaptiveTopBar({
    super.key,
    required this.isFullScreen,
    this.onExitFullscreen,
    this.isLive = false,
    this.viewerCount,
    this.qualities,
    this.onQualitySelected,
    this.onAnalyticsEvent,
    this.showBackButton,
    this.messages,
    this.styling,
    this.visibility,
    this.title,
    this.subtitle,
    this.episodes,
    this.onEpisodesPressed,
    this.audioTracks,
    this.subtitles,
    this.currentSubtitleTrack,
    this.onSubtitleSelected,
    this.onAudioSubtitlesPressed,
    this.onSpeedPressed,
    this.onSettingsPressed,
    this.onMiniPlayerPressed,
    this.showActions,
  });

  bool get _shouldShowBackButton => showBackButton == true;

  @override
  Widget build(BuildContext context) {
    final textDirection = messages?.resolveTextDirection(context) ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;
    final isRtl = textDirection == TextDirection.rtl;
    final iconColor = styling?.iconColor ?? Colors.white;
    final textColor = styling?.textColor ?? Colors.white;
    final showLive = visibility?.showLiveBadge ?? true;

    return Directionality(
      textDirection: textDirection,
      child: Row(
        children: [
          if (_shouldShowBackButton)
            Tooltip(
              message: messages?.backText ??
                  messages?.exitFullscreenText ??
                  'Back',
              child: GestureDetector(
                onTap: onExitFullscreen,
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.30),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: PlayerIcon.resolve(
                        context,
                        icon: styling?.icons.backIcon,
                        fallbackIcon: isRtl
                            ? Icons.arrow_forward_rounded
                            : Icons.arrow_back_rounded,
                        defaultColor: iconColor,
                        defaultSize: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_shouldShowBackButton) const SizedBox(width: 8),
          if (showLive)
            AdaptiveLiveIndicator(
              isLive: isLive,
              qualities: qualities,
              onQualitySelected: onQualitySelected,
              onAnalyticsEvent: onAnalyticsEvent,
              messages: messages,
              styling: styling,
            ),
          if (title != null && title!.isNotEmpty) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 1.0),
                      child: Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.75),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ] else
            const Spacer(),
          if (viewerCount != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PlayerIcon.resolve(
                        context,
                        icon: styling?.icons.viewerCountIcon,
                        fallbackIcon: Icons.remove_red_eye_outlined,
                        defaultColor: iconColor,
                        defaultSize: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        viewerCount!,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Top-End Action Buttons (Episodes, Subtitles, Speed, Settings, MiniPlayer)
          if (showActions ?? visibility?.showActionsInTopBar ?? false) ...[
            // Episodes Drawer Button
            if ((visibility?.showEpisodesButton ?? true) &&
                episodes != null &&
                episodes!.isNotEmpty &&
                onEpisodesPressed != null) ...[
              const SizedBox(width: 8),
              AdaptiveCirclePillButton(
                playerIcon: styling?.icons.episodesIcon,
                icon: Icons.video_library_outlined,
                tooltip: messages?.episodesText ?? 'Episodes',
                onTap: onEpisodesPressed!,
                color: iconColor,
              ),
            ],

            // Dual-Column Audio & Subtitles Button
            if ((visibility?.showAudioSubtitlesButton ?? true) &&
                onAudioSubtitlesPressed != null &&
                ((audioTracks != null && audioTracks!.isNotEmpty) ||
                    (subtitles != null && subtitles!.isNotEmpty))) ...[
              const SizedBox(width: 8),
              AdaptiveCirclePillButton(
                playerIcon: styling?.icons.audioSubtitlesIcon,
                icon: Icons.subtitles_outlined,
                tooltip: messages?.audioAndSubtitlesText ?? 'Audio & Subtitles',
                onTap: onAudioSubtitlesPressed!,
                color: iconColor,
              ),
            ],

            // Playback Speed Button
            if ((visibility?.showSpeedButton ?? true) &&
                onSpeedPressed != null) ...[
              const SizedBox(width: 8),
              AdaptiveCirclePillButton(
                playerIcon: styling?.icons.speedIcon,
                icon: Icons.speed_rounded,
                tooltip: messages?.playbackSpeedText ?? 'Playback Speed',
                onTap: onSpeedPressed!,
                color: iconColor,
              ),
            ],

            // Settings Button
            if ((visibility?.showSettingsButton ?? true) &&
                onSettingsPressed != null) ...[
              const SizedBox(width: 8),
              AdaptiveCirclePillButton(
                playerIcon: styling?.icons.settingsIcon,
                icon: Icons.settings_outlined,
                tooltip: messages?.playerSettingsText ??
                    PlayerStrings.playerSettings,
                onTap: onSettingsPressed!,
                color: iconColor,
              ),
            ],

            // MiniPlayer / PiP Button
            if ((visibility?.showMiniPlayerButton ?? true) &&
                onMiniPlayerPressed != null) ...[
              const SizedBox(width: 8),
              AdaptiveCirclePillButton(
                playerIcon: styling?.icons.miniPlayerIcon,
                icon: Icons.picture_in_picture_alt_rounded,
                tooltip: messages?.miniPlayerText ?? 'Miniplayer',
                onTap: onMiniPlayerPressed!,
                color: iconColor,
              ),
            ],
          ],
        ],
      ),
    );
  }
}
