import 'package:flutter/material.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../models/video_chapter.dart';
import '../utils/video_player_web_safe.dart';
import 'buffer_slider.dart';

/// Progress bar slider for video scrubbing with gradient track, buffered progress, chapters, and YouTube-style hover timestamp tooltip.
class AdaptiveProgressBar extends StatefulWidget {
  final VideoPlayerController controller;
  final double? dragPosition;
  final ValueChanged<double> onDragChanged;
  final ValueChanged<double> onDragEnd;
  final PlayerStyleConfig? styling;
  final List<VideoChapter>? chapters;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;

  const AdaptiveProgressBar({
    super.key,
    required this.controller,
    required this.dragPosition,
    required this.onDragChanged,
    required this.onDragEnd,
    this.styling,
    this.chapters,
    this.onAnalyticsEvent,
  });

  @override
  State<AdaptiveProgressBar> createState() => _AdaptiveProgressBarState();
}

class _AdaptiveProgressBarState extends State<AdaptiveProgressBar> {
  bool _isHovered = false;
  double? _hoverFraction;

  String _formatPreviewTime(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  void _updateHoverPosition(Offset localPosition, double maxWidth) {
    const horizontalInset = 12.0;
    final effectiveWidth =
        (maxWidth - horizontalInset * 2).clamp(1.0, double.infinity);
    final fraction = ((localPosition.dx - horizontalInset) / effectiveWidth)
        .clamp(0.0, 1.0);
    setState(() {
      _isHovered = true;
      _hoverFraction = fraction;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, VideoPlayerValue value, child) {
        final duration = value.duration.inMilliseconds.toDouble();
        final position =
            widget.dragPosition ?? value.position.inMilliseconds.toDouble();

        final playedColor =
            widget.styling?.progressBarPlayedColor ?? const Color(0xFFFF0033);
        final handleColor =
            widget.styling?.progressBarHandleColor ?? const Color(0xFFFF0033);

        final isInteracting = _isHovered || widget.dragPosition != null;
        final double? previewFraction =
            widget.dragPosition != null && duration > 0
                ? (widget.dragPosition! / duration).clamp(0.0, 1.0)
                : (_isHovered ? _hoverFraction : null);
        final Duration? previewDuration =
            previewFraction != null && duration > 0
                ? Duration(milliseconds: (previewFraction * duration).round())
                : null;
        final VideoChapter? previewChapter = previewDuration != null
            ? VideoChapter.findChapterAt(widget.chapters, previewDuration)
            : null;

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final pillWidth = previewChapter != null ? 130.0 : 56.0;
                const horizontalInset = 12.0;
                final trackWidth = (constraints.maxWidth - horizontalInset * 2)
                    .clamp(1.0, double.infinity);
                final previewX = previewFraction != null
                    ? horizontalInset + previewFraction * trackWidth
                    : 0.0;
                final tooltipLeft = (previewX - pillWidth / 2).clamp(
                  0.0,
                  (constraints.maxWidth - pillWidth)
                      .clamp(0.0, double.infinity),
                );

                return MouseRegion(
                  onEnter: (event) => _updateHoverPosition(
                      event.localPosition, constraints.maxWidth),
                  onHover: (event) => _updateHoverPosition(
                      event.localPosition, constraints.maxWidth),
                  onExit: (_) => setState(() {
                    _isHovered = false;
                    _hoverFraction = null;
                  }),
                  child: SizedBox(
                    height: 22,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        if (previewDuration != null)
                          Positioned(
                            top: previewChapter != null ? -42 : -28,
                            left: tooltipLeft,
                            child: IgnorePointer(
                              child: Container(
                                width: pillWidth,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xD9000000),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    width: 0.8,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (previewChapter != null)
                                      Text(
                                        previewChapter.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    Text(
                                      _formatPreviewTime(previewDuration),
                                      style: TextStyle(
                                        color: previewChapter != null
                                            ? Colors.white70
                                            : Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: isInteracting ? 5.5 : 3.5,
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: isInteracting ? 7.5 : 6.0,
                              pressedElevation: 4.0,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12.0,
                            ),
                            activeTrackColor: playedColor,
                            inactiveTrackColor:
                                Colors.white.withValues(alpha: 0.22),
                            thumbColor: handleColor,
                            trackShape: GradientSliderTrackShape(
                              gradient: LinearGradient(
                                colors: [playedColor, handleColor],
                              ),
                              buffered: value.buffered,
                              duration: value.duration,
                              hoverFraction:
                                  _isHovered ? _hoverFraction : null,
                              chapters: widget.chapters,
                            ),
                          ),
                          child: Slider(
                            value: position.clamp(
                                0.0, duration > 0 ? duration : 0.0),
                            min: 0.0,
                            max: duration > 0 ? duration : 0.0,
                            onChanged: widget.onDragChanged,
                            onChangeEnd: (newPosition) {
                              widget.onDragEnd(newPosition);
                              widget.onAnalyticsEvent?.call('video_seek', {
                                'to_position': (newPosition / 1000).round(),
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
