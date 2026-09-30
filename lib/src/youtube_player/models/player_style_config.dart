import 'package:flutter/material.dart';

/// Configuration model for player visual styling and theme colors (SRP)
class PlayerStyleConfig {
  /// Progress bar played color
  final Color progressBarPlayedColor;

  /// Progress bar handle color
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

  const PlayerStyleConfig({
    this.progressBarPlayedColor = Colors.red,
    this.progressBarHandleColor = Colors.redAccent,
    this.progressBarBufferedColor,
    this.progressBarBackgroundColor,
    this.controlsBackgroundColor,
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
  });

  /// Creates a copy with updated values
  PlayerStyleConfig copyWith({
    Color? progressBarPlayedColor,
    Color? progressBarHandleColor,
    Color? progressBarBufferedColor,
    Color? progressBarBackgroundColor,
    Color? controlsBackgroundColor,
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
    );
  }
}
