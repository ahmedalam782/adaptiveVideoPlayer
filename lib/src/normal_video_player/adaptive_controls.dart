import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../youtube_player/models/player_config.dart';
import 'model/video_config.dart';
import 'utils/subtitle_parser.dart';

typedef AdaptiveControlsBuilder = Widget Function(
    BuildContext context, VideoPlayerController controller, bool isFullScreen);

typedef SubtitleBuilder = Widget Function(
    BuildContext context, String subtitleText);

class BaseAdaptiveVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final bool showControls;
  final bool isFullScreen;
  final AdaptiveControlsBuilder? controlsBuilder;
  final SubtitleBuilder? subtitleBuilder;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;
  final List<VideoQuality>? qualities;
  final VideoQuality? currentQuality;
  final void Function(VideoQuality)? onQualitySelected;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final void Function(SubtitleTrack?)? onSubtitleSelected;
  final List<SubtitleItem>? parsedSubtitles;
  final bool isLive;
  final String? viewerCount;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onExitFullscreen;

  const BaseAdaptiveVideoPlayer({
    super.key,
    required this.controller,
    this.showControls = true,
    this.isFullScreen = false,
    this.controlsBuilder,
    this.subtitleBuilder,
    this.styling,
    this.messages,
    this.onAnalyticsEvent,
    this.qualities,
    this.currentQuality,
    this.onQualitySelected,
    this.subtitles,
    this.currentSubtitleTrack,
    this.onSubtitleSelected,
    this.parsedSubtitles,
    this.isLive = false,
    this.viewerCount,
    this.onEnterFullscreen,
    this.onExitFullscreen,
  });

  @override
  State<BaseAdaptiveVideoPlayer> createState() =>
      _BaseAdaptiveVideoPlayerState();
}

class _BaseAdaptiveVideoPlayerState extends State<BaseAdaptiveVideoPlayer> {
  bool _controlsVisible = true;
  int _seekDirection = 0; // -1 for backward, 1 for forward, 0 for none
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();

