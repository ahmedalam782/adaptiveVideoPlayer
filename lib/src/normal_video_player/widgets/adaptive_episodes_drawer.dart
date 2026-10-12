import 'package:flutter/material.dart';
import '../../youtube_player/models/player_style_config.dart';
import '../../youtube_player/models/player_text_config.dart';
import '../models/video_episode.dart';
import 'responsive/responsive_episode_list_card.dart';
import 'responsive/responsive_episodes_rail.dart';

/// Episode list for Windows, web, and tablet.
///
/// [horizontal] is the rail used on a phone or tablet. Otherwise the list
/// width follows [maxWidth].
class ResponsiveEpisodesPanel extends StatefulWidget {
  final List<VideoEpisode> episodes;
  final VideoEpisode? currentEpisode;
  final ValueChanged<VideoEpisode>? onEpisodeSelected;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final VoidCallback? onClose;

  /// Horizontal episode rail used on phone and tablet.
  final bool horizontal;

  /// Caps the floating card so it stays inside smaller windows.
  final double? maxWidth;
  final double? maxHeight;

  const ResponsiveEpisodesPanel({
    super.key,
    required this.episodes,
    this.currentEpisode,
    this.onEpisodeSelected,
    this.styling,
    this.messages,
    this.onClose,
    this.horizontal = false,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  State<ResponsiveEpisodesPanel> createState() => _ResponsiveEpisodesPanelState();
}

/// Previous name. Prefer [ResponsiveEpisodesPanel].
typedef AdaptiveEpisodesDrawer = ResponsiveEpisodesPanel;

class _ResponsiveEpisodesPanelState extends State<ResponsiveEpisodesPanel>
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
  void didUpdateWidget(covariant ResponsiveEpisodesPanel oldWidget) {
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

    if (widget.horizontal) {
      return ResponsiveEpisodesRail(
        episodes: widget.episodes,
        currentEpisode: widget.currentEpisode ?? _selectedEpisode,
        onEpisodeSelected: (episode) {
          setState(() => _selectedEpisode = episode);
          widget.onEpisodeSelected?.call(episode);
        },
        styling: widget.styling,
        messages: widget.messages,
        onClose: widget.onClose,
      );
    }

    return Directionality(
      textDirection: textDirection,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: widget.maxWidth ?? 440,
          constraints: BoxConstraints(maxHeight: widget.maxHeight ?? 520),
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

                    return ResponsiveEpisodeListCard(
                      episode: ep,
                      isCurrent: isCurrent,
                      isRtl: isRtl,
                      playedColor: widget.styling?.progressBarPlayedColor ??
                          const Color(0xFFE50914),
                      nowPlayingText: widget.messages?.nowPlayingText ??
                          (isRtl ? 'يعرض الآن' : 'Now Playing'),
                      wave: _waveController,
                      onTap: () {
                        setState(() => _selectedEpisode = ep);
                        widget.onEpisodeSelected?.call(ep);
                      },
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
}
