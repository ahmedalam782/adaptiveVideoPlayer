import 'dart:ui';
import 'package:flutter/material.dart';

import '../../youtube_player/models/youtube_player_config.dart';

/// Volume HUD feedback overlay positioned at the top of the video player.
class AdaptiveVolumeHudOverlay extends StatelessWidget {
  final double? volume;
  final bool isFullScreen;
  final PlayerStyleConfig? styling;

  const AdaptiveVolumeHudOverlay({
    super.key,
    required this.volume,
    required this.isFullScreen,
    this.styling,
  });

  @override
  Widget build(BuildContext context) {
    if (volume == null) return const SizedBox.shrink();

    final PlayerIcon? volIcon;
    final IconData fallbackIcon;
    if (volume == 0) {
      volIcon = styling?.icons.volumeMuteIcon;
      fallbackIcon = Icons.volume_off_rounded;
    } else if (volume! < 0.5) {
      volIcon = styling?.icons.volumeLowIcon;
      fallbackIcon = Icons.volume_down_rounded;
    } else {
      volIcon = styling?.icons.volumeHighIcon;
      fallbackIcon = Icons.volume_up_rounded;
    }

    final activeColor = styling?.volumeSliderActiveColor ??
        styling?.progressBarPlayedColor ??
        Colors.white;

    return Positioned(
      top: isFullScreen ? 28 : 16,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PlayerIcon.resolve(
                      context,
                      icon: volIcon,
                      fallbackIcon: fallbackIcon,
                      defaultColor: styling?.iconColor ?? Colors.white,
                      defaultSize: 20,
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: volume,
                          backgroundColor:
                              styling?.volumeSliderInactiveColor ??
                                  Colors.white24,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(activeColor),
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(volume! * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
