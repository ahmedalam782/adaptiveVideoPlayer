import 'package:flutter/material.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../models/video_chapter.dart';
import '../utils/video_player_web_safe.dart';
import 'adaptive_video_surface.dart';
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

  VideoPlayerController? _previewController;
  bool _isInitializingPreview = false;
  bool _isSeekingPreview = false;
  Duration? _pendingSeekDuration;
  int _lastSeekedMs = -10000;

  @override
  void didUpdateWidget(covariant AdaptiveProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller.dataSource != widget.controller.dataSource) {
      _disposePreviewController();
    }
  }

  @override
  void dispose() {
    _disposePreviewController();
    super.dispose();
  }

  void _disposePreviewController() {
    final ctrl = _previewController;
    _previewController = null;
    _isInitializingPreview = false;
    _isSeekingPreview = false;
    _pendingSeekDuration = null;
    _lastSeekedMs = -10000;
    ctrl?.dispose();
  }

  Future<void> _ensurePreviewController(Duration initialTarget) async {
    if (_previewController != null || _isInitializingPreview) return;
    final mainCtrl = widget.controller;
    if (!mainCtrl.value.isInitialized ||
        mainCtrl.value.duration <= Duration.zero ||
        mainCtrl.dataSource.isEmpty ||
        mainCtrl.dataSourceType != DataSourceType.network) {
      return;
    }

    final uri = Uri.tryParse(mainCtrl.dataSource);
    if (uri == null) return;

    _isInitializingPreview = true;
    final previewCtrl = VideoPlayerController.networkUrl(
      uri,
      httpHeaders: mainCtrl.httpHeaders,
    );

    try {
      await previewCtrl.initialize();
      if (!mounted || mainCtrl.dataSource != widget.controller.dataSource) {
        await previewCtrl.dispose();
        return;
      }
      await previewCtrl.setVolume(0.0);
      _previewController = previewCtrl;
      _isInitializingPreview = false;
      final target = _pendingSeekDuration ?? initialTarget;
      _requestPreviewSeek(target, force: true);
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      _isInitializingPreview = false;
      await previewCtrl.dispose();
    }
  }

  void _requestPreviewSeek(Duration target, {bool force = false}) {
    _pendingSeekDuration = target;
    if (_previewController == null) {
      _ensurePreviewController(target);
      return;
    }
    if (!_previewController!.value.isInitialized) return;
    if (!force && (target.inMilliseconds - _lastSeekedMs).abs() < 400) {
      return;
    }
    _drainPreviewSeekQueue();
  }

  Future<void> _drainPreviewSeekQueue() async {
    if (_isSeekingPreview) return;
    _isSeekingPreview = true;
    try {
      while (mounted &&
          _previewController != null &&
          _previewController!.value.isInitialized &&
          _pendingSeekDuration != null) {
        final nextTarget = _pendingSeekDuration!;
        _pendingSeekDuration = null;
        if ((nextTarget.inMilliseconds - _lastSeekedMs).abs() < 250 &&
            _lastSeekedMs >= 0) {
          continue;
        }
        _lastSeekedMs = nextTarget.inMilliseconds;
        await _previewController!.seekTo(nextTarget);
        if (mounted) {
          setState(() {});
        }
      }
    } catch (_) {
      // Ignore transient seek errors on rapid scrubbing
    } finally {
      _isSeekingPreview = false;
    }
  }

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
    final durationMs = widget.controller.value.duration.inMilliseconds;
    if (durationMs > 0) {
      final target = Duration(milliseconds: (fraction * durationMs).round());
      _requestPreviewSeek(target);
    }
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

        final activePreviewCtrl = (_previewController != null &&
                _previewController!.value.isInitialized)
            ? _previewController
            : null;

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const thumbWidth = 132.0;
                const thumbHeight = 74.0;
                const horizontalInset = 12.0;
                final trackWidth = (constraints.maxWidth - horizontalInset * 2)
                    .clamp(1.0, double.infinity);
                final previewX = previewFraction != null
                    ? horizontalInset + previewFraction * trackWidth
                    : 0.0;
                final tooltipLeft = (previewX - thumbWidth / 2).clamp(
                  0.0,
                  (constraints.maxWidth - thumbWidth)
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
                        if (previewDuration != null || activePreviewCtrl != null)
                          Positioned(
                            top: activePreviewCtrl != null
                                ? (previewChapter != null ? -118 : -102)
                                : (previewChapter != null ? -48 : -32),
                            left: tooltipLeft,
                            child: Offstage(
                              offstage: previewDuration == null,
                              child: IgnorePointer(
                                child: SizedBox(
                                  width: thumbWidth,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (activePreviewCtrl != null) ...[
                                        Container(
                                          width: thumbWidth,
                                          height: thumbHeight,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.6,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.55),
                                                blurRadius: 10,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6.4),
                                            child: FittedBox(
                                              fit: BoxFit.cover,
                                              clipBehavior: Clip.hardEdge,
                                              child: SizedBox(
                                                width: activePreviewCtrl
                                                            .value.size.width >
                                                        0
                                                    ? activePreviewCtrl
                                                        .value.size.width
                                                    : 320,
                                                height: activePreviewCtrl
                                                            .value.size.height >
                                                        0
                                                    ? activePreviewCtrl
                                                        .value.size.height
                                                    : 180,
                                                child: VideoPlayer(
                                                  activePreviewCtrl,
                                                  key: AdaptiveVideoSurface
                                                      .keyForController(
                                                    activePreviewCtrl,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                      ],
                                      if (previewDuration != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xCC000000),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (previewChapter != null)
                                                Text(
                                                  previewChapter.title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              Text(
                                                _formatPreviewTime(
                                                    previewDuration),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
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
                            onChanged: (val) {
                              if (duration > 0) {
                                _requestPreviewSeek(
                                  Duration(milliseconds: val.round()),
                                );
                              }
                              widget.onDragChanged(val);
                            },
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
