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
  final PlayerIconConfig? icons;

  const FullscreenButton({
    super.key,
    required this.onTap,
    required this.iconColor,
    this.isFullscreen = false,
    this.tooltip,
    this.icons,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: PlayerIcon.resolve(
          context,
          icon: isFullscreen ? icons?.exitFullscreenIcon : icons?.fullscreenIcon,
          fallbackIcon: isFullscreen
              ? Icons.fullscreen_exit_rounded
              : Icons.fullscreen_rounded,
          defaultColor: iconColor,
          defaultSize: 28,
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
  final PlayerIconConfig? icons;

  const MuteButton({
    super.key,
    required this.onTap,
    required this.iconColor,
    required this.isMuted,
    this.tooltip,
    this.icons,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: PlayerIcon.resolve(
          context,
          icon: isMuted ? icons?.volumeMuteIcon : icons?.volumeHighIcon,
          fallbackIcon:
              isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          defaultColor: iconColor,
          defaultSize: 26,
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
  final PlayerIconConfig? icons;

  const SettingsButton({
    super.key,
    required this.onTap,
    required this.iconColor,
    this.tooltip,
    this.icons,
  });

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: PlayerIcon.resolve(
          context,
          icon: icons?.settingsIcon,
          fallbackIcon: Icons.settings_rounded,
          defaultColor: iconColor,
          defaultSize: 26,
        ),
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
  final double thumbRadius;
  final double trackHeight;
  final SliderComponentShape? thumbShape;

  const ProgressBar({
    super.key,
    required this.controller,
    this.playedColor = Colors.red,
    this.handleColor = Colors.redAccent,
    this.backgroundColor = Colors.white24,
    this.thumbRadius = 7.5,
    this.trackHeight = 4.5,
    this.thumbShape,
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
              trackHeight: widget.trackHeight,
              thumbShape: widget.thumbShape ??
                  RoundSliderThumbShape(enabledThumbRadius: widget.thumbRadius),
              overlayShape: RoundSliderOverlayShape(
                overlayRadius: widget.thumbRadius * 1.8,
              ),
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
          icons: config.icons,
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
      if (!isLive && showTimeDisplay)
        TotalDuration(controller: controller),
      if (!isLive && showProgressBar)
        ProgressBar(
          controller: controller,
          playedColor: config.progressBarPlayedColor,
          handleColor: config.progressBarHandleColor,
          backgroundColor: config.progressBarBackgroundColor ?? Colors.white24,
          thumbRadius: config.progressBarThumbRadius,
          trackHeight: config.progressBarTrackHeight,
          thumbShape: config.progressBarThumbShape,
        )
      else
        const Spacer(),
      if (showSettingsButton && onSettingsTap != null) ...[
        const SizedBox(width: 8),
        SettingsButton(
          onTap: onSettingsTap,
          iconColor: config.iconColor,
          icons: config.icons,
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
              child: Builder(
                builder: (context) {
                  return PlayerIcon.resolve(
                    context,
                    icon: config.icons.miniPlayerIcon,
                    fallbackIcon: Icons.picture_in_picture_alt_rounded,
                    defaultColor: config.iconColor,
                    defaultSize: 22,
                  );
                },
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
          icons: config.icons,
          tooltip: isFullscreen
              ? (messages?.exitFullscreenText ?? 'Exit Fullscreen')
              : (messages?.fullscreenText ?? 'Fullscreen'),
        ),
      ],
    ];
  }
}
