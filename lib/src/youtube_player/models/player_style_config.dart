import 'package:flutter/material.dart';

import 'player_icon_config.dart';

/// Layout presentation style for the player bottom control bar
enum BottomBarLayout {
  /// YouTube-style multi-pill layout with progress bar above the controls.
  youtubePills,

  /// Modern unified floating capsule where play, duration, inline progress bar,
  /// volume, and fullscreen all sit in a single horizontal row.
  inline,
}

/// Configuration model for player visual styling, theme colors, progress bars, and custom icons (SRP).
class PlayerStyleConfig {
  /// Progress bar played color
  final Color progressBarPlayedColor;

  /// Progress bar handle / thumb color
  final Color progressBarHandleColor;

  /// Loading indicator color
  final Color loadingIndicatorColor;

  /// Error icon color
  final Color errorIconColor;

  /// Icon color for controls
  final Color iconColor;

  /// Text color for time displays
  final Color textColor;

  /// Background color for player
  final Color backgroundColor;

  /// Background color for settings sheet
  final Color settingsBackgroundColor;

  /// Background color for setting items
  final Color settingItemBackgroundColor;

  /// Switch inactive thumb color
  final Color? switchInactiveThumbColor;

  /// Switch inactive track color
  final Color? switchInactiveTrackColor;

  /// Text style for time displays
  final TextStyle? timeTextStyle;

  /// Text style for settings title
  final TextStyle? settingsTitleStyle;

  /// Text style for setting items
  final TextStyle? settingItemTextStyle;

  /// Text style for error message
  final TextStyle? errorTextStyle;

  /// Whether to use modern glassmorphic cinema design for player controls (defaults to true)
  final bool useGlassmorphicControls;

  /// Color for buffered portion of progress bar
  final Color? progressBarBufferedColor;

  /// Color for background unplayed portion of progress bar
  final Color? progressBarBackgroundColor;

  /// Background color for controls pills and action bars
  final Color? controlsBackgroundColor;

  /// Fill color of the center play/pause disc.
  final Color centerButtonColor;

  /// Glyph color of the center play/pause icon.
  final Color centerIconColor;

  /// Tint for the top control gradient. The gradient fades this color to clear.
  final Color topBarColor;

  /// Comprehensive icon customization configuration (PNG, SVG, IconData, builder, colors)
  final PlayerIconConfig icons;

  /// Radius of the circular scrubber handle/thumb on the progress bar in normal state (default: 6.0)
  final double progressBarThumbRadius;

  /// Radius of the circular scrubber handle/thumb on the progress bar when hovered or dragging (default: 7.5)
  final double progressBarHoverThumbRadius;

  /// Height of the progress bar timeline track in normal state (default: 3.5)
  final double progressBarTrackHeight;

  /// Height of the progress bar timeline track when hovered or dragging (default: 5.5)
  final double progressBarHoverTrackHeight;

  /// Radius of the touch/hover ripple overlay around the progress bar scrubber circle (default: 12.0)
  final double progressBarOverlayRadius;

  /// Whether to show the circular thumb / scrubber handle on the progress bar (default: true)
  final bool showProgressBarThumb;

  /// Optional custom [SliderComponentShape] for the progress bar thumb
  final SliderComponentShape? progressBarThumbShape;

  /// Optional custom size/diameter for the circular loading / buffering indicator
  final double? loadingIndicatorSize;

  /// Stroke width for the circular loading / buffering progress indicator (default: 4.0)
  final double loadingIndicatorStrokeWidth;

  /// Optional custom builder for the circular loading / buffering indicator
  final Widget Function(BuildContext context)? loadingIndicatorBuilder;

  /// Active track color for the volume slider in the bottom bar
  final Color? volumeSliderActiveColor;

  /// Inactive track color for the volume slider in the bottom bar
  final Color? volumeSliderInactiveColor;

  /// Thumb color for the volume slider in the bottom bar
  final Color? volumeSliderThumbColor;

  /// Radius of the circular thumb handle on the volume slider (default: 5.5)
  final double volumeSliderThumbRadius;

  /// Track height of the volume slider (default: 3.0)
  final double volumeSliderTrackHeight;

  /// Optional explicit height for the bottom control bar (if null, dynamically scales with screen size)
  final double? bottomBarHeight;

