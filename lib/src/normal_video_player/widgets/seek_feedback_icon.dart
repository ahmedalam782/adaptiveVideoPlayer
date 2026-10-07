import 'package:flutter/material.dart';

import '../../youtube_player/models/player_icon_config.dart';

/// A widget displaying directional seek feedback icons (forward or rewind).
class SeekFeedbackIcon extends StatelessWidget {
  final bool isForward;
  final Color iconColor;
  final PlayerIcon? configuredIcon;
  final double size;

  const SeekFeedbackIcon({
    super.key,
    required this.isForward,
    required this.iconColor,
    this.configuredIcon,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isNumberedIcon = configuredIcon?.iconData == Icons.replay_10_rounded ||
        configuredIcon?.iconData == Icons.replay_5_rounded ||
        configuredIcon?.iconData == Icons.replay_30_rounded ||
        configuredIcon?.iconData == Icons.forward_10_rounded ||
        configuredIcon?.iconData == Icons.forward_5_rounded ||
        configuredIcon?.iconData == Icons.forward_30_rounded;

    if (configuredIcon != null && !isNumberedIcon) {
      return configuredIcon!.build(
        context,
        defaultColor: iconColor,
        defaultSize: size,
        fallbackIcon: isForward
            ? Icons.fast_forward_rounded
            : Icons.fast_rewind_rounded,
      );
    }

    return Icon(
      isForward ? Icons.fast_forward_rounded : Icons.fast_rewind_rounded,
      color: iconColor,
      size: size,
    );
  }
}
