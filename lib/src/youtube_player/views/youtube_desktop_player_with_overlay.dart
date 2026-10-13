import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/native_pip_service.dart';
import '../../normal_video_player/utils/fullscreen_utils_export.dart';
import '../../normal_video_player/widgets/adaptive_seek_feedback_overlay.dart';
import '../../normal_video_player/widgets/pip_playback_chrome.dart';
import '../models/youtube_player_config.dart';
import '../widgets/youtube_desktop_overlay.dart';
import '../widgets/youtube_live_badge.dart';
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
  final bool isLive;
  final String? viewerCount;
  final YouTubeLiveBadgeBuilder? liveBadgeBuilder;

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
    this.isLive = false,
    this.viewerCount,
    this.liveBadgeBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final inNativePip = NativePipService.isInPip.value;
    final isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
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
                  final isCover = config.style.videoFit == BoxFit.cover;
                  // wasPlaying is null until fullscreen or PiP has observed
                  // playback. Until then, honor the configured autoPlay flag.
                  final shouldAutoPlay = fullscreenManager.isInPip ||
                      (fullscreenManager.wasPlaying ??
                          config.playback.autoPlay);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: (isCover ||
                                (!constraints.maxWidth.isFinite &&
                                    !constraints.maxHeight.isFinite))
                            ? SizedBox.expand(
                                child: IgnorePointer(
                                  ignoring: inNativePip,
                                  child: YouTubeWebViewPlayer(
                                    key: desktopWebViewKey,
                                    videoId: videoId,
                                    config: config,
                                    startAt: fullscreenManager
                                        .currentPositionSeconds,
                                    autoPlay: shouldAutoPlay,
                                    onPositionUpdate: onPositionUpdate,
                                    onPlayingStateChanged:
                                        onPlayingStateChanged,
                                    onReady: onReady,
                                    onEnded: onEnded,
                                    onEnterFullscreen: onOpenFullscreen,
                                    onExitFullscreen:
                                        fullscreenManager.closeFullscreen,
                                    onSeekForward: () =>
                                        onTriggerSeekFeedback(1),
                                    onSeekBackward: () =>
                                        onTriggerSeekFeedback(-1),
                                    onToggleFullscreen: onToggleFullscreen,
                                    onOpenPip: onOpenPip,
                                    onTouchActivity: onMouseActivity,
                                    onControlsVisibilityChanged:
                                        onControlsVisibilityChanged,
                                  ),
                                ),
                              )
                            : AspectRatio(
                                aspectRatio: targetAspect,
                                child: IgnorePointer(
                                  ignoring: inNativePip,
                                  child: YouTubeWebViewPlayer(
                                    key: desktopWebViewKey,
                                    videoId: videoId,
                                    config: config,
                                    startAt: fullscreenManager
                                        .currentPositionSeconds,
                                    autoPlay: shouldAutoPlay,
                                    onPositionUpdate: onPositionUpdate,
                                    onPlayingStateChanged:
                                        onPlayingStateChanged,
                                    onReady: onReady,
                                    onEnded: onEnded,
                                    onEnterFullscreen: onOpenFullscreen,
                                    onExitFullscreen:
                                        fullscreenManager.closeFullscreen,
                                    onSeekForward: () =>
                                        onTriggerSeekFeedback(1),
                                    onSeekBackward: () =>
                                        onTriggerSeekFeedback(-1),
                                    onToggleFullscreen: onToggleFullscreen,
                                    onOpenPip: onOpenPip,
                                    onTouchActivity: onMouseActivity,
                                    onControlsVisibilityChanged:
                                        onControlsVisibilityChanged,
                                  ),
                                ),
                              ),
                      ),
                      AdaptiveSeekFeedbackOverlay(
                        seekDirection: seekDirection,
                        seekSeconds: seekSeconds,
                        styling: config.style,
                        fallbackColor: const Color(0x6C000000),
                      ),
                      if (isLive || viewerCount != null || liveBadgeBuilder != null)
                        PositionedDirectional(
                          top: 12,
                          start: 12,
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
                                iconColor: config.style.iconColor,
                                textColor: config.style.textColor,
                              ),
                        ),
                      if (inNativePip && !isMobile)
                        Positioned.fill(
                          child: PipPlaybackChrome(
                            isPlaying: isPlaying,
                            progress: pipProgress,
                            textDirection: config.text.resolveTextDirection(context),
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
                            onDragUpdate: (details) => moveDesktopPipWindow(
                              details.delta.dx.round(),
                              details.delta.dy.round(),
                            ),
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
