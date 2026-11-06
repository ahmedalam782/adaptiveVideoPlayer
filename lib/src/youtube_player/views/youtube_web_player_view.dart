import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../normal_video_player/utils/fullscreen_utils_export.dart';
import '../models/youtube_player_config.dart';
import '../utils/youtube_web_export.dart';
import '../widgets/youtube_live_badge.dart';
import '../widgets/youtube_web_iframe_view.dart';

/// Renders the Flutter Web YouTube player view with the iframe, live badge,
/// and keyboard shortcuts.
class YouTubeWebPlayerView extends StatefulWidget {
  final String viewId;
  final String videoId;
  final YouTubePlayerConfig config;
  final double? aspectRatio;
  final bool isLive;
  final String? viewerCount;
  final YouTubeLiveBadgeBuilder? liveBadgeBuilder;
  final VoidCallback onOpenPip;
  final VoidCallback onToggleFullscreen;
  final bool isInFullscreen;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onMute;
  final VoidCallback? onUnMute;

  const YouTubeWebPlayerView({
    super.key,
    required this.viewId,
    required this.videoId,
    required this.config,
    this.aspectRatio,
    this.isLive = false,
    this.viewerCount,
    this.liveBadgeBuilder,
    required this.onOpenPip,
    required this.onToggleFullscreen,
    this.isInFullscreen = false,
    this.onPlay,
    this.onPause,
    this.onMute,
    this.onUnMute,
  });

  @override
  State<YouTubeWebPlayerView> createState() => _YouTubeWebPlayerViewState();
}

class _YouTubeWebPlayerViewState extends State<YouTubeWebPlayerView> {
  @override
  void initState() {
    super.initState();
    listenToFullscreenChange((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDir = widget.config.text.resolveTextDirection(context);
    final isFullscreenNow = widget.isInFullscreen || isYoutubeWebFullscreen();
    final showLiveBadge = widget.isLive ||
        widget.viewerCount != null ||
        widget.liveBadgeBuilder != null;

    final targetAspect = widget.aspectRatio ?? (16.0 / 9.0);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (isFullscreenNow) {
            widget.onToggleFullscreen();
          }
        },
        const SingleActivator(LogicalKeyboardKey.keyF):
            widget.onToggleFullscreen,
        const SingleActivator(LogicalKeyboardKey.keyI): widget.onOpenPip,
        const SingleActivator(LogicalKeyboardKey.space): () {
          widget.onPlay?.call();
        },
        const SingleActivator(LogicalKeyboardKey.keyM): () {
          widget.onMute?.call();
        },
      },
      child: Focus(
        autofocus: true,
        child: Directionality(
          textDirection: effectiveDir,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isFullscreenNow ? 0 : 8),
            child: AspectRatio(
              aspectRatio: targetAspect,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  YouTubeWebIframeView(
                    key: ValueKey(widget.viewId),
                    viewId: widget.viewId,
                  ),
                  if (showLiveBadge)
                    PositionedDirectional(
                      top: 12,
                      start: 12,
                      child: (widget.liveBadgeBuilder ??
                                  widget.config.liveBadgeBuilder)
                              ?.call(
                            context,
                            isLive: widget.isLive,
                            viewerCount: widget.viewerCount,
                          ) ??
                          YouTubeLiveBadge(
                            isLive: widget.isLive,
                            viewerCount: widget.viewerCount,
                            liveText: widget.config.text.liveText,
                            iconColor: widget.config.style.iconColor,
                            textColor: widget.config.style.textColor,
                          ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
