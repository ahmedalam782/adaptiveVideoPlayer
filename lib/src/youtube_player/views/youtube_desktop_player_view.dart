import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/native_pip_service.dart';
import '../../normal_video_player/widgets/adaptive_seek_feedback_overlay.dart';
import '../../normal_video_player/widgets/pip_playback_chrome.dart';
import '../models/youtube_player_config.dart';
import '../widgets/youtube_desktop_overlay.dart';
import '../widgets/youtube_webview_player_export.dart';

/// Renders the desktop YouTube player view with webview, keyboard shortcuts, and animated seek overlay (+10, +20, +30).
class YouTubeDesktopPlayerView extends StatefulWidget {
  final GlobalKey<YouTubeWebViewPlayerState> desktopWebViewKey;
  final String videoId;
  final YouTubePlayerConfig config;
  final YouTubeDesktopFullscreenManager fullscreenManager;
  final double? aspectRatio;
  final VoidCallback onReady;
  final VoidCallback? onEnded;

  const YouTubeDesktopPlayerView({
    super.key,
    required this.desktopWebViewKey,
    required this.videoId,
    required this.config,
    required this.fullscreenManager,
    this.aspectRatio,
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
  int _positionSeconds = 0;
  int _durationSeconds = 0;

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

  void _onControlsVisibilityChanged(bool visible) {
    if (!mounted) return;
    _controlsHideTimer?.cancel();
    if (_isHovered != visible) {
      setState(() {
        _isHovered = visible;
      });
    }
    if (visible) {
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
      _controlsHideTimer = Timer(const Duration(milliseconds: 2600), () {
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

  double get _pipProgress {
    if (_durationSeconds <= 0) return 0;
    return (_positionSeconds / _durationSeconds).clamp(0.0, 1.0);
  }

  void _rememberPlayback(int positionSeconds, int durationSeconds) {
    final duration = durationSeconds > 0 ? durationSeconds : _durationSeconds;
    final changed =
        positionSeconds != _positionSeconds || duration != _durationSeconds;
    _positionSeconds = positionSeconds;
    if (duration > 0) _durationSeconds = duration;
    if (changed && mounted) setState(() {});
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
    if (widget.fullscreenManager.isInFullscreen) {
      widget.fullscreenManager.closeFullscreen();
    }
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
      isPlaying: () => _isPlaying,
      progress: () => _pipProgress,
      onPlayPause: _togglePlayPause,
      onSeekBackward: () => _seekBy(-10),
      onSeekForward: () => _seekBy(10),
    );
  }

  Widget _buildPlayerWithOverlay() {
    final inNativePip = NativePipService.isInPip.value;
    final showPipButton = !inNativePip && (_isHovered || !_isPlaying);
    final showMini = !widget.fullscreenManager.isInPip &&
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
                _scheduleHideControls();
              }
            },
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => _onMouseActivity(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final targetAspect = widget.aspectRatio ?? (16.0 / 9.0);
                  double letterboxBottom = 0.0;
                  double pillarboxSide = 0.0;

                  final isCover = widget.config.style.videoFit == BoxFit.cover;

                  if (!isCover &&
                      constraints.maxWidth.isFinite &&
                      constraints.maxHeight.isFinite &&
                      constraints.maxWidth > 0 &&
                      constraints.maxHeight > 0) {
                    final currentAspect =
                        constraints.maxWidth / constraints.maxHeight;
                    if (currentAspect < targetAspect) {
                      // Taller than video aspect ratio -> vertical letterboxing (black bars top & bottom)
                      final videoHeight = constraints.maxWidth / targetAspect;
                      letterboxBottom =
                          (constraints.maxHeight - videoHeight) / 2.0;
                    } else if (currentAspect > targetAspect) {
                      // Wider than video aspect ratio -> horizontal pillarboxing (black bars left & right)
                      final videoWidth = constraints.maxHeight * targetAspect;
                      pillarboxSide =
                          (constraints.maxWidth - videoWidth) / 2.0;
                    }
                  }

                  final baseBottom = widget.config.style.bottomBarMargin != null &&
                          widget.config.style.bottomBarMargin is EdgeInsets
                      ? (widget.config.style.bottomBarMargin as EdgeInsets).bottom
                      : (widget.fullscreenManager.isInFullscreen ? 85.0 : 85.0);

                  final responsiveBottom = letterboxBottom + baseBottom;
                  final responsiveRight = pillarboxSide + 6.0;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                  IgnorePointer(
                    ignoring: inNativePip,
                    child: YouTubeWebViewPlayer(
                      key: widget.desktopWebViewKey,
                      videoId: widget.videoId,
                      config: widget.config,
                      startAt: widget.fullscreenManager.currentPositionSeconds,
                      autoPlay: widget.fullscreenManager.wasPlaying,
                      onPositionUpdate: (pos, dur) {
                        widget.fullscreenManager.currentPositionSeconds = pos;
                        _rememberPlayback(pos, dur);
                        if (widget.fullscreenManager.isInPip) {
                          widget.fullscreenManager.markOverlaysNeedBuild();
                        }
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
                      onExitFullscreen:
                          widget.fullscreenManager.closeFullscreen,
                      onSeekForward: () => _triggerSeekFeedback(1),
                      onSeekBackward: () => _triggerSeekFeedback(-1),
                      onToggleFullscreen: _toggleFullscreen,
                      onTouchActivity: _onMouseActivity,
                      onControlsVisibilityChanged:
                          _onControlsVisibilityChanged,
                    ),
                  ),
                  AdaptiveSeekFeedbackOverlay(
                    seekDirection: _seekDirection,
                    seekSeconds: _seekSeconds,
                    styling: widget.config.style,
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
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                color: 
                                    const Color(0x6C000000),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (showMini)
                                    _buildYouTubeStyleBtn(
                                      playerIcon: widget
                                          .config.style.icons.miniPlayerIcon,
                                      fallbackIcon:
                                          Icons.picture_in_picture_alt_rounded,
                                      tooltip:
                                          widget.config.text.miniPlayerText,
                                      onTap: _openPip,
                                      size: 19,
                                    ),
                                  if (showFullscreen)
                                    _buildYouTubeStyleBtn(
                                      playerIcon: widget.fullscreenManager
                                              .isInFullscreen
                                          ? widget.config.style.icons
                                              .exitFullscreenIcon
                                          : widget.config.style.icons
                                              .fullscreenIcon,
                                      fallbackIcon: widget.fullscreenManager
                                              .isInFullscreen
                                          ? Icons.fullscreen_exit_rounded
                                          : Icons.fullscreen_rounded,
                                      tooltip: widget.fullscreenManager
                                              .isInFullscreen
                                          ? widget
                                              .config.text.exitFullscreenText
                                          : widget.config.text.fullscreenText,
                                      onTap: _toggleFullscreen,
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
                        isPlaying: _isPlaying,
                        progress: _pipProgress,
                        closeTooltip: widget.config.text.closeMiniPlayerText,
                        expandTooltip: widget.config.text.expandPlayerText,
                        playTooltip: widget.config.text.playText,
                        pauseTooltip: widget.config.text.pauseText,
                        onClose: () {
                          widget.desktopWebViewKey.currentState?.pause();
                          NativePipService.closePip();
                        },
                        onExpand: NativePipService.exitPip,
                        onPlayPause: _togglePlayPause,
                        onSeekBackward: () => _seekBy(-10),
                        onSeekForward: () => _seekBy(10),
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

  Widget _buildYouTubeStyleBtn({
    PlayerIcon? playerIcon,
    IconData? fallbackIcon,
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
          child: SizedBox(
            width: 32,
            height: 32,
            child: Center(
              child: Builder(
                builder: (context) {
                  return PlayerIcon.resolve(
                    context,
                    icon: playerIcon,
                    fallbackIcon: fallbackIcon ?? Icons.circle,
                    defaultColor: Colors.white.withValues(alpha: 0.95),
                    defaultSize: size,
                  );
                },
              ),
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
              onTap: () =>
                  widget.fullscreenManager.closePip(pauseOnClose: false),
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
                      onPressed: () => widget.fullscreenManager
                          .closePip(pauseOnClose: false),
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
