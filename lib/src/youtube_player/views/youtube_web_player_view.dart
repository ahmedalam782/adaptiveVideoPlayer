import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../normal_video_player/utils/fullscreen_utils_export.dart';
import '../models/youtube_player_config.dart';
import '../utils/youtube_web_export.dart';
import '../widgets/youtube_desktop_style_button.dart';
import '../widgets/youtube_live_badge.dart';
import '../widgets/youtube_web_iframe_view.dart';

/// Renders the Flutter Web YouTube player view with the iframe, live badge,
/// keyboard shortcuts, hover detection, and floating action capsule (PiP and Fullscreen buttons).
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
  bool _isHovered = true;
  Timer? _controlsHideTimer;

  @override
  void initState() {
    super.initState();
    _scheduleHideControls();
    listenToFullscreenChange((_) {
      if (mounted) setState(() {});
    });
  }

  void _onMouseActivity() {
    if (!mounted) return;
    if (!_isHovered) {
      setState(() {
        _isHovered = true;
      });
    }
    _scheduleHideControls();
  }

  void _scheduleHideControls() {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) {
        setState(() {
          _isHovered = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controlsHideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveDir = widget.config.text.resolveTextDirection(context);
    final isFullscreenNow = widget.isInFullscreen || isYoutubeWebFullscreen();
    // In fullscreen mode, show the exit fullscreen button.
    final showFullscreen = widget.config.visibility.showControls &&
        widget.config.visibility.showFullscreenButton &&
        isFullscreenNow;
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
          child: MouseRegion(
            onEnter: (_) => _onMouseActivity(),
            onHover: (_) => _onMouseActivity(),
            onExit: (_) {
              if (mounted) {
                _scheduleHideControls();
              }
            },
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
                    if (showFullscreen)
                      PositionedDirectional(
                        top: 14,
                        end: 14,
                        child: AnimatedOpacity(
                          opacity: _isHovered ? 1.0 : 0.85,
                          duration: const Duration(milliseconds: 220),
                          child: Container(
                            height: 36,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              color: const Color(0xAA000000),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                YouTubeDesktopStyleButton(
                                  playerIcon: widget
                                      .config.style.icons.exitFullscreenIcon,
                                  fallbackIcon: Icons.fullscreen_exit_rounded,
                                  tooltip:
                                      widget.config.text.exitFullscreenText,
                                  onTap: widget.onToggleFullscreen,
                                  size: 21,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