    // Add listener to fire events
    widget.controller.addListener(_videoListener);
    widget.onAnalyticsEvent?.call('video_initialized',
        {'duration': widget.controller.value.duration.inSeconds});
  }

  bool _videoEndedEventSent = false;
  String _currentSubtitleText = '';

  void _videoListener() {
    final position = widget.controller.value.position;
    final duration = widget.controller.value.duration;

    if (position >= duration && duration.inMilliseconds > 0) {
      if (!_videoEndedEventSent) {
        _videoEndedEventSent = true;
        widget.onAnalyticsEvent?.call('video_ended', {});
      }
    } else {
      _videoEndedEventSent = false;
    }

    _updateSubtitle(position);
  }

  void _updateSubtitle(Duration position) {
    if (widget.parsedSubtitles == null || widget.parsedSubtitles!.isEmpty) {
      if (_currentSubtitleText.isNotEmpty) {
        setState(() => _currentSubtitleText = '');
      }
      return;
    }

    // Binary search or simple iteration
    String newText = '';
    for (final item in widget.parsedSubtitles!) {
      if (position >= item.start && position <= item.end) {
        newText = item.text;
        break;
      }
    }

    if (_currentSubtitleText != newText && mounted) {
      setState(() => _currentSubtitleText = newText);
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
      if (_controlsVisible) {
        _startHideTimer();
      } else {
        _hideTimer?.cancel();
      }
    });
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (widget.isLive) return;

    final width = MediaQuery.of(context).size.width;
    final position = details.globalPosition.dx;
    final currentPosition = widget.controller.value.position;
    final wasPlaying = widget.controller.value.isPlaying;

    setState(() {
      if (position > width / 2) {
        _seekDirection = 1;
        widget.controller.seekTo(currentPosition + const Duration(seconds: 10));
      } else {
        _seekDirection = -1;
        final newPosition = currentPosition - const Duration(seconds: 10);
        widget.controller
            .seekTo(newPosition.isNegative ? Duration.zero : newPosition);
      }
    });

    if (wasPlaying) {
      widget.controller.play();
    }

    _startHideTimer(); // Reset auto-hide timer when double tapped

    // Reset visual feedback after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _seekDirection = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoContent = AspectRatio(
      aspectRatio: widget.controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(widget.controller),

          // Built-in Subtitle/ClosedCaption overlay Layer
          if (widget.subtitleBuilder != null)
            ValueListenableBuilder(
              valueListenable: widget.controller,
              builder: (context, VideoPlayerValue value, child) {
                return widget.subtitleBuilder!(context, value.caption.text);
              },
            ),
        ],
      ),
    );

    return Container(
      color: Colors.black,
      width: widget.isFullScreen ? double.infinity : null,
      height: widget.isFullScreen ? double.infinity : null,
      child: Stack(
        fit: widget.isFullScreen ? StackFit.expand : StackFit.loose,
        alignment: Alignment.center,
        children: [
          widget.isFullScreen
              ? Center(child: videoContent)
              : videoContent,

        // Buffering/Loading Indicator Overlay
        ValueListenableBuilder(
          valueListenable: widget.controller,
          builder: (context, VideoPlayerValue value, child) {
            // Only show buffering if we are actively trying to play or at the very start
            if (value.isBuffering &&
                (value.isPlaying || value.position == Duration.zero)) {
              return Center(
                child: CircularProgressIndicator(
                  color: widget.styling?.loadingIndicatorColor ??
                      const Color.fromRGBO(255, 0, 0, 0.7),
                  strokeCap: StrokeCap.round,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // Visual feedback overlay for Double-Tap seeking
        if (_seekDirection != 0)
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: _seekDirection == -1
                        ? Colors.white24
                        : Colors.transparent,
                    child: _seekDirection == -1
                        ? const Center(
                            child: Icon(Icons.fast_rewind,
                                color: Colors.white, size: 48))
                        : null,
                  ),
                ),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: _seekDirection == 1
                        ? Colors.white24
                        : Colors.transparent,
                    child: _seekDirection == 1
                        ? const Center(
                            child: Icon(Icons.fast_forward,
                                color: Colors.white, size: 48))
                        : null,
                  ),
                ),
              ],
            ),
          ),

        if (_currentSubtitleText.isNotEmpty)
          Positioned(
            left: 20,
            right: 20,
            bottom: widget.showControls && _controlsVisible
                ? 80
                : 20, // Move up if controls are visible
            child: widget.subtitleBuilder != null
                ? widget.subtitleBuilder!(context, _currentSubtitleText)
                : Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _currentSubtitleText,
                        textAlign: TextAlign.center,
                        style: widget.styling?.settingItemTextStyle?.copyWith(
                                fontSize: widget.isFullScreen ? 20 : 16) ??
                            TextStyle(
                                color: Colors.white,
                                fontSize: widget.isFullScreen ? 20 : 16),
                      ),
                    ),
                  ),
          ),

        if (widget.showControls)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleControls,
              onDoubleTapDown: _handleDoubleTap,
              child: AnimatedOpacity(
                opacity: _controlsVisible ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: widget.controlsBuilder != null
                    ? widget.controlsBuilder!(
                        context, widget.controller, widget.isFullScreen)
                    : AdaptiveControlsLayer(
                        controller: widget.controller,
                        isFullScreen: widget.isFullScreen,
                        styling: widget.styling,
                        messages: widget.messages,
                        onAnalyticsEvent: widget.onAnalyticsEvent,
                        qualities: widget.qualities,
                        currentQuality: widget.currentQuality,
                        onQualitySelected: widget.onQualitySelected,
                        subtitles: widget.subtitles,
                        currentSubtitleTrack: widget.currentSubtitleTrack,
                        onSubtitleSelected: widget.onSubtitleSelected,
                        parsedSubtitles: widget.parsedSubtitles,
                        controlsBuilder: widget.controlsBuilder,
                        subtitleBuilder: widget.subtitleBuilder,
                        isLive: widget.isLive,
                        viewerCount: widget.viewerCount,
                        onEnterFullscreen: widget.onEnterFullscreen,
                        onExitFullscreen: widget.onExitFullscreen,
                      ),
              ),
            ),
          ),
      ],
      ),
    );
  }
}

