import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../normal_video_player/widgets/adaptive_seek_feedback_overlay.dart';
import '../models/youtube_player_config.dart';
import '../widgets/youtube_desktop_overlay.dart';
import '../widgets/youtube_webview_player_export.dart';

/// Renders the desktop YouTube player view with webview, keyboard shortcuts, and animated seek overlay (+10, +20, +30).
class YouTubeDesktopPlayerView extends StatefulWidget {
  final GlobalKey<YouTubeWebViewPlayerState> desktopWebViewKey;
  final String videoId;
  final YouTubePlayerConfig config;
  final YouTubeDesktopFullscreenManager fullscreenManager;
  final VoidCallback onReady;
  final VoidCallback? onEnded;

  const YouTubeDesktopPlayerView({
    super.key,
    required this.desktopWebViewKey,
    required this.videoId,
    required this.config,
    required this.fullscreenManager,
    required this.onReady,
    this.onEnded,
  });

  @override
  State<YouTubeDesktopPlayerView> createState() =>
      _YouTubeDesktopPlayerViewState();
}

class _YouTubeDesktopPlayerViewState extends State<YouTubeDesktopPlayerView> {
  int _seekDirection = 0;
  int _seekSeconds = 10;
  Timer? _seekResetTimer;
  Timer? _controlsHideTimer;
  bool _isHovered = true;
  bool _isPlaying = false;

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
    if (_isPlaying) {
      _controlsHideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _isPlaying) {
          setState(() {
            _isHovered = false;
          });
        }
      });
    }
  }

  void _triggerSeekFeedback(int direction) {
    if (!mounted) return;
    _seekResetTimer?.cancel();
    setState(() {
      if (_seekDirection == direction) {
        _seekSeconds += 10;
      } else {
        _seekDirection = direction;
        _seekSeconds = 10;
      }
    });
    _seekResetTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _seekDirection = 0;
          _seekSeconds = 10;
        });
      }
    });
  }

  void _seekBy(int offsetSeconds) async {
    final state = widget.desktopWebViewKey.currentState;
    if (state != null) {
      final cur = await state.getCurrentTime() ?? state.currentPosition;
      final target = (cur + offsetSeconds).clamp(0, 999999);
      state.seekTo(target);
      _triggerSeekFeedback(offsetSeconds > 0 ? 1 : -1);
    }
  }

  void _togglePlayPause() async {
    final state = widget.desktopWebViewKey.currentState;
    if (state != null) {
      final isPlaying = await state.isPlaying();
      if (isPlaying) {
        state.pause();
      } else {
        state.play();
      }
    }
  }

  void _toggleMute() {
    final state = widget.desktopWebViewKey.currentState;
    state?.mute();
  }

  void _toggleFullscreen() {
    if (widget.fullscreenManager.isInFullscreen) {
      widget.fullscreenManager.closeFullscreen();
    } else {
      _openFullscreen();
    }
  }

  void _openFullscreen() {
    widget.fullscreenManager.openFullscreen(
      desktopPlayerBuilder: _buildPlayerWithOverlay,
      textDirection: widget.config.text.resolveTextDirection(context),
    );
  }

  void _togglePip() {
    if (widget.fullscreenManager.isInPip) {
      widget.fullscreenManager.closePip(pauseOnClose: false);
    } else {
      _openPip();
    }
  }

  void _openPip() {
    widget.fullscreenManager.openPip(
      desktopPlayerBuilder: _buildPlayerWithOverlay,
      getExpandTooltip: () => widget.config.text.expandPlayerText,
      getCloseTooltip: () => widget.config.text.closeMiniPlayerText,
      textDirection: widget.config.text.resolveTextDirection(context),
    );
  }

  Widget _buildPlayerWithOverlay() {
    final isNormalInline = !widget.fullscreenManager.isInFullscreen &&
        !widget.fullscreenManager.isInPip;
    final showPipButton = _isHovered || !_isPlaying;
    final showMini = isNormalInline &&
        widget.config.visibility.showControls &&
        widget.config.visibility.showMiniPlayerButton;
    final showFullscreen = !widget.fullscreenManager.isInPip &&
        widget.config.visibility.showControls &&
        widget.config.visibility.showFullscreenButton;
    final effectiveDir = mounted
        ? widget.config.text.resolveTextDirection(context)
        : (widget.config.text.textDirection ?? TextDirection.ltr);
    final isRtl = effectiveDir == TextDirection.rtl;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (widget.fullscreenManager.isInFullscreen) {
            widget.fullscreenManager.closeFullscreen();
          } else if (widget.fullscreenManager.isInPip) {
            widget.fullscreenManager.closePip(pauseOnClose: false);
          }
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _seekBy(10),
        const SingleActivator(LogicalKeyboardKey.keyL): () => _seekBy(10),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _seekBy(-10),
        const SingleActivator(LogicalKeyboardKey.keyJ): () => _seekBy(-10),
        const SingleActivator(LogicalKeyboardKey.space): _togglePlayPause,
        const SingleActivator(LogicalKeyboardKey.keyK): _togglePlayPause,
        const SingleActivator(LogicalKeyboardKey.keyF): _toggleFullscreen,
        const SingleActivator(LogicalKeyboardKey.keyI): _togglePip,
        const SingleActivator(LogicalKeyboardKey.keyM): _toggleMute,
      },
      child: Focus(
        autofocus: true,
        child: Directionality(
          textDirection: effectiveDir,
          child: MouseRegion(
            onEnter: (_) => _onMouseActivity(),
            onHover: (_) => _onMouseActivity(),
            onExit: (_) {
              if (_isPlaying && mounted) {
                setState(() {
                  _isHovered = false;
                });
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                YouTubeWebViewPlayer(
                  key: widget.desktopWebViewKey,
                  videoId: widget.videoId,
                  config: widget.config,
                  startAt: widget.fullscreenManager.currentPositionSeconds,
                  autoPlay: widget.fullscreenManager.wasPlaying,
                  onPositionUpdate: (pos) {
                    widget.fullscreenManager.currentPositionSeconds = pos;
                  },
                  onPlayingStateChanged: (playing) {
                    if (!mounted) return;
                    setState(() {
                      _isPlaying = playing;
                      if (!playing) {
                        _isHovered = true;
                      }
                    });
                    if (playing) {
                      _scheduleHideControls();
                    } else {
                      _controlsHideTimer?.cancel();
                    }
                  },
                  onReady: widget.onReady,
                  onEnded: widget.onEnded,
                  onEnterFullscreen: _openFullscreen,
                  onExitFullscreen: widget.fullscreenManager.closeFullscreen,
                  onSeekForward: () => _triggerSeekFeedback(1),
                  onSeekBackward: () => _triggerSeekFeedback(-1),
                  onToggleFullscreen: _toggleFullscreen,
                ),
                AdaptiveSeekFeedbackOverlay(
                  seekDirection: _seekDirection,
                  seekSeconds: _seekSeconds,
                ),
                if (showMini || showFullscreen)
                  Positioned(
                    top: 14,
                    left: isRtl ? 14 : null,
                    right: isRtl ? null : 14,
                    child: AnimatedOpacity(
                      opacity: showPipButton ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      child: IgnorePointer(
                        ignoring: !showPipButton,
                        child: Directionality(
                          textDirection: effectiveDir,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (showMini)
                                  Tooltip(
                                    message: widget.config.text.miniPlayerText,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _openPip,
                                        customBorder: const CircleBorder(),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(
                                            Icons.picture_in_picture_alt_rounded,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (showMini && showFullscreen)
                                  const SizedBox(width: 8),
                                if (showFullscreen)
                                  Tooltip(
                                    message: widget.fullscreenManager.isInFullscreen
                                        ? widget.config.text.exitFullscreenText
                                        : widget.config.text.fullscreenText,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _toggleFullscreen,
                                        customBorder: const CircleBorder(),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Icon(
                                            widget.fullscreenManager.isInFullscreen
                                                ? Icons.fullscreen_exit_rounded
                                                : Icons.fullscreen_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _seekResetTimer?.cancel();
    _controlsHideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fullscreenManager.isInFullscreen) {
      return const SizedBox.shrink();
    }

    if (widget.fullscreenManager.isInPip) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.fullscreenManager.closePip(pauseOnClose: false),
        child: Material(
          color: Colors.black87,
          child: InkWell(
            onTap: () => widget.fullscreenManager.closePip(pauseOnClose: false),
            hoverColor: Colors.white.withValues(alpha: 0.05),
            splashColor: Colors.white.withValues(alpha: 0.1),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.picture_in_picture_alt_rounded,
                    color: Colors.white54,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () =>
                        widget.fullscreenManager.closePip(pauseOnClose: false),
                    icon: const Icon(
                      Icons.open_in_full_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    label: Text(
                      widget.config.text.restorePlayerText,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return _buildPlayerWithOverlay();
  }
}
