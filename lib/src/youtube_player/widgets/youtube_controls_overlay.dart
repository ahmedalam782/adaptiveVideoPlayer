import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'player_controls.dart';
import 'player_bottom_actions.dart';
import '../models/youtube_player_config.dart';

/// A custom YouTube controls overlay for version 10.x.x
class CustomYoutubeControls extends StatefulWidget {
  final YoutubePlayerController controller;
  final YouTubePlayerConfig config;
  final bool isLive;
  final bool isMuted;
  final bool isFullscreen;
  final VoidCallback onFullscreenTap;
  final VoidCallback onMuteTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onPipTap;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;
  final Widget? topActions;

  const CustomYoutubeControls({
    super.key,
    required this.controller,
    required this.config,
    this.isLive = false,
    required this.isMuted,
    this.isFullscreen = false,
    required this.onFullscreenTap,
    required this.onMuteTap,
    this.onSettingsTap,
    this.onPipTap,
    required this.onSeekBackward,
    required this.onSeekForward,
    this.topActions,
  });

  @override
  State<CustomYoutubeControls> createState() => _CustomYoutubeControlsState();
}

class _CustomYoutubeControlsState extends State<CustomYoutubeControls> {
  bool _isVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _resetTimer() {
    _hideTimer?.cancel();
    if (_isVisible) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isVisible = false;
          });
        }
      });
    }
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
    _resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubeValueBuilder(
      controller: widget.controller,
      builder: (context, value) {
        final isBuffering = value.playerState == PlayerState.buffering;
        final isPlaying = value.playerState == PlayerState.playing;

        // Reset timer if we are playing and controls are visible
        if (isPlaying &&
            _isVisible &&
            (_hideTimer == null || !_hideTimer!.isActive)) {
          _resetTimer();
        }
        // Cancel timer if we are paused or buffering so controls stay visible
        if (!isPlaying || isBuffering) {
          _hideTimer?.cancel();
        }

        return Directionality(
          textDirection: widget.config.text.resolveTextDirection(context),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleVisibility,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background fade when controls are visible
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: _isVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: IgnorePointer(
                      ignoring: !_isVisible,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),

                // Buffering indicator (always visible when buffering)
                if (isBuffering)
                  Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: widget.config.style.loadingIndicatorColor,
                      ),
                    ),
                  ),

                // Center play/pause (only when not buffering)
                if (!isBuffering)
                  Positioned.fill(
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _isVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: IgnorePointer(
                          ignoring: !_isVisible,
                          child: GestureDetector(
                            onTap: () {
                              if (isPlaying) {
                                widget.controller.pauseVideo();
                              } else {
                                widget.controller.playVideo();
                              }
                              _resetTimer();
                            },
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: widget.config.style.iconColor,
                                  size: 36,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Seek buttons overlay (always in the center, ignored if controls not visible)
                if (!isBuffering && !widget.isLive)
                  Positioned.fill(
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _isVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: IgnorePointer(
                          ignoring: !_isVisible,
                          child: SeekButtonsOverlay(
                            onSeekBackward: widget.onSeekBackward,
                            onSeekForward: widget.onSeekForward,
                          ),
                        ),
                      ),
                    ),
                  ),

              // Top Actions
              if (widget.topActions != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity: _isVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: IgnorePointer(
                      ignoring: !_isVisible,
                      child: widget.topActions!,
                    ),
                  ),
                ),

              // Bottom Actions
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _isVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: !_isVisible,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black87],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        bottom: widget.isFullscreen,
                        left: widget.isFullscreen,
                        right: widget.isFullscreen,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                        children: PlayerBottomActionsBuilder.build(
                          controller: widget.controller,
                          config: PlayerBottomActionsConfig(
                            progressBarPlayedColor:
                                widget.config.style.progressBarPlayedColor,
                            progressBarHandleColor:
                                widget.config.style.progressBarHandleColor,
                            iconColor: widget.config.style.iconColor,
                            textColor: widget.config.style.textColor,
                            timeTextStyle: widget.config.style.timeTextStyle,
                          ),
                          isMuted: widget.isMuted,
                          isFullscreen: widget.isFullscreen,
                          showFullscreenButton:
                              widget.config.visibility.showFullscreenButton,
                          showSettingsButton:
                              widget.config.visibility.showSettingsButton,
                          showVolumeButton:
                              widget.config.visibility.showVolumeButton,
                          showTimeDisplay:
                              widget.config.visibility.showTimeDisplay,
                          showProgressBar:
                              widget.config.visibility.showProgressBar,
                          showMiniPlayerButton:
                              widget.config.visibility.showMiniPlayerButton,
                          messages: widget.config.text,
                          onFullscreenTap: widget.onFullscreenTap,
                          onMuteTap: widget.onMuteTap,
                          onSettingsTap: widget.onSettingsTap,
                          onPipTap: widget.onPipTap,
                          isLive: widget.isLive,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
    },
    );
  }
}
