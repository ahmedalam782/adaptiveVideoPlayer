import 'dart:math' as math;

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

    final textDirection =
        widget.messages?.resolveTextDirection(context) ??
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
    final selectedSeason =
        (_activeSeason != null && seasons.contains(_activeSeason))
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
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
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
                            horizontal: 14,
                            vertical: 8,
                          ),
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
                              const Icon(
                                Icons.expand_more_rounded,
                                color: Colors.white,
                              ),
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
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: widget.onClose,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
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

  Widget _buildThumbnail() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          color: isCurrent ? const Color(0xFF3A3A3A) : const Color(0xFF242424),
          child: episode.thumbnailUrl == null
              ? const Icon(
                  Icons.movie_creation_outlined,
                  color: Colors.white38,
                  size: 32,
                )
              : Image.network(
                  episode.thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.movie_creation_outlined,
                    color: Colors.white38,
                    size: 32,
                  ),
                ),
        ),
        const Center(
          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final length = PlayerChromeUtils.clockLabel(episode.duration);
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final isCompact = availableHeight < 210;

        if (isCompact) {
          // Horizontal layout when vertical space is restricted (e.g. portrait phone).
          final thumbWidth = math.min(160.0, (availableHeight - 12) * 16 / 9);
          final cardWidth = math.max(260.0, thumbWidth + 140.0);

          return SizedBox(
            width: cardWidth,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrent
                        ? playedColor.withValues(alpha: 0.8)
                        : Colors.white10,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: thumbWidth,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: _buildThumbnail(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${episode.number}. ${episode.title}',
                            maxLines: availableHeight < 140 ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (length.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              length,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          if (availableHeight >= 140 &&
                              (episode.description ?? '').isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Flexible(
                              child: Text(
                                episode.description!,
                                maxLines: availableHeight < 165 ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 11,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Spacious layout: vertical stacked card for landscape / tablet / wide views.
        return SizedBox(
          width: 220,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isCurrent
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isCurrent
                      ? playedColor.withValues(alpha: 0.8)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _buildThumbnail(),
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
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if ((episode.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        episode.description!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
