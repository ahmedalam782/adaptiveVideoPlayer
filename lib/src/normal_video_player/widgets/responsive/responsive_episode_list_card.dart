import 'package:flutter/material.dart';

import '../../models/video_episode.dart';

/// One episode row in the wide window episode list.
class ResponsiveEpisodeListCard extends StatelessWidget {
  final VideoEpisode episode;
  final bool isCurrent;
  final bool isRtl;
  final Color playedColor;
  final String nowPlayingText;
  final Animation<double> wave;
  final VoidCallback onTap;

  const ResponsiveEpisodeListCard({
    super.key,
    required this.episode,
    required this.isCurrent,
    required this.isRtl,
    required this.playedColor,
    required this.nowPlayingText,
    required this.wave,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrent
              ? const Color(0xFF2B2B2B)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrent ? Colors.white : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${episode.number}',
                  style: TextStyle(
                    color: isCurrent ? Colors.white : Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    episode.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 50,
                  height: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: episode.watchedProgress.clamp(0.0, 1.0),
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(playedColor),
                    ),
                  ),
                ),
              ],
            ),
            if (isCurrent) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      episode.description ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                          image: episode.thumbnailUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(episode.thumbnailUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: episode.thumbnailUrl == null
                            ? const Icon(Icons.movie_creation_outlined,
                                color: Colors.white38, size: 28)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              nowPlayingText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            ResponsiveNowPlayingEqualizer(wave: wave),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small equalizer shown on the episode that is playing.
class ResponsiveNowPlayingEqualizer extends StatelessWidget {
  final Animation<double> wave;

  const ResponsiveNowPlayingEqualizer({super.key, required this.wave});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: wave,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _Bar(factor: 0.4 + (wave.value * 0.6)),
            const SizedBox(width: 1.5),
            _Bar(factor: 1.0 - (wave.value * 0.7)),
            const SizedBox(width: 1.5),
            _Bar(factor: 0.3 + (wave.value * 0.7)),
          ],
        );
      },
    );
  }
}

class _Bar extends StatelessWidget {
  final double factor;

  const _Bar({required this.factor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: 10 * factor.clamp(0.2, 1.0),
      decoration: BoxDecoration(
        color: const Color(0xFF00A3FF),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
