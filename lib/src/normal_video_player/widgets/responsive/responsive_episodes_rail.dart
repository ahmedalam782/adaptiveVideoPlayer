import 'package:flutter/material.dart';

import '../../../youtube_player/models/youtube_player_config.dart';
import '../../models/video_episode.dart';
import '../../utils/player_chrome_utils.dart';

/// Horizontal episode rail for a phone or tablet window.
class ResponsiveEpisodesRail extends StatefulWidget {
  final List<VideoEpisode> episodes;
  final VideoEpisode? currentEpisode;
  final ValueChanged<VideoEpisode>? onEpisodeSelected;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final VoidCallback? onClose;

  const ResponsiveEpisodesRail({
    super.key,
    required this.episodes,
    this.currentEpisode,
    this.onEpisodeSelected,
    this.styling,
    this.messages,
    this.onClose,
  });

  @override
  State<ResponsiveEpisodesRail> createState() => _ResponsiveEpisodesRailState();
}

class _ResponsiveEpisodesRailState extends State<ResponsiveEpisodesRail> {
  String? _activeSeason;

  @override
  Widget build(BuildContext context) {
    if (widget.episodes.isEmpty) return const SizedBox.shrink();

    final textDirection = widget.messages?.resolveTextDirection(context) ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;
    final isRtl = textDirection == TextDirection.rtl;
    final episodesLabel =
        widget.messages?.episodesText ?? (isRtl ? 'الحلقات' : 'Episodes');
    final groups = PlayerChromeUtils.groupBySeason(widget.episodes);
    final seasons = groups.keys.toList();
    final currentSeason = PlayerChromeUtils.seasonKey(
      widget.currentEpisode ?? widget.episodes.first,
    );
    final selectedSeason = (_activeSeason != null && seasons.contains(_activeSeason))
        ? _activeSeason!
        : (seasons.contains(currentSeason) ? currentSeason : seasons.first);
    final visible = groups[selectedSeason] ?? widget.episodes;
    final playedColor =
        widget.styling?.progressBarPlayedColor ?? const Color(0xFFE50914);

    return Directionality(
      textDirection: textDirection,
      child: Material(
        color: const Color(0xF0141414),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    if (seasons.length > 1)
                      PopupMenuButton<String>(
                        initialValue: selectedSeason,
                        color: const Color(0xFF2A2A2A),
                        onSelected: (season) =>
                            setState(() => _activeSeason = season),
                        itemBuilder: (context) => [
                          for (final season in seasons)
                            PopupMenuItem(
                              value: season,
                              child: Text(
                                PlayerChromeUtils.seasonLabel(
                                  season: season,
                                  isRtl: isRtl,
                                  episodesLabel: episodesLabel,
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                PlayerChromeUtils.seasonLabel(
                                  season: selectedSeason,
                                  isRtl: isRtl,
                                  episodesLabel: episodesLabel,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Icon(Icons.expand_more_rounded,
                                  color: Colors.white),
                            ],
                          ),
                        ),
                      )
                    else
                      Text(
                        episodesLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    const Spacer(),
                    if (widget.onClose != null)
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final episode = visible[index];
                      return ResponsiveEpisodeRailCard(
                        episode: episode,
                        isCurrent: widget.currentEpisode?.id == episode.id,
                        playedColor: playedColor,
                        onTap: () => widget.onEpisodeSelected?.call(episode),
                      );
                    },
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

/// One episode card in [ResponsiveEpisodesRail].
class ResponsiveEpisodeRailCard extends StatelessWidget {
  final VideoEpisode episode;
  final bool isCurrent;
  final Color playedColor;
  final VoidCallback onTap;

  const ResponsiveEpisodeRailCard({
    super.key,
    required this.episode,
    required this.isCurrent,
    required this.playedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final length = PlayerChromeUtils.clockLabel(episode.duration);
    return SizedBox(
      width: 220,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: isCurrent
                          ? const Color(0xFF3A3A3A)
                          : const Color(0xFF242424),
                      child: episode.thumbnailUrl == null
                          ? const Icon(Icons.movie_creation_outlined,
                              color: Colors.white38, size: 36)
                          : Image.network(
                              episode.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.movie_creation_outlined,
                                color: Colors.white38,
                                size: 36,
                              ),
                            ),
                    ),
                    const Center(
                      child: Icon(Icons.play_arrow_rounded,
                          color: Colors.white, size: 42),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: LinearProgressIndicator(
                        value: episode.watchedProgress.clamp(0.0, 1.0),
                        minHeight: 3,
                        backgroundColor: Colors.white24,
                        color: playedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${episode.number}. ${episode.title}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (length.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                length,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
            if ((episode.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                episode.description!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
