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
  final String? tooltip;

  const FullscreenButton({
    super.key,
    required this.onTap,
    required this.iconColor,
    this.isFullscreen = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
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

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

/// Mute toggle button widget
class MuteButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;
  final bool isMuted;
  final String? tooltip;

  const MuteButton({
    super.key,
    required this.onTap,
    required this.iconColor,
    required this.isMuted,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
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

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}

/// Settings button widget
class SettingsButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color iconColor;
  final String? tooltip;

  const SettingsButton({
    super.key,
    required this.onTap,
    required this.iconColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(Icons.settings, color: iconColor, size: 24),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
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
    bool showVolumeButton = true,
    bool showTimeDisplay = true,
    bool showProgressBar = true,
    bool showMiniPlayerButton = true,
    PlayerTextConfig? messages,
    bool isLive = false,
    required VoidCallback onFullscreenTap,
    required VoidCallback onMuteTap,
    VoidCallback? onSettingsTap,
    VoidCallback? onPipTap,
  }) {
    return [
      if (showVolumeButton)
        MuteButton(
          onTap: onMuteTap,
          iconColor: config.iconColor,
          isMuted: isMuted,
          tooltip: isMuted
              ? (messages?.unmuteAudioText ?? 'Unmute')
              : (messages?.muteAudioText ?? 'Mute'),
        ),
      if (showVolumeButton) const SizedBox(width: 4),
      if (!isLive && showTimeDisplay) CurrentPosition(controller: controller),
      if (!isLive && showTimeDisplay)
        TimeSeparator(
          textStyle: config.timeTextStyle,
          textColor: config.textColor,
        ),
      if (!isLive && showTimeDisplay) RemainingDuration(controller: controller),
      if (!isLive && showProgressBar)
        ProgressBar(
          controller: controller,
          playedColor: config.progressBarPlayedColor,
          handleColor: config.progressBarHandleColor,
        )
      else
        const Spacer(),
      if (showSettingsButton && onSettingsTap != null) ...[
        const SizedBox(width: 8),
        SettingsButton(
          onTap: onSettingsTap,
          iconColor: config.iconColor,
          tooltip: messages?.playerSettingsText ?? 'Player Settings',
        ),
      ],
      if (!isFullscreen &&
          !isLive &&
          showMiniPlayerButton &&
          onPipTap != null) ...[
        const SizedBox(width: 8),
        Tooltip(
          message: messages?.miniPlayerText ?? 'Miniplayer',
          child: GestureDetector(
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
        ),
      ],
      if (showFullscreenButton) ...[
        const SizedBox(width: 8),
        FullscreenButton(
          onTap: onFullscreenTap,
          iconColor: config.iconColor,
          isFullscreen: isFullscreen,
          tooltip: isFullscreen
              ? (messages?.exitFullscreenText ?? 'Exit Fullscreen')
              : (messages?.fullscreenText ?? 'Fullscreen'),
        ),
      ],
    ];
  }
}
