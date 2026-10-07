import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/services/native_pip_service.dart';
import '../models/youtube_player_config.dart';
import '../widgets/youtube_desktop_overlay.dart';
import '../widgets/youtube_desktop_pip_placeholder.dart';
import '../widgets/youtube_webview_player_export.dart';
import 'youtube_desktop_player_with_overlay.dart';

/// Type alias recognizing [YouTubeDesktopPlayerView] as the unified native player for all non-web platforms (Android, iOS, Windows, macOS, Linux).
typedef YouTubeNativePlayerView = YouTubeDesktopPlayerView;

/// Renders the desktop/mobile native YouTube player view with webview, gestures/keyboard shortcuts, and animated seek overlay (+10, +20, +30).
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
      if (_isPlaying) {
        state.pause();
      } else {
        state.play();
        if (!widget.config.playback.mute) {
          state.unMute();
        }
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
    return YouTubeDesktopPlayerWithOverlay(
      desktopWebViewKey: widget.desktopWebViewKey,
      videoId: widget.videoId,
      config: widget.config,
      fullscreenManager: widget.fullscreenManager,
      aspectRatio: widget.aspectRatio,
      isPlaying: _isPlaying,
      isHovered: _isHovered,
      seekDirection: _seekDirection,
      seekSeconds: _seekSeconds,
      pipProgress: _pipProgress,
      onTogglePlayPause: _togglePlayPause,
      onSeekBy: _seekBy,
      onToggleFullscreen: _toggleFullscreen,
      onTogglePip: _togglePip,
      onToggleMute: _toggleMute,
      onOpenFullscreen: _openFullscreen,
      onOpenPip: _openPip,
      onMouseActivity: _onMouseActivity,
      onMouseExit: () {
        if (_isPlaying && mounted) {
          _scheduleHideControls();
        }
      },
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
      onControlsVisibilityChanged: _onControlsVisibilityChanged,
      onReady: widget.onReady,
      onEnded: widget.onEnded,
      onTriggerSeekFeedback: _triggerSeekFeedback,
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
      return YouTubeDesktopPipPlaceholder(
        onRestore: () => widget.fullscreenManager.closePip(pauseOnClose: false),
        restorePlayerText: widget.config.text.restorePlayerText,
      );
    }

    return _buildPlayerWithOverlay();
  }
}
