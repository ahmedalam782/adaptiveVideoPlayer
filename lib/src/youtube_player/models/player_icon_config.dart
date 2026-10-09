import 'package:flutter/material.dart';

/// Callback signature for dynamic icon builders giving context, color, and size.
typedef PlayerIconBuilder = Widget Function(
  BuildContext context,
  Color color,
  double size,
);

/// A versatile icon definition for the video player that supports:
/// - Standard Flutter [IconData]
/// - Custom [Widget] (e.g. SVG pictures from `flutter_svg`, Lottie animations, custom shapes)
/// - Custom [PlayerIconBuilder] for dynamic theme-aware rendering
/// - Local raster images (PNG, JPEG, etc.) via [PlayerIcon.asset]
/// - Remote images via [PlayerIcon.network]
/// - Individual color and size overrides
class PlayerIcon {
  /// Custom arbitrary widget (e.g. SvgPicture, Image, Lottie, etc.)
  final Widget? widget;

  /// Custom builder receiving context, color, and size
  final PlayerIconBuilder? builder;

  /// Flutter IconData
  final IconData? iconData;

  /// Specific color override for this icon (if null, falls back to player theme iconColor)
  final Color? color;

  /// Specific size override for this icon (if null, falls back to default size)
  final double? size;

  const PlayerIcon({
    this.widget,
    this.builder,
    this.iconData,
    this.color,
    this.size,
  });

  /// Creates a [PlayerIcon] from a standard Flutter [IconData]
  const PlayerIcon.icon(IconData icon, {Color? color, double? size})
      : this(iconData: icon, color: color, size: size);

  /// Creates a [PlayerIcon] wrapping any custom [Widget] (e.g. SvgPicture, custom container)
  const PlayerIcon.widget(Widget widget, {Color? color, double? size})
      : this(widget: widget, color: color, size: size);

  /// Creates a [PlayerIcon] using a builder that dynamically receives [context], [color], and [size]
  const PlayerIcon.builder(PlayerIconBuilder builder, {Color? color, double? size})
      : this(builder: builder, color: color, size: size);

  /// Creates a [PlayerIcon] displaying a local raster asset (e.g. PNG, JPEG, WEBP)
  PlayerIcon.asset(
    String name, {
    Key? key,
    Color? color,
    double? size,
    BoxFit fit = BoxFit.contain,
    String? package,
  })  : widget = Image.asset(
          name,
          key: key,
          color: color,
          width: size,
          height: size,
          fit: fit,
          package: package,
        ),
        builder = null,
        iconData = null,
        color = color,
        size = size;

  /// Creates a [PlayerIcon] displaying a network image
  PlayerIcon.network(
    String src, {
    Key? key,
    Color? color,
    double? size,
    BoxFit fit = BoxFit.contain,
  })  : widget = Image.network(
          src,
          key: key,
          color: color,
          width: size,
          height: size,
          fit: fit,
        ),
        builder = null,
        iconData = null,
        color = color,
        size = size;

  /// Builds the widget with fallback defaults if not explicitly specified on this icon.
  Widget build(
    BuildContext context, {
    Color? defaultColor,
    double? defaultSize,
    IconData? fallbackIcon,
  }) {
    final effectiveColor = color ?? defaultColor ?? Colors.white;
    final effectiveSize = size ?? defaultSize ?? 20.0;

    if (builder != null) {
      return builder!(context, effectiveColor, effectiveSize);
    }
    if (widget != null) {
      return SizedBox(
        width: effectiveSize,
        height: effectiveSize,
        child: Center(child: widget!),
      );
    }
    if (iconData != null) {
      return Icon(
        iconData,
        color: effectiveColor,
        size: effectiveSize,
      );
    }
    if (fallbackIcon != null) {
      return Icon(
        fallbackIcon,
        color: effectiveColor,
        size: effectiveSize,
      );
    }
    return const SizedBox.shrink();
  }

