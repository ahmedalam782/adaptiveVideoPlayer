import 'package:flutter/material.dart';

/// Volume HUD feedback overlay positioned at the top of the video player.
class AdaptiveVolumeHudOverlay extends StatelessWidget {
  final double? volume;
  final bool isFullScreen;

  const AdaptiveVolumeHudOverlay({
    super.key,
    required this.volume,
    required this.isFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    if (volume == null) return const SizedBox.shrink();

    return Positioned(
      top: isFullScreen ? 28 : 16,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  volume == 0
                      ? Icons.volume_off_rounded
                      : volume! < 0.5
                          ? Icons.volume_down_rounded
                          : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: volume,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
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
    );
  }
}
