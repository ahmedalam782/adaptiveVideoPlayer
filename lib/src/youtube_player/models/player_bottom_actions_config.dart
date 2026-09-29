import 'package:flutter/material.dart';

/// Configuration class for player bottom actions styling (SRP)
class PlayerBottomActionsConfig {
  final Color progressBarPlayedColor;
  final Color progressBarHandleColor;
  final Color iconColor;
  final Color textColor;
  final TextStyle? timeTextStyle;

  const PlayerBottomActionsConfig({
    this.progressBarPlayedColor = Colors.red,
    this.progressBarHandleColor = Colors.redAccent,
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
    this.timeTextStyle,
  });
}