  /// Optional padding inside the bottom control bar container
  final EdgeInsetsGeometry? bottomBarPadding;

  /// Optional margin around the bottom control bar container
  final EdgeInsetsGeometry? bottomBarMargin;

  /// Optional custom border radius for the bottom control bar capsule
  final BorderRadiusGeometry? bottomBarBorderRadius;

  /// Layout presentation style of the bottom bar controls (default: [BottomBarLayout.youtubePills])
  final BottomBarLayout bottomBarLayout;

  const PlayerStyleConfig({
    this.progressBarPlayedColor = Colors.red,
    this.progressBarHandleColor = Colors.redAccent,
    this.progressBarBufferedColor,
    this.progressBarBackgroundColor,
    this.controlsBackgroundColor,
    this.centerButtonColor = Colors.white,
    this.centerIconColor = const Color(0xFF1E88E5),
    this.topBarColor = const Color(0xCC000000),
    this.loadingIndicatorColor = const Color(0xFFFF0000),
    this.errorIconColor = const Color(0xFFFF0000),
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
    this.backgroundColor = const Color(0xFF1D1D1D),
    this.settingsBackgroundColor = const Color(0xFF1D1D1D),
    this.settingItemBackgroundColor = const Color(0xFF0D0D0D),
    this.switchInactiveThumbColor,
    this.switchInactiveTrackColor,
    this.timeTextStyle,
    this.settingsTitleStyle,
    this.settingItemTextStyle,
    this.errorTextStyle,
    this.useGlassmorphicControls = true,
    this.icons = const PlayerIconConfig(),
    this.progressBarThumbRadius = 6.0,
    this.progressBarHoverThumbRadius = 7.5,
    this.progressBarTrackHeight = 3.5,
    this.progressBarHoverTrackHeight = 5.5,
    this.progressBarOverlayRadius = 12.0,
    this.showProgressBarThumb = true,
    this.progressBarThumbShape,
    this.loadingIndicatorSize,
    this.loadingIndicatorStrokeWidth = 4.0,
    this.loadingIndicatorBuilder,
    this.volumeSliderActiveColor,
    this.volumeSliderInactiveColor,
    this.volumeSliderThumbColor,
    this.volumeSliderThumbRadius = 5.5,
    this.volumeSliderTrackHeight = 3.0,
    this.bottomBarHeight,
    this.bottomBarPadding,
    this.bottomBarMargin,
    this.bottomBarBorderRadius,
    this.bottomBarLayout = BottomBarLayout.youtubePills,
  });

