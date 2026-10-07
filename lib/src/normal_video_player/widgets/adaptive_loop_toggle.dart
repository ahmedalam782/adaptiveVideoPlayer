import 'package:flutter/material.dart';
import '../utils/video_player_web_safe.dart';

import '../../core/constants/player_strings.dart';
import '../../youtube_player/models/player_icon_config.dart';
import '../../youtube_player/models/player_style_config.dart';
import '../../youtube_player/models/player_text_config.dart';

/// A toggle widget allowing users to toggle video looping.
class AdaptiveLoopToggle extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isLooping;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;

  const AdaptiveLoopToggle({
    super.key,
    required this.controller,
    required this.isLooping,
    this.styling,
    this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: messages?.loopVideoText ?? PlayerStrings.loopVideo,
      waitDuration: const Duration(milliseconds: 500),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          controller.setLooping(!isLooping);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
          child: Container(
            width: 30,
            height: 16,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isLooping
                  ? Colors.white.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: isLooping
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Builder(
                builder: (context) {
                  return PlayerIcon.resolve(
                    context,
                    icon: styling?.icons.loopIcon,
                    fallbackIcon:
                        isLooping ? Icons.repeat_rounded : Icons.pause_rounded,
                    defaultColor: Colors.black87,
                    defaultSize: 9,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