  /// Helper method to cleanly resolve an icon with fallbacks
  static Widget resolve(
    BuildContext context, {
    PlayerIcon? icon,
    Color? defaultColor,
    double? defaultSize,
    required IconData fallbackIcon,
  }) {
    if (icon != null) {
      return icon.build(
        context,
        defaultColor: defaultColor,
        defaultSize: defaultSize,
        fallbackIcon: fallbackIcon,
      );
    }
    return Icon(
      fallbackIcon,
      color: defaultColor ?? Colors.white,
      size: defaultSize ?? 20.0,
    );
  }
}

/// Comprehensive icon configuration allowing users to customize any icon in the player
/// as a PNG, SVG, IconData, builder, or arbitrary widget.
class PlayerIconConfig {
  /// Play icon (default: Icons.play_arrow_rounded)
  final PlayerIcon? playIcon;

  /// Pause icon (default: Icons.pause_rounded)
  final PlayerIcon? pauseIcon;

  /// Stop icon (default: Icons.stop_rounded)
  final PlayerIcon? stopIcon;

  /// Replay / restart icon (default: Icons.replay_rounded)
  final PlayerIcon? replayIcon;

  /// High / normal volume icon (default: Icons.volume_up_rounded)
  final PlayerIcon? volumeHighIcon;

  /// Low volume icon (default: Icons.volume_down_rounded)
  final PlayerIcon? volumeLowIcon;

  /// Muted / zero volume icon (default: Icons.volume_off_rounded)
  final PlayerIcon? volumeMuteIcon;

  /// Skip forward / increase icon (default: Icons.forward_10_rounded)
  final PlayerIcon? skipForwardIcon;

  /// Skip backward / rewind icon (default: Icons.replay_10_rounded)
  final PlayerIcon? skipBackwardIcon;

  /// Fullscreen enter icon (default: Icons.fullscreen_rounded)
  final PlayerIcon? fullscreenIcon;

  /// Fullscreen exit icon (default: Icons.fullscreen_exit_rounded)
  final PlayerIcon? exitFullscreenIcon;

  /// Settings icon (default: Icons.settings)
  final PlayerIcon? settingsIcon;

  /// Subtitles / CC icon (default: Icons.subtitles_outlined)
  final PlayerIcon? subtitlesIcon;

  /// Loop toggle icon (default: Icons.repeat_rounded)
  final PlayerIcon? loopIcon;

  /// Miniplayer / picture-in-picture icon (default: Icons.picture_in_picture_alt_rounded)
  final PlayerIcon? miniPlayerIcon;

  /// Back navigation icon (default: Icons.arrow_back_rounded)
  final PlayerIcon? backIcon;

  /// Error display icon (default: Icons.error_outline)
  final PlayerIcon? errorIcon;

  /// Live viewer count icon (default: Icons.remove_red_eye_outlined)
  final PlayerIcon? viewerCountIcon;

  /// Playback speed icon in settings (default: Icons.speed_rounded)
  final PlayerIcon? speedIcon;

  /// Video quality icon in settings (default: Icons.high_quality_rounded)
  final PlayerIcon? qualityIcon;

  /// Selection checkmark icon in settings (default: Icons.check_rounded)
  final PlayerIcon? checkIcon;

  /// Close button icon in dialogs (default: Icons.close_rounded)
  final PlayerIcon? closeIcon;

  /// Drag handle indicator icon in dialogs (default: Icons.drag_indicator_rounded)
  final PlayerIcon? dragIndicatorIcon;

  /// Next episode icon (default: Icons.skip_next_rounded)
  final PlayerIcon? nextEpisodeIcon;

  /// Episodes drawer icon (default: Icons.video_library_outlined)
  final PlayerIcon? episodesIcon;

  /// Audio and Subtitles popup icon (default: Icons.subtitles_outlined)
  final PlayerIcon? audioSubtitlesIcon;

