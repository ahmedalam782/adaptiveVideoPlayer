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
    );
  }

  Widget _buildPlayerWithOverlay() {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (widget.fullscreenManager.isInFullscreen) {
            widget.fullscreenManager.closeFullscreen();
          }
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _seekBy(10),
        const SingleActivator(LogicalKeyboardKey.keyL): () => _seekBy(10),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _seekBy(-10),
        const SingleActivator(LogicalKeyboardKey.keyJ): () => _seekBy(-10),
        const SingleActivator(LogicalKeyboardKey.space): _togglePlayPause,
        const SingleActivator(LogicalKeyboardKey.keyK): _togglePlayPause,
        const SingleActivator(LogicalKeyboardKey.keyF): _toggleFullscreen,
        const SingleActivator(LogicalKeyboardKey.keyM): _toggleMute,
      },
      child: Focus(
        autofocus: true,
        child: Stack(
          alignment: Alignment.center,
          children: [
            YouTubeWebViewPlayer(
              key: widget.desktopWebViewKey,
              videoId: widget.videoId,
              config: widget.config,
              onPositionUpdate: (pos) {
                widget.fullscreenManager.currentPositionSeconds = pos;
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _seekResetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fullscreenManager.isInFullscreen) {
      return const SizedBox.shrink();
    }

    return _buildPlayerWithOverlay();
  }
}
