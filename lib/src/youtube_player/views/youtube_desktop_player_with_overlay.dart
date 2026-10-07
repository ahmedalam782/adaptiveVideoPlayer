import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/native_pip_service.dart';
import '../../normal_video_player/widgets/adaptive_seek_feedback_overlay.dart';
import '../../normal_video_player/widgets/pip_playback_chrome.dart';
import '../models/youtube_player_config.dart';
import '../widgets/youtube_desktop_overlay.dart';
import '../widgets/youtube_desktop_style_button.dart';
import '../widgets/youtube_webview_player_export.dart';

/// Desktop YouTube player viewport with keyboard shortcut bindings, responsive letterboxing,
/// seek feedback overlays, and bottom action buttons (SRP & OOP).
class YouTubeDesktopPlayerWithOverlay extends StatelessWidget {
  final GlobalKey<YouTubeWebViewPlayerState> desktopWebViewKey;
  final String videoId;
  final YouTubePlayerConfig config;
  final YouTubeDesktopFullscreenManager fullscreenManager;
  final double? aspectRatio;
  final bool isPlaying;
  final bool isHovered;
  final int seekDirection;
  final int seekSeconds;
  final double pipProgress;
  final VoidCallback onTogglePlayPause;
  final void Function(int offsetSeconds) onSeekBy;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onTogglePip;
  final VoidCallback onToggleMute;
  final VoidCallback onOpenFullscreen;
  final VoidCallback onOpenPip;
  final VoidCallback onMouseActivity;
  final VoidCallback onMouseExit;
  final void Function(int position, int duration) onPositionUpdate;
  final ValueChanged<bool> onPlayingStateChanged;
  final ValueChanged<bool> onControlsVisibilityChanged;
  final VoidCallback? onReady;
  final VoidCallback? onEnded;
  final void Function(int direction) onTriggerSeekFeedback;

