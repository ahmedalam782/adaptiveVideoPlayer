import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/youtube_player_config.dart';
import 'current_position.dart';
import 'remaining_duration.dart';

/// Fullscreen toggle button widget
class FullscreenButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;
  final bool isFullscreen;

  const FullscreenButton({
    super.key,
    required this.onTap,
    required this.iconColor,
    this.isFullscreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
          color: iconColor,
          size: 24,
        ),
      ),
    );
  }
}

/// Mute toggle button widget
class MuteButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;
  final bool isMuted;

  const MuteButton({
    super.key,
    required this.onTap,
    required this.iconColor,
    required this.isMuted,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          isMuted ? Icons.volume_off : Icons.volume_up,
          color: iconColor,
          size: 28,
        ),
      ),
    );
  }
}

/// Settings button widget
class SettingsButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;

  const SettingsButton({
    super.key,
    required this.onTap,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(Icons.settings, color: iconColor, size: 24),
      ),
    );
  }
}

/// Time separator widget
class TimeSeparator extends StatelessWidget {
  final TextStyle? textStyle;
  final Color textColor;

  const TimeSeparator({
    super.key,
    this.textStyle,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      ' / ',
      style: textStyle ?? TextStyle(color: textColor, fontSize: 14),
    );
  }
}

/// A smooth seek bar widget for YouTube videos
class ProgressBar extends StatefulWidget {
  final YoutubePlayerController controller;
  final Color playedColor;
  final Color handleColor;
  final Color backgroundColor;

  const ProgressBar({
    super.key,
    required this.controller,
    this.playedColor = Colors.red,
    this.handleColor = Colors.redAccent,
    this.backgroundColor = Colors.white12,
  });

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<YoutubeVideoState>(
      stream: widget.controller.videoStateStream,
      initialData: const YoutubeVideoState(),
      builder: (context, snapshot) {
        final position = snapshot.data?.position ?? Duration.zero;
        final duration = widget.controller.metadata.duration;

        final double currentProgress = duration.inSeconds > 0
            ? (position.inSeconds / duration.inSeconds).clamp(0.0, 1.0)
            : 0.0;

        final sliderValue = _dragValue ?? currentProgress;

        return Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: widget.playedColor,
              inactiveTrackColor: widget.backgroundColor,
              thumbColor: widget.handleColor,
              trackHeight: 4.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
            ),
            child: Slider(
              value: sliderValue,
              onChanged: (newValue) {
                setState(() {
                  _dragValue = newValue;
                });
              },
              onChangeEnd: (newValue) {
                final seekSeconds = newValue * duration.inSeconds;
                widget.controller
                    .seekTo(seconds: seekSeconds, allowSeekAhead: true);
                setState(() {
                  _dragValue = null;
                });
              },
            ),
          ),
        );
      },
    );
  }
}

/// Utility class for building player bottom actions
class PlayerBottomActionsBuilder {
  /// Builds the list of bottom action widgets for the YouTube player
  static List<Widget> build({
    required YoutubePlayerController controller,
    required PlayerBottomActionsConfig config,
    required bool isMuted,
    bool isFullscreen = false,
    bool showFullscreenButton = true,
    bool showSettingsButton = false,
    bool isLive = false,
    required VoidCallback onFullscreenTap,
    required VoidCallback onMuteTap,
    VoidCallback? onSettingsTap,
    VoidCallback? onPipTap,
  }) {
    return [
      MuteButton(
        onTap: onMuteTap,
        iconColor: config.iconColor,
        isMuted: isMuted,
      ),
      if (!isLive) CurrentPosition(controller: controller),
      if (!isLive)
        TimeSeparator(
          textStyle: config.timeTextStyle,
          textColor: config.textColor,
        ),
      if (!isLive) RemainingDuration(controller: controller),
      if (!isLive)
        ProgressBar(
          controller: controller,
          playedColor: config.progressBarPlayedColor,
          handleColor: config.progressBarHandleColor,
        )
      else
        const Spacer(),
      if (showSettingsButton && onSettingsTap != null)
        SettingsButton(onTap: onSettingsTap, iconColor: config.iconColor),
      if (!isFullscreen && !isLive && onPipTap != null)
        GestureDetector(
          onTap: onPipTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.picture_in_picture_alt_rounded,
              color: config.iconColor,
              size: 22,
            ),
          ),
        ),
      if (showFullscreenButton)
        FullscreenButton(
          onTap: onFullscreenTap,
          iconColor: config.iconColor,
          isFullscreen: isFullscreen,
        ),
    ];
  }
}