class AdaptiveControlsLayer extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isFullScreen;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;
  final List<VideoQuality>? qualities;
  final VideoQuality? currentQuality;
  final void Function(VideoQuality)? onQualitySelected;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final void Function(SubtitleTrack?)? onSubtitleSelected;
  final List<SubtitleItem>? parsedSubtitles;
  final AdaptiveControlsBuilder? controlsBuilder;
  final SubtitleBuilder? subtitleBuilder;
  final bool isLive;
  final String? viewerCount;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onExitFullscreen;

  const AdaptiveControlsLayer({
    super.key,
    required this.controller,
    this.isFullScreen = false,
    this.styling,
    this.messages,
    this.onAnalyticsEvent,
    this.qualities,
    this.currentQuality,
    this.onQualitySelected,
    this.subtitles,
    this.currentSubtitleTrack,
    this.onSubtitleSelected,
    this.parsedSubtitles,
    this.controlsBuilder,
    this.subtitleBuilder,
    this.isLive = false,
    this.viewerCount,
    this.onEnterFullscreen,
    this.onExitFullscreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Stack(
        children: [
          Positioned(
            top: 24,
            left: 24,
            right: 24,
            child: _buildTopBar(),
          ),
          Align(
            alignment: Alignment.center,
            child: _buildCenterPlayPause(),
          ),
          SafeArea(
            top: false,
            bottom: isFullScreen,
            left: isFullScreen,
            right: isFullScreen,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isLive) _buildProgressBar(context),
                _buildBottomBar(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        _buildLiveIndicator(),
        const SizedBox(width: 8),
        if (viewerCount != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text(viewerCount!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCenterPlayPause() {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, _) {
        final isPlaying = value.isPlaying;
        return IconButton(
          iconSize: isFullScreen ? 80 : 64, // Bigger in landscape
          icon: Icon(
            isPlaying ? null : Icons.play_arrow,
            color: styling?.iconColor ?? Colors.white.withValues(alpha: 0.9),
          ),
          onPressed: () {
            if (isPlaying) {
              controller.pause();
              onAnalyticsEvent?.call(
                  'video_paused', {'position': value.position.inSeconds});
            } else {
              controller.play();
              onAnalyticsEvent?.call(
                  'video_played', {'position': value.position.inSeconds});
            }
          },
        );
      },
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, _) {
        final duration = value.duration.inSeconds.toDouble();
        final position = value.position.inSeconds
            .clamp(0, value.duration.inSeconds)
            .toDouble();

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Buffer indicator layer
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: CustomPaint(
                  painter: _BufferPainter(value.buffered, value.duration),
                ),
              ),
            ),

            // Pro Gradient Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: isFullScreen ? 6.0 : 4.0, // Thicker in landscape
                trackShape: _GradientSliderTrackShape(
                  gradient: LinearGradient(
                    colors: styling?.progressBarPlayedColor != null
                        ? [styling!.progressBarPlayedColor, styling!.progressBarPlayedColor]
                        : const [Color(0xFFFF007F), Color(0xFF00E5FF)],
                  ),
                ),
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: isFullScreen ? 8.0 : 6.0,
                  elevation: 4.0,
                ),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 14.0),
                activeTrackColor: styling?.progressBarPlayedColor ?? Colors.white,
                inactiveTrackColor: Colors.white24,
                thumbColor: styling?.progressBarHandleColor ?? Colors.white,
              ),
              child: Slider(
                min: 0,
                max: duration > 0 ? duration : 1,
                value: position,
                onChanged: (seconds) {
                  controller.seekTo(Duration(seconds: seconds.toInt()));
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBottomPlayPause(),
                const SizedBox(width: 4),
                _buildVolumeControl(),
                const SizedBox(width: 8),
                if (!isLive)
                  Flexible(
                    child: ValueListenableBuilder(
                      valueListenable: controller,
                      builder: (context, VideoPlayerValue value, child) {
                        return FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${_formatDuration(value.position)} / ${_formatDuration(value.duration)}",
                            maxLines: 1,
                            style: styling?.timeTextStyle ??
                                const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSettingsButton(context),
              const SizedBox(width: 4),
              _buildFullscreenButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPlayPause() {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, _) {
        final isPlaying = value.isPlaying;
        return IconButton(
          padding: const EdgeInsets.all(4.0),
          constraints: const BoxConstraints(),
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 26,
          ),
          onPressed: () {
            isPlaying ? controller.pause() : controller.play();
          },
        );
      },
    );
  }

  Widget _buildVolumeControl() {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, _) {
        final isMuted = value.volume == 0;
        return IconButton(
          padding: const EdgeInsets.all(4.0),
          constraints: const BoxConstraints(),
          icon: Icon(
            isMuted ? Icons.volume_off : Icons.volume_up,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () {
            controller.setVolume(isMuted ? 1.0 : 0.0);
          },
        );
      },
    );
  }

  Widget _buildLiveIndicator() {
    if (isLive) {
      // Currently live: show red badge
      return Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            const Text('LIVE',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );
    } else {
      // Not live, but check if there's a live quality available to switch to
      final liveQuality = qualities?.where((q) => q.isLive).firstOrNull;
      if (liveQuality != null) {
        return GestureDetector(
          onTap: () {
            onAnalyticsEvent?.call('switched_to_live', {});
            onQualitySelected?.call(liveQuality);
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white54, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const Text('GO LIVE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Widget _buildSettingsButton(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onAnalyticsEvent?.call('settings_opened', {});
        showModalBottomSheet(
          context: context,
          backgroundColor:
              styling?.settingsBackgroundColor ?? const Color(0xFF212121),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.hd,
                          color: styling?.iconColor ?? Colors.white),
                      title: Text(messages?.qualityText ?? 'Quality (Resolution)',
                          style: styling?.settingItemTextStyle ??
                              const TextStyle(color: Colors.white)),
                      trailing: Text(currentQuality?.title ?? (messages?.autoText ?? 'Auto'),
                          style: TextStyle(
                              color:
                                  styling?.iconColor.withValues(alpha: 0.7) ??
                                      Colors.white70)),
                      onTap: () {
                        Navigator.pop(context);
                        onAnalyticsEvent
                            ?.call('resolution_settings_clicked', {});
                        if (qualities != null && qualities!.isNotEmpty) {
                          _showQualitiesBottomSheet(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  backgroundColor: styling?.settingsBackgroundColor ?? const Color(0xFF212121),
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    messages?.noQualitiesAvailableText ?? 'No qualities available',
                                    style: styling?.settingItemTextStyle ?? const TextStyle(color: Colors.white),
                                  )));
                        }
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.closed_caption,
                          color: styling?.iconColor ?? Colors.white),
                      title: Text(messages?.subtitlesText ?? 'Subtitles',
                          style: styling?.settingItemTextStyle ??
                              const TextStyle(color: Colors.white)),
                      trailing: Text(currentSubtitleTrack?.title ?? (messages?.offText ?? 'Off'),
                          style: TextStyle(
                              color:
                                  styling?.iconColor.withValues(alpha: 0.7) ??
                                      Colors.white70)),
                      onTap: () {
                        Navigator.pop(context);
                        onAnalyticsEvent?.call('subtitle_settings_clicked', {});
                        if (subtitles != null && subtitles!.isNotEmpty) {
                          _showSubtitlesBottomSheet(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  backgroundColor: styling?.settingsBackgroundColor ?? const Color(0xFF212121),
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    messages?.noSubtitlesAvailableText ?? 'No subtitles available',
                                    style: styling?.settingItemTextStyle ?? const TextStyle(color: Colors.white),
                                  )));
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(Icons.settings,
            color: styling?.iconColor ?? Colors.white, size: 18),
      ),
    );
  }

  void _showQualitiesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          styling?.settingsBackgroundColor ?? const Color(0xFF212121),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: qualities!.length,
              itemBuilder: (context, index) {
                final quality = qualities![index];
                final isSelected = currentQuality == quality;
                return ListTile(
                  title: Text(quality.title,
                      style: styling?.settingItemTextStyle ??
                          const TextStyle(color: Colors.white)),
                  trailing: isSelected
                      ? Icon(Icons.check,
                          color: styling?.iconColor ?? Colors.white)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    onQualitySelected?.call(quality);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showSubtitlesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          styling?.settingsBackgroundColor ?? const Color(0xFF212121),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: subtitles!.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Off option
                  return ListTile(
                    title: Text(messages?.offText ?? 'Off',
                        style: styling?.settingItemTextStyle ??
                            const TextStyle(color: Colors.white)),
                    trailing: currentSubtitleTrack == null
                        ? Icon(Icons.check,
                            color: styling?.iconColor ?? Colors.white)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      onSubtitleSelected?.call(null);
                    },
                  );
                }
                final track = subtitles![index - 1];
                final isSelected = currentSubtitleTrack == track;
                return ListTile(
                  title: Text(track.title,
                      style: styling?.settingItemTextStyle ??
                          const TextStyle(color: Colors.white)),
                  trailing: isSelected
                      ? Icon(Icons.check,
                          color: styling?.iconColor ?? Colors.white)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    onSubtitleSelected?.call(track);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFullscreenButton(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isFullScreen) {
          onExitFullscreen?.call();
        } else {
          onEnterFullscreen?.call();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(
          isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
          color: styling?.iconColor ?? Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

class _BufferPainter extends CustomPainter {
  final List<DurationRange> buffered;
  final Duration duration;

  _BufferPainter(this.buffered, this.duration);

  @override
  void paint(Canvas canvas, Size size) {
    if (duration.inMilliseconds == 0) return;

    final paint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.fill;

    for (final range in buffered) {
      final startX =
          (range.start.inMilliseconds / duration.inMilliseconds) * size.width;
      final endX =
          (range.end.inMilliseconds / duration.inMilliseconds) * size.width;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(startX, size.height / 2 - 1, endX, size.height / 2 + 1),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BufferPainter oldDelegate) {
    return oldDelegate.buffered != buffered || oldDelegate.duration != duration;
  }
}

class _GradientSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  const _GradientSliderTrackShape({
    this.gradient = const LinearGradient(
      colors: [Color(0xFFFF007F), Color(0xFF00E5FF)],
    ),
  });

  final LinearGradient gradient;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);

    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final activeTrackRect = Rect.fromLTRB(
        trackRect.left, trackRect.top, thumbCenter.dx, trackRect.bottom);
    final inactiveTrackRect = Rect.fromLTRB(
        thumbCenter.dx, trackRect.top, trackRect.right, trackRect.bottom);

    final Paint activePaint = Paint()
      ..shader = gradient.createShader(trackRect);
    final Paint inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor!;

    if (inactiveTrackRect.width > 0) {
      context.canvas.drawRRect(
        RRect.fromRectAndRadius(
            inactiveTrackRect, Radius.circular(trackRect.height / 2)),
        inactivePaint,
      );
    }
    if (activeTrackRect.width > 0) {
      context.canvas.drawRRect(
        RRect.fromRectAndRadius(
            activeTrackRect, Radius.circular(trackRect.height / 2)),
        activePaint,
      );
    }
  }
}