  const PlayerIconConfig({
    this.playIcon,
    this.pauseIcon,
    this.stopIcon,
    this.replayIcon,
    this.volumeHighIcon,
    this.volumeLowIcon,
    this.volumeMuteIcon,
    this.skipForwardIcon,
    this.skipBackwardIcon,
    this.fullscreenIcon,
    this.exitFullscreenIcon,
    this.settingsIcon,
    this.subtitlesIcon,
    this.loopIcon,
    this.miniPlayerIcon,
    this.backIcon,
    this.errorIcon,
    this.viewerCountIcon,
    this.speedIcon,
    this.qualityIcon,
    this.checkIcon,
    this.closeIcon,
    this.dragIndicatorIcon,
    this.nextEpisodeIcon,
    this.episodesIcon,
    this.audioSubtitlesIcon,
  });

  /// Creates a copy with the given fields replaced by the new values
  PlayerIconConfig copyWith({
    PlayerIcon? playIcon,
    PlayerIcon? pauseIcon,
    PlayerIcon? stopIcon,
    PlayerIcon? replayIcon,
    PlayerIcon? volumeHighIcon,
    PlayerIcon? volumeLowIcon,
    PlayerIcon? volumeMuteIcon,
    PlayerIcon? skipForwardIcon,
    PlayerIcon? skipBackwardIcon,
    PlayerIcon? fullscreenIcon,
    PlayerIcon? exitFullscreenIcon,
    PlayerIcon? settingsIcon,
    PlayerIcon? subtitlesIcon,
    PlayerIcon? loopIcon,
    PlayerIcon? miniPlayerIcon,
    PlayerIcon? backIcon,
    PlayerIcon? errorIcon,
    PlayerIcon? viewerCountIcon,
    PlayerIcon? speedIcon,
    PlayerIcon? qualityIcon,
    PlayerIcon? checkIcon,
    PlayerIcon? closeIcon,
    PlayerIcon? dragIndicatorIcon,
    PlayerIcon? nextEpisodeIcon,
    PlayerIcon? episodesIcon,
    PlayerIcon? audioSubtitlesIcon,
  }) {
    return PlayerIconConfig(
      playIcon: playIcon ?? this.playIcon,
      pauseIcon: pauseIcon ?? this.pauseIcon,
      stopIcon: stopIcon ?? this.stopIcon,
      replayIcon: replayIcon ?? this.replayIcon,
      volumeHighIcon: volumeHighIcon ?? this.volumeHighIcon,
      volumeLowIcon: volumeLowIcon ?? this.volumeLowIcon,
      volumeMuteIcon: volumeMuteIcon ?? this.volumeMuteIcon,
      skipForwardIcon: skipForwardIcon ?? this.skipForwardIcon,
      skipBackwardIcon: skipBackwardIcon ?? this.skipBackwardIcon,
      fullscreenIcon: fullscreenIcon ?? this.fullscreenIcon,
      exitFullscreenIcon: exitFullscreenIcon ?? this.exitFullscreenIcon,
      settingsIcon: settingsIcon ?? this.settingsIcon,
      subtitlesIcon: subtitlesIcon ?? this.subtitlesIcon,
      loopIcon: loopIcon ?? this.loopIcon,
      miniPlayerIcon: miniPlayerIcon ?? this.miniPlayerIcon,
      backIcon: backIcon ?? this.backIcon,
      errorIcon: errorIcon ?? this.errorIcon,
      viewerCountIcon: viewerCountIcon ?? this.viewerCountIcon,
      speedIcon: speedIcon ?? this.speedIcon,
      qualityIcon: qualityIcon ?? this.qualityIcon,
      checkIcon: checkIcon ?? this.checkIcon,
      closeIcon: closeIcon ?? this.closeIcon,
      dragIndicatorIcon: dragIndicatorIcon ?? this.dragIndicatorIcon,
      nextEpisodeIcon: nextEpisodeIcon ?? this.nextEpisodeIcon,
      episodesIcon: episodesIcon ?? this.episodesIcon,
      audioSubtitlesIcon: audioSubtitlesIcon ?? this.audioSubtitlesIcon,
    );
  }
}
