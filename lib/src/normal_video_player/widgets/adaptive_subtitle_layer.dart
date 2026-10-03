import 'package:flutter/material.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import 'adaptive_controls_layer.dart';

/// Subtitle display overlay positioned at the bottom of the player.
class AdaptiveSubtitleLayer extends StatelessWidget {
  final String subtitleText;
  final bool showControls;
  final bool controlsVisible;
  final bool isFullScreen;
  final SubtitleBuilder? subtitleBuilder;
  final PlayerStyleConfig? styling;

  const AdaptiveSubtitleLayer({
    super.key,
    required this.subtitleText,
    required this.showControls,
    required this.controlsVisible,
    required this.isFullScreen,
    this.subtitleBuilder,
    this.styling,
  });

  @override
  Widget build(BuildContext context) {
    if (subtitleText.isEmpty) return const SizedBox.shrink();

    return Positioned(
      left: 20,
      right: 20,
      bottom: showControls && controlsVisible
          ? (styling?.bottomBarLayout == BottomBarLayout.inline ? 76.0 : 96.0)
          : 20.0,
      child: subtitleBuilder != null
          ? subtitleBuilder!(context, subtitleText)
          : Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subtitleText,
                  textAlign: TextAlign.center,
                  style: styling?.settingItemTextStyle?.copyWith(
                          fontSize: isFullScreen ? 20 : 16) ??
                      TextStyle(
                          color: Colors.white,
                          fontSize: isFullScreen ? 20 : 16),
                ),
              ),
            ),
    );
  }
}