  const YouTubeDesktopPlayerWithOverlay({
    super.key,
    required this.desktopWebViewKey,
    required this.videoId,
    required this.config,
    required this.fullscreenManager,
    this.aspectRatio,
    required this.isPlaying,
    required this.isHovered,
    required this.seekDirection,
    required this.seekSeconds,
    required this.pipProgress,
    required this.onTogglePlayPause,
    required this.onSeekBy,
    required this.onToggleFullscreen,
    required this.onTogglePip,
    required this.onToggleMute,
    required this.onOpenFullscreen,
    required this.onOpenPip,
    required this.onMouseActivity,
    required this.onMouseExit,
    required this.onPositionUpdate,
    required this.onPlayingStateChanged,
    required this.onControlsVisibilityChanged,
    this.onReady,
    this.onEnded,
    required this.onTriggerSeekFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final inNativePip = NativePipService.isInPip.value;
    final showPipButton = !inNativePip && (isHovered || !isPlaying);
    final showMini = !fullscreenManager.isInPip &&
        !inNativePip &&
        config.visibility.showControls &&
        config.visibility.showMiniPlayerButton;
    final showFullscreen = !fullscreenManager.isInPip &&
        !inNativePip &&
        config.visibility.showControls &&
        config.visibility.showFullscreenButton;
    final effectiveDir = config.text.resolveTextDirection(context);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (fullscreenManager.isInFullscreen) {
            fullscreenManager.closeFullscreen();
          } else if (fullscreenManager.isInPip) {
            fullscreenManager.closePip(pauseOnClose: false);
          }
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => onSeekBy(10),
        const SingleActivator(LogicalKeyboardKey.keyL): () => onSeekBy(10),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => onSeekBy(-10),
        const SingleActivator(LogicalKeyboardKey.keyJ): () => onSeekBy(-10),
        const SingleActivator(LogicalKeyboardKey.space): onTogglePlayPause,
        const SingleActivator(LogicalKeyboardKey.keyK): onTogglePlayPause,
        const SingleActivator(LogicalKeyboardKey.keyF): onToggleFullscreen,
        const SingleActivator(LogicalKeyboardKey.keyI): onTogglePip,
        const SingleActivator(LogicalKeyboardKey.keyM): onToggleMute,
      },
      child: Focus(
        autofocus: true,
        child: Directionality(
          textDirection: effectiveDir,
          child: MouseRegion(
            onEnter: (_) => onMouseActivity(),
            onHover: (_) => onMouseActivity(),
            onExit: (_) => onMouseExit(),
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => onMouseActivity(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final targetAspect = aspectRatio ?? (16.0 / 9.0);
                  double letterboxBottom = 0.0;
                  double pillarboxSide = 0.0;

                  final isCover = config.style.videoFit == BoxFit.cover;

                  if (!isCover &&
                      constraints.maxWidth.isFinite &&
                      constraints.maxHeight.isFinite &&
                      constraints.maxWidth > 0 &&
                      constraints.maxHeight > 0) {
                    final currentAspect =
                        constraints.maxWidth / constraints.maxHeight;
                    if (currentAspect < targetAspect) {
                      final videoHeight = constraints.maxWidth / targetAspect;
                      letterboxBottom =
                          (constraints.maxHeight - videoHeight) / 2.0;
                    } else if (currentAspect > targetAspect) {
                      final videoWidth = constraints.maxHeight * targetAspect;
                      pillarboxSide =
                          (constraints.maxWidth - videoWidth) / 2.0;
                    }
                  }

                  final baseBottom = config.style.bottomBarMargin != null &&
                          config.style.bottomBarMargin is EdgeInsets
                      ? (config.style.bottomBarMargin as EdgeInsets).bottom
                      : (fullscreenManager.isInFullscreen ? 85.0 : 85.0);

                  final responsiveBottom = letterboxBottom + baseBottom;
                  final responsiveRight = pillarboxSide + 6.0;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IgnorePointer(
                        ignoring: inNativePip,
                        child: YouTubeWebViewPlayer(
                          key: desktopWebViewKey,
                          videoId: videoId,
                          config: config,
                          startAt: fullscreenManager.currentPositionSeconds,
                          autoPlay: (fullscreenManager.wasPlaying == true ||
                              fullscreenManager.isInPip),
                          onPositionUpdate: onPositionUpdate,
                          onPlayingStateChanged: onPlayingStateChanged,
                          onReady: onReady,
                          onEnded: onEnded,
                          onEnterFullscreen: onOpenFullscreen,
                          onExitFullscreen: fullscreenManager.closeFullscreen,
                          onSeekForward: () => onTriggerSeekFeedback(1),
                          onSeekBackward: () => onTriggerSeekFeedback(-1),
                          onToggleFullscreen: onToggleFullscreen,
                          onTouchActivity: onMouseActivity,
                          onControlsVisibilityChanged:
                              onControlsVisibilityChanged,
                        ),
                      ),
                      AdaptiveSeekFeedbackOverlay(
                        seekDirection: seekDirection,
                        seekSeconds: seekSeconds,
                        styling: config.style,
                        fallbackColor: const Color(0x6C000000),
                      ),
                      if (showMini || showFullscreen)
                        PositionedDirectional(
                          end: responsiveRight,
                          bottom: responsiveBottom,
                          child: IgnorePointer(
                            ignoring: !showPipButton,
                            child: AnimatedOpacity(
                              opacity: showPipButton ? 1 : 0,
                              duration: const Duration(milliseconds: 220),
                              child: Directionality(
                                textDirection: effectiveDir,
                                child: Container(
                                  height: 36,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0x6C000000),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (showMini)
                                        YouTubeDesktopStyleButton(
                                          playerIcon:
                                              config.style.icons.miniPlayerIcon,
                                          fallbackIcon: Icons
                                              .picture_in_picture_alt_rounded,
                                          tooltip: config.text.miniPlayerText,
                                          onTap: onOpenPip,
                                          size: 19,
                                        ),
                                      if (showFullscreen)
                                        YouTubeDesktopStyleButton(
                                          playerIcon: fullscreenManager
                                                  .isInFullscreen
                                              ? config.style.icons
                                                  .exitFullscreenIcon
                                              : config
                                                  .style.icons.fullscreenIcon,
                                          fallbackIcon: fullscreenManager
                                                  .isInFullscreen
                                              ? Icons.fullscreen_exit_rounded
                                              : Icons.fullscreen_rounded,
                                          tooltip: fullscreenManager
                                                  .isInFullscreen
                                              ? config.text.exitFullscreenText
                                              : config.text.fullscreenText,
                                          onTap: onToggleFullscreen,
                                          size: 21,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (inNativePip)
                        Positioned.fill(
                          child: PipPlaybackChrome(
                            isPlaying: isPlaying,
                            progress: pipProgress,
                            closeTooltip: config.text.closeMiniPlayerText,
                            expandTooltip: config.text.expandPlayerText,
                            playTooltip: config.text.playText,
                            pauseTooltip: config.text.pauseText,
                            onClose: () {
                              desktopWebViewKey.currentState?.pause();
                              NativePipService.closePip();
                            },
                            onExpand: NativePipService.exitPip,
                            onPlayPause: onTogglePlayPause,
                            onSeekBackward: () => onSeekBy(-10),
                            onSeekForward: () => onSeekBy(10),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
