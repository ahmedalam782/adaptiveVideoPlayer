import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    hide FullscreenButton;

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

                // Play and skip buttons in one row, above the progress bar
                if (!isBuffering &&
                    widget.config.style.bottomBarLayout !=
                        BottomBarLayout.inline &&
                    (widget.config.visibility.showCenterPlayPause ||
                        (!widget.isLive &&
                            widget.config.visibility.showSkipButtons)))
                  Positioned.fill(
                    child: Align(
                      alignment: const Alignment(0, -0.28),
                      child: AnimatedOpacity(
                        opacity: _isVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: IgnorePointer(
                          ignoring: !_isVisible,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!widget.isLive &&
                                  widget.config.visibility.showSkipButtons)
                                SeekButton(
                                  icon: Icons.replay_10_rounded,
                                  onTap: widget.onSeekBackward,
                                ),
                              if (!widget.isLive &&
                                  widget.config.visibility.showSkipButtons &&
                                  widget.config.visibility.showCenterPlayPause)
                                const SizedBox(width: 22),
                              if (widget.config.visibility.showCenterPlayPause)
                                GestureDetector(
                                  onTap: () {
                                    if (isPlaying) {
                                      widget.controller.pauseVideo();
                                    } else {
                                      widget.controller.playVideo();
                                    }
                                    _resetTimer();
                                  },
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: widget.config.style.centerButtonColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x2E000000),
                                          blurRadius: 10,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: PlayerIcon.resolve(
                                      context,
                                      icon: isPlaying
                                          ? widget.config.style.icons.pauseIcon
                                          : widget.config.style.icons.playIcon,
                                      fallbackIcon: isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      defaultColor:
                                          widget.config.style.centerIconColor,
                                      defaultSize: 32,
                                    ),
                                  ),
                                ),
                              if (!widget.isLive &&
                                  widget.config.visibility.showSkipButtons &&
                                  widget.config.visibility.showCenterPlayPause)
                                const SizedBox(width: 22),
                              if (!widget.isLive &&
                                  widget.config.visibility.showSkipButtons)
                                SeekButton(
                                  icon: Icons.forward_10_rounded,
                                  onTap: widget.onSeekForward,
                                ),
                            ],
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
                      child: SafeArea(
                        top: false,
                        bottom: widget.isFullscreen,
                        left: widget.isFullscreen,
                        right: widget.isFullscreen,
                        child: widget.config.style.bottomBarLayout ==
                                BottomBarLayout.inline
                            ? _buildInlineBottomBar(context, value)
                            : Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.transparent, Colors.black87],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (!widget.isLive)
                                      _YouTubeTimeEndIcons(
                                        controller: widget.controller,
                                        config: widget.config,
                                        isFullscreen: widget.isFullscreen,
                                        onFullscreenTap: widget.onFullscreenTap,
                                        onPipTap: widget.onPipTap,
                                      ),
                                    // Progress Bar on top across full width
                                    if (!widget.isLive &&
                                        widget
                                            .config.visibility.showProgressBar)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 2,
                                        ),
                                        child: Row(
                                          children: [
                                            ProgressBar(
                                              controller: widget.controller,
                                              playedColor: widget.config.style
                                                  .progressBarPlayedColor,
                                              handleColor: widget.config.style
                                                  .progressBarHandleColor,
                                              backgroundColor: widget
                                                      .config
                                                      .style
                                                      .progressBarBackgroundColor ??
                                                  Colors.white
                                                      .withValues(alpha: 0.24),
                                              thumbRadius: widget.config.style
                                                  .progressBarThumbRadius,
                                              trackHeight: widget.config.style
                                                  .progressBarTrackHeight,
                                              thumbShape: widget.config.style
                                                  .progressBarThumbShape,
                                            ),
                                          ],
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        children:
                                            PlayerBottomActionsBuilder.build(
                                          controller: widget.controller,
                                          config: PlayerBottomActionsConfig(
                                            progressBarPlayedColor: widget
                                                .config
                                                .style
                                                .progressBarPlayedColor,
                                            progressBarHandleColor: widget
                                                .config
                                                .style
                                                .progressBarHandleColor,
                                            progressBarBackgroundColor: widget
                                                .config
                                                .style
                                                .progressBarBackgroundColor,
                                            iconColor:
                                                widget.config.style.iconColor,
                                            textColor:
                                                widget.config.style.textColor,
                                            timeTextStyle: widget
                                                .config.style.timeTextStyle,
                                            icons: widget.config.style.icons,
                                            progressBarThumbRadius: widget
                                                .config
                                                .style
                                                .progressBarThumbRadius,
                                            progressBarTrackHeight: widget
                                                .config
                                                .style
                                                .progressBarTrackHeight,
                                            progressBarThumbShape: widget.config
                                                .style.progressBarThumbShape,
                                          ),
                                          isMuted: widget.isMuted,
                                          isFullscreen: widget.isFullscreen,
                                          showSettingsButton: widget.config
                                              .visibility.showSettingsButton,
                                          showVolumeButton: widget.config
                                              .visibility.showVolumeButton,
                                          showTimeDisplay: widget.isLive &&
                                              widget.config.visibility
                                                  .showTimeDisplay,
                                          showProgressBar: false,
                                          showMiniPlayerButton: widget.isLive &&
                                              widget.config.visibility
                                                  .showMiniPlayerButton,
                                          showFullscreenButton: widget.isLive &&
                                              widget.config.visibility
                                                  .showFullscreenButton,
                                          messages: widget.config.text,
                                          onFullscreenTap:
                                              widget.onFullscreenTap,
                                          onMuteTap: widget.onMuteTap,
                                          onSettingsTap: widget.onSettingsTap,
                                          onPipTap: widget.onPipTap,
                                          isLive: widget.isLive,
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
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    final hours = safe.inHours;
    final minutes = safe.inMinutes.remainder(60);
    final seconds = safe.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildInlineBottomBar(BuildContext context, YoutubePlayerValue value) {
    final style = widget.config.style;
    final visibility = widget.config.visibility;
    final isPlaying = value.playerState == PlayerState.playing;

    final playedColor = style.progressBarPlayedColor;
    final handleColor = style.progressBarHandleColor;
    final containerColor =
        style.controlsBackgroundColor ?? const Color(0xFF1B313F);
    final iconColor = style.iconColor;
    final textColor = style.textColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 500;
        final showVolume = visibility.showVolumeButton;
        final showTime = visibility.showTimeDisplay && !widget.isLive;
        final showFullscreen = visibility.showFullscreenButton;
        final showSettings =
            visibility.showSettingsButton && widget.onSettingsTap != null;
        final showMini = !widget.isFullscreen &&
            !widget.isLive &&
            visibility.showMiniPlayerButton &&
            widget.onPipTap != null;
        final isUltraCompact = constraints.maxWidth < 320;
        final showProgressBar = visibility.showProgressBar && !widget.isLive;

        final dynamicHeight =
            style.bottomBarHeight ?? (isCompact ? 42.0 : 46.0);
        final dynamicMargin = style.bottomBarMargin ??
            EdgeInsets.fromLTRB(
              isCompact ? 10.0 : 16.0,
              0.0,
              isCompact ? 10.0 : 16.0,
              isCompact ? 8.0 : 14.0,
            );
        final dynamicPadding = style.bottomBarPadding ??
            EdgeInsets.symmetric(
              horizontal: isCompact ? 10.0 : 14.0,
              vertical: 2.0,
            );
        final dynamicRadius =
            style.bottomBarBorderRadius ?? BorderRadius.circular(16);

        return Padding(
          padding: dynamicMargin,
          child: Container(
            height: dynamicHeight,
            padding: dynamicPadding,
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: dynamicRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // 1. Play / Pause Button
                Tooltip(
                  message: isPlaying
                      ? (widget.config.text.pauseText)
                      : (widget.config.text.playText),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        if (isPlaying) {
                          widget.controller.pauseVideo();
                        } else {
                          widget.controller.playVideo();
                        }
                        _resetTimer();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: PlayerIcon.resolve(
                          context,
                          icon: isPlaying
                              ? style.icons.pauseIcon
                              : style.icons.playIcon,
                          fallbackIcon: isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          defaultColor: iconColor,
                          defaultSize: 22,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                // 2. Timestamp (00:00 / 04:32)
                if (showTime) ...[
                  StreamBuilder<YoutubeVideoState>(
                    stream: widget.controller.videoStateStream,
                    initialData: const YoutubeVideoState(),
                    builder: (context, snapshot) {
                      final pos = snapshot.data?.position ?? Duration.zero;
                      final dur = widget.controller.metadata.duration;
                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isUltraCompact
                              ? _formatDuration(pos)
                              : '${_formatDuration(pos)} / ${_formatDuration(dur)}',
                          style: style.timeTextStyle ??
                              TextStyle(
                                color: textColor.withValues(alpha: 0.85),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: isCompact ? 4 : 6),
                ],

                // 3. Inline Progress Slider
                if (showProgressBar)
                  ProgressBar(
                    controller: widget.controller,
                    playedColor: playedColor,
                    handleColor: handleColor,
                    backgroundColor: style.progressBarBackgroundColor ??
                        Colors.white.withValues(alpha: 0.24),
                    thumbRadius: style.progressBarThumbRadius,
                    trackHeight: style.progressBarTrackHeight,
                    thumbShape: style.progressBarThumbShape,
                  )
                else
                  const Spacer(),

                // 4. Volume Button
                if (showVolume) ...[
                  const SizedBox(width: 4),
                  MuteButton(
                    onTap: widget.onMuteTap,
                    iconColor: iconColor,
                    isMuted: widget.isMuted,
                    icons: style.icons,
                    tooltip: widget.isMuted
                        ? widget.config.text.unmuteAudioText
                        : widget.config.text.muteAudioText,
                  ),
                ],

                // 5. Settings Button
                if (showSettings) ...[
                  const SizedBox(width: 4),
                  SettingsButton(
                    onTap: widget.onSettingsTap!,
                    iconColor: iconColor,
                    icons: style.icons,
                    tooltip: widget.config.text.playerSettingsText,
                  ),
                ],

                // 6. MiniPlayer Button
                if (showMini) ...[
                  const SizedBox(width: 4),
                  Tooltip(
                    message: widget.config.text.miniPlayerText,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: widget.onPipTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: PlayerIcon.resolve(
                            context,
                            icon: style.icons.miniPlayerIcon,
                            fallbackIcon: Icons.picture_in_picture_alt_rounded,
                            defaultColor: iconColor,
                            defaultSize: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                // 7. Fullscreen Button
                if (showFullscreen) ...[
                  const SizedBox(width: 4),
                  FullscreenButton(
                    onTap: widget.onFullscreenTap,
                    iconColor: iconColor,
                    isFullscreen: widget.isFullscreen,
                    icons: style.icons,
                    tooltip: widget.isFullscreen
                        ? widget.config.text.exitFullscreenText
                        : widget.config.text.fullscreenText,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _YouTubeTimeEndIcons extends StatelessWidget {
  final YoutubePlayerController controller;
  final YouTubePlayerConfig config;
  final bool isFullscreen;
  final VoidCallback onFullscreenTap;
  final VoidCallback? onPipTap;

  const _YouTubeTimeEndIcons({
    required this.controller,
    required this.config,
    required this.isFullscreen,
    required this.onFullscreenTap,
    this.onPipTap,
  });

  String _clock(Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    final hours = safe.inHours;
    final minutes = safe.inMinutes.remainder(60);
    final seconds = safe.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final visibility = config.visibility;
    final showTime = visibility.showTimeDisplay;
    final showFullscreen = visibility.showFullscreenButton;
    final showMini = !isFullscreen &&
        visibility.showMiniPlayerButton &&
        onPipTap != null;
    if (!showTime && !showFullscreen && !showMini) {
      return const SizedBox.shrink();
    }

    final iconColor = config.style.iconColor;
    final textColor = config.style.textColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
      child: Row(
        children: [
          if (showTime)
            StreamBuilder<YoutubeVideoState>(
              stream: controller.videoStateStream,
              initialData: const YoutubeVideoState(),
              builder: (context, snapshot) {
                final position = snapshot.data?.position ?? Duration.zero;
                final duration = controller.metadata.duration;
                return Text(
                  '${_clock(position)} / ${_clock(duration)}',
                  style: config.style.timeTextStyle ??
                      TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                );
              },
            ),
          const Spacer(),
          if (showMini)
            Tooltip(
              message: config.text.miniPlayerText,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onPipTap,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: PlayerIcon.resolve(
                    context,
                    icon: config.style.icons.miniPlayerIcon,
                    fallbackIcon: Icons.picture_in_picture_alt_rounded,
                    defaultColor: iconColor,
                    defaultSize: 22,
                  ),
                ),
              ),
            ),
          if (showFullscreen)
            FullscreenButton(
              onTap: onFullscreenTap,
              iconColor: iconColor,
              isFullscreen: isFullscreen,
              icons: config.style.icons,
              tooltip: isFullscreen
                  ? config.text.exitFullscreenText
                  : config.text.fullscreenText,
            ),
        ],
      ),
    );
  }
}
