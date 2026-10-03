import 'package:flutter/material.dart';

import 'player_icon_config.dart';

/// Configuration class for player bottom actions styling (SRP)
class PlayerBottomActionsConfig {
  final Color progressBarPlayedColor;
  final Color progressBarHandleColor;
  final Color? progressBarBackgroundColor;
  final Color iconColor;
  final Color textColor;
  final TextStyle? timeTextStyle;
  final PlayerIconConfig icons;
  final double progressBarThumbRadius;
  final double progressBarTrackHeight;
  final SliderComponentShape? progressBarThumbShape;

  const PlayerBottomActionsConfig({
    this.progressBarPlayedColor = Colors.red,
    this.progressBarHandleColor = Colors.redAccent,
    this.progressBarBackgroundColor,
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
    this.timeTextStyle,
    this.icons = const PlayerIconConfig(),
    this.progressBarThumbRadius = 7.5,
    this.progressBarTrackHeight = 4.5,
    this.progressBarThumbShape,
  });
}