  /// Creates a copy with updated values
  PlayerStyleConfig copyWith({
    Color? progressBarPlayedColor,
    Color? progressBarHandleColor,
    Color? progressBarBufferedColor,
    Color? progressBarBackgroundColor,
    Color? controlsBackgroundColor,
    Color? centerButtonColor,
    Color? centerIconColor,
    Color? topBarColor,
    Color? loadingIndicatorColor,
    Color? errorIconColor,
    Color? iconColor,
    Color? textColor,
    Color? backgroundColor,
    Color? settingsBackgroundColor,
    Color? settingItemBackgroundColor,
    Color? switchInactiveThumbColor,
    Color? switchInactiveTrackColor,
    TextStyle? timeTextStyle,
    TextStyle? settingsTitleStyle,
    TextStyle? settingItemTextStyle,
    TextStyle? errorTextStyle,
    bool? useGlassmorphicControls,
    PlayerIconConfig? icons,
    double? progressBarThumbRadius,
    double? progressBarHoverThumbRadius,
    double? progressBarTrackHeight,
    double? progressBarHoverTrackHeight,
    double? progressBarOverlayRadius,
    bool? showProgressBarThumb,
    SliderComponentShape? progressBarThumbShape,
    double? loadingIndicatorSize,
    double? loadingIndicatorStrokeWidth,
    Widget Function(BuildContext context)? loadingIndicatorBuilder,
    Color? volumeSliderActiveColor,
    Color? volumeSliderInactiveColor,
    Color? volumeSliderThumbColor,
    double? volumeSliderThumbRadius,
    double? volumeSliderTrackHeight,
    double? bottomBarHeight,
    EdgeInsetsGeometry? bottomBarPadding,
    EdgeInsetsGeometry? bottomBarMargin,
    BorderRadiusGeometry? bottomBarBorderRadius,
    BottomBarLayout? bottomBarLayout,
  }) {
    return PlayerStyleConfig(
      progressBarPlayedColor:
          progressBarPlayedColor ?? this.progressBarPlayedColor,
      progressBarHandleColor:
          progressBarHandleColor ?? this.progressBarHandleColor,
      progressBarBufferedColor:
          progressBarBufferedColor ?? this.progressBarBufferedColor,
      progressBarBackgroundColor:
          progressBarBackgroundColor ?? this.progressBarBackgroundColor,
      controlsBackgroundColor:
          controlsBackgroundColor ?? this.controlsBackgroundColor,
      centerButtonColor: centerButtonColor ?? this.centerButtonColor,
      centerIconColor: centerIconColor ?? this.centerIconColor,
      topBarColor: topBarColor ?? this.topBarColor,
      loadingIndicatorColor:
          loadingIndicatorColor ?? this.loadingIndicatorColor,
      errorIconColor: errorIconColor ?? this.errorIconColor,
      iconColor: iconColor ?? this.iconColor,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      settingsBackgroundColor:
          settingsBackgroundColor ?? this.settingsBackgroundColor,
      settingItemBackgroundColor:
          settingItemBackgroundColor ?? this.settingItemBackgroundColor,
      switchInactiveThumbColor:
          switchInactiveThumbColor ?? this.switchInactiveThumbColor,
      switchInactiveTrackColor:
          switchInactiveTrackColor ?? this.switchInactiveTrackColor,
      timeTextStyle: timeTextStyle ?? this.timeTextStyle,
      settingsTitleStyle: settingsTitleStyle ?? this.settingsTitleStyle,
      settingItemTextStyle: settingItemTextStyle ?? this.settingItemTextStyle,
      errorTextStyle: errorTextStyle ?? this.errorTextStyle,
      useGlassmorphicControls:
          useGlassmorphicControls ?? this.useGlassmorphicControls,
      icons: icons ?? this.icons,
      progressBarThumbRadius:
          progressBarThumbRadius ?? this.progressBarThumbRadius,
      progressBarHoverThumbRadius:
          progressBarHoverThumbRadius ?? this.progressBarHoverThumbRadius,
      progressBarTrackHeight:
          progressBarTrackHeight ?? this.progressBarTrackHeight,
      progressBarHoverTrackHeight:
          progressBarHoverTrackHeight ?? this.progressBarHoverTrackHeight,
      progressBarOverlayRadius:
          progressBarOverlayRadius ?? this.progressBarOverlayRadius,
      showProgressBarThumb: showProgressBarThumb ?? this.showProgressBarThumb,
      progressBarThumbShape:
          progressBarThumbShape ?? this.progressBarThumbShape,
      loadingIndicatorSize: loadingIndicatorSize ?? this.loadingIndicatorSize,
      loadingIndicatorStrokeWidth:
          loadingIndicatorStrokeWidth ?? this.loadingIndicatorStrokeWidth,
      loadingIndicatorBuilder:
          loadingIndicatorBuilder ?? this.loadingIndicatorBuilder,
      volumeSliderActiveColor:
          volumeSliderActiveColor ?? this.volumeSliderActiveColor,
      volumeSliderInactiveColor:
          volumeSliderInactiveColor ?? this.volumeSliderInactiveColor,
      volumeSliderThumbColor:
          volumeSliderThumbColor ?? this.volumeSliderThumbColor,
      volumeSliderThumbRadius:
          volumeSliderThumbRadius ?? this.volumeSliderThumbRadius,
      volumeSliderTrackHeight:
          volumeSliderTrackHeight ?? this.volumeSliderTrackHeight,
      bottomBarHeight: bottomBarHeight ?? this.bottomBarHeight,
      bottomBarPadding: bottomBarPadding ?? this.bottomBarPadding,
      bottomBarMargin: bottomBarMargin ?? this.bottomBarMargin,
      bottomBarBorderRadius:
          bottomBarBorderRadius ?? this.bottomBarBorderRadius,
      bottomBarLayout: bottomBarLayout ?? this.bottomBarLayout,
    );
  }
}
