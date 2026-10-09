import 'package:flutter/material.dart';
import '../../youtube_player/models/player_style_config.dart';
import '../../youtube_player/models/player_text_config.dart';
import '../models/video_episode.dart';

/// Episodes drawer / popup matching Netflix's series episode selector (Image 5).
class AdaptiveEpisodesDrawer extends StatefulWidget {
  final List<VideoEpisode> episodes;
  final VideoEpisode? currentEpisode;
  final ValueChanged<VideoEpisode>? onEpisodeSelected;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final VoidCallback? onClose;

  const AdaptiveEpisodesDrawer({
    super.key,
    required this.episodes,
    this.currentEpisode,
    this.onEpisodeSelected,
    this.styling,
    this.messages,
    this.onClose,
  });

  @override
  State<AdaptiveEpisodesDrawer> createState() => _AdaptiveEpisodesDrawerState();
}

class _AdaptiveEpisodesDrawerState extends State<AdaptiveEpisodesDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  VideoEpisode? _selectedEpisode;

  @override
  void initState() {
    super.initState();
    _selectedEpisode = widget.currentEpisode ?? widget.episodes.firstOrNull;
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant AdaptiveEpisodesDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentEpisode != oldWidget.currentEpisode) {
      _selectedEpisode = widget.currentEpisode;
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = widget.messages?.resolveTextDirection(context) ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;
    final isRtl = textDirection == TextDirection.rtl;

    return Directionality(
      textDirection: textDirection,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 440,
          constraints: const BoxConstraints(maxHeight: 520),
          decoration: BoxDecoration(
            color: widget.styling?.settingsBackgroundColor ??
                const Color(0xF2181818),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.75),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.messages?.episodesText ??
                          (isRtl ? 'الحلقات' : 'Episodes'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.onClose != null)
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white70, size: 20),
                        onPressed: widget.onClose,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),

              // Episodes List
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: widget.episodes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final ep = widget.episodes[index];
                    final isCurrent = _selectedEpisode?.id == ep.id ||
                        (_selectedEpisode == null && index == 0);

                    return _buildEpisodeCard(
                      episode: ep,
                      isCurrent: isCurrent,
                      isRtl: isRtl,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodeCard({
    required VideoEpisode episode,
    required bool isCurrent,
    required bool isRtl,
  }) {
    final playedColor =
        widget.styling?.progressBarPlayedColor ?? const Color(0xFFE50914);

    return InkWell(
      onTap: () {
        setState(() => _selectedEpisode = episode);
        widget.onEpisodeSelected?.call(episode);
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrent
              ? const Color(0xFF2B2B2B)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: isCurrent
              ? Border.all(color: Colors.white, width: 1.5)
              : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row with Number, Title, and Progress Bar
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
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Watched progress bar line
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

            // Expanded card for currently active episode
            if (isCurrent) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Synopsis / Description
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

                  // Thumbnail with "Now Playing" badge
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
                      // "يعرض الآن" (Now Playing) Overlay Badge
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
                              widget.messages?.nowPlayingText ??
                                  (isRtl ? 'يعرض الآن' : 'Now Playing'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            _buildAnimatedEqualizer(),
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

  Widget _buildAnimatedEqualizer() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(0.4 + (_waveController.value * 0.6)),
            const SizedBox(width: 1.5),
            _buildBar(1.0 - (_waveController.value * 0.7)),
            const SizedBox(width: 1.5),
            _buildBar(0.3 + (_waveController.value * 0.7)),
          ],
        );
      },
    );
  }

  Widget _buildBar(double heightFactor) {
    return Container(
      width: 2,
      height: 10 * heightFactor.clamp(0.2, 1.0),
      decoration: BoxDecoration(
        color: const Color(0xFF00A3FF), // Sleek equalizer blue
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
