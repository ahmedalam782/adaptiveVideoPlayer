import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/native_pip_service.dart';
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

  @override
  void initState() {
    super.initState();
    NativePipService.isInPip.addListener(_onNativePipModeChanged);
    NativePipService.pipAction.addListener(_onPipActionReceived);
  }

  void _onPipActionReceived() {
    if (!mounted) return;
    final action = NativePipService.pipAction.value;
    if (action == 'toggle_play') {
      _togglePlayPause();
    }
  }

  void _onNativePipModeChanged() {
    if (!mounted) return;
    if (NativePipService.isInPip.value && widget.fullscreenManager.isInPip) {
      widget.fullscreenManager.closePip(pauseOnClose: false);
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant YouTubeDesktopPlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fullscreenManager.isInPip &&
        !widget.fullscreenManager.isInPip) {
      _isHovered = true;
      _scheduleHideControls();
    } else if (oldWidget.fullscreenManager.isInFullscreen &&
        !widget.fullscreenManager.isInFullscreen) {
      _isHovered = true;
      _scheduleHideControls();
    }
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

  void _openPip() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final entered = await NativePipService.enterPip();
      if (entered) return;
    }
    if (!mounted) return;
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
    final inNativePip = NativePipService.isInPip.value;
    final showPipButton = !inNativePip && (_isHovered || !_isPlaying);
    final showMini = isNormalInline &&
        !inNativePip &&
        widget.config.visibility.showControls &&
        widget.config.visibility.showMiniPlayerButton;
    final showFullscreen = !widget.fullscreenManager.isInPip &&
        !inNativePip &&
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
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => _onMouseActivity(),
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
                  onTouchActivity: _onMouseActivity,
                ),
                AdaptiveSeekFeedbackOverlay(
                  seekDirection: _seekDirection,
                  seekSeconds: _seekSeconds,
                ),
                if (widget.fullscreenManager.isInFullscreen)
                  Positioned(
                    top: 14,
                    left: isRtl ? null : 14,
                    right: isRtl ? 14 : null,
                    child: AnimatedOpacity(
                      opacity: showPipButton ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      child: IgnorePointer(
                        ignoring: !showPipButton,
                        child: Directionality(
                          textDirection: effectiveDir,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 0.8,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _toggleFullscreen,
                                customBorder: const CircleBorder(),
                                child: const Padding(
                                  padding: EdgeInsets.all(6.0),
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (showMini || showFullscreen)
                  Positioned(
                    right: isRtl ? null : 6,
                    left: isRtl ? 6 : null,
                    bottom: 6,
                    child: IgnorePointer(
                      ignoring: !showPipButton,
                      child: AnimatedOpacity(
                        opacity: showPipButton ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 220),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showMini)
                              _buildYouTubeStyleBtn(
                                icon: Icons.picture_in_picture_alt_rounded,
                                tooltip: widget.config.text.miniPlayerText,
                                onTap: _openPip,
                                size: 20,
                              ),
                            if (showFullscreen)
                              _buildYouTubeStyleBtn(
                                icon: widget.fullscreenManager.isInFullscreen
                                    ? Icons.fullscreen_exit_rounded
                                    : Icons.fullscreen_rounded,
                                tooltip: widget.fullscreenManager.isInFullscreen
                                    ? widget.config.text.exitFullscreenText
                                    : widget.config.text.fullscreenText,
                                onTap: _toggleFullscreen,
                                size: 22,
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
  );
}

  Widget _buildYouTubeStyleBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    double size = 20,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.9),
              size: size,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    NativePipService.isInPip.removeListener(_onNativePipModeChanged);
    NativePipService.pipAction.removeListener(_onPipActionReceived);
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
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          widget.fullscreenManager.closePip(pauseOnClose: false);
        },
        child: GestureDetector(
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
        ),
      );
    }

    return _buildPlayerWithOverlay();
  }
}
