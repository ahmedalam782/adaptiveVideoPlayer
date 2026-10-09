import 'package:flutter/material.dart';

import '../../youtube_player/models/youtube_player_config.dart';
import '../utils/video_player_web_safe.dart';

/// A Netflix-inspired circular percentage loading and buffering indicator.
///
/// Features a vivid red circular progress arc with rounded caps ([StrokeCap.round])
/// and a centered, bold percentage readout (e.g. `77%`).
///
/// Can dynamically calculate buffer completion from a provided [VideoPlayerController],
/// accept an explicit [progress] (between `0.0` and `1.0`), or smoothly progress an
/// animated loading state.
class AdaptiveCircularPercentageLoader extends StatefulWidget {
  /// Explicit progress value between `0.0` and `1.0`.
  /// If provided, this value overrides automatic calculation.
  final double? progress;

  /// Optional video player controller to dynamically calculate buffer percentage.
  final VideoPlayerController? controller;

  /// Player visual styling configuration.
  final PlayerStyleConfig? styling;

  /// Color for the circular progress arc. Defaults to [styling?.loadingIndicatorColor] or Netflix red (`Color(0xFFE50914)`).
  final Color? color;

  /// Outer diameter of the circular indicator. Defaults to [styling?.loadingIndicatorSize] or `56.0`.
  final double? size;

  /// Stroke width for the circular arc. Defaults to [styling?.loadingIndicatorStrokeWidth] or `4.0`.
  final double? strokeWidth;

  /// Whether to show the percentage text in the center. Defaults to `true`.
  final bool showPercentage;

  /// Custom text style for the percentage text in the center.
  final TextStyle? textStyle;

  /// Optional background track color for the uncompleted portion of the circle.
  final Color? backgroundColor;

  /// Whether to rotate the arc around the center. Defaults to `true`.
  final bool rotateArc;

  const AdaptiveCircularPercentageLoader({
    super.key,
    this.progress,
    this.controller,
    this.styling,
    this.color,
    this.size,
    this.strokeWidth,
    this.showPercentage = true,
    this.textStyle,
    this.backgroundColor,
    this.rotateArc = true,
  });

  @override
  State<AdaptiveCircularPercentageLoader> createState() =>
      _AdaptiveCircularPercentageLoaderState();
}

class _AdaptiveCircularPercentageLoaderState
    extends State<AdaptiveCircularPercentageLoader>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _simulatedProgressController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.rotateArc) {
      _rotationController.repeat();
    }

    _simulatedProgressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _simulatedProgressController.repeat(reverse: true);

    try {
      widget.controller?.addListener(_onControllerUpdate);
    } catch (_) {}
  }

  @override
  void didUpdateWidget(AdaptiveCircularPercentageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      try {
        oldWidget.controller?.removeListener(_onControllerUpdate);
      } catch (_) {}
      try {
        widget.controller?.addListener(_onControllerUpdate);
      } catch (_) {}
    }
    if (oldWidget.rotateArc != widget.rotateArc) {
      if (widget.rotateArc) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    try {
      widget.controller?.removeListener(_onControllerUpdate);
    } catch (_) {}
    _rotationController.dispose();
    _simulatedProgressController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  int _resolvePercentage() {
    if (widget.progress != null) {
      return (widget.progress! * 100).round().clamp(0, 100);
    }

    final controller = widget.controller;
    if (controller != null && controller.value.isInitialized) {
      final value = controller.value;
      final position = value.position;

      // Look for buffered range covering current position
      for (final range in value.buffered) {
        if (range.start <= position && range.end >= position) {
          final ahead = range.end - position;
          const targetBufferMs = 3500;
          return ((ahead.inMilliseconds / targetBufferMs) * 100)
              .round()
              .clamp(1, 99);
        }
      }

      // If buffer range is ahead
      for (final range in value.buffered) {
        if (range.start > position) {
          final ahead = range.end - position;
          const targetBufferMs = 3500;
          return ((ahead.inMilliseconds / targetBufferMs) * 100)
              .round()
              .clamp(1, 99);
        }
      }
    }

    // Dynamic simulated loading percentage based on smooth ticker (15% to 95%)
    final animVal = _simulatedProgressController.value;
    return (15 + (animVal * 80)).round().clamp(1, 99);
  }

  double _resolveArcProgress() {
    if (widget.progress != null) {
      return widget.progress!.clamp(0.05, 1.0);
    }
    final pct = _resolvePercentage();
    return (pct / 100.0).clamp(0.05, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSize =
        widget.size ?? widget.styling?.loadingIndicatorSize ?? 56.0;
    final effectiveColor = widget.color ??
        widget.styling?.loadingIndicatorColor ??
        const Color(0xFFE50914);
    final effectiveStrokeWidth = widget.strokeWidth ??
        widget.styling?.loadingIndicatorStrokeWidth ??
        4.0;
    final effectiveBgColor = widget.backgroundColor ??
        widget.styling?.loadingIndicatorBackgroundColor ??
        Colors.transparent;
    final showPercentage = widget.showPercentage &&
        (widget.styling?.showLoadingPercentage ?? true);

    return AnimatedBuilder(
      animation: _simulatedProgressController,
      builder: (context, _) {
        final percentage = _resolvePercentage();
        final arcProgress = _resolveArcProgress();

        final fontSize = (effectiveSize * 0.24).clamp(10.0, 20.0);
        final effectiveTextStyle = widget.textStyle ??
            widget.styling?.loadingIndicatorTextStyle ??
            TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
              shadows: const [
                Shadow(
                  color: Color(0x99000000),
                  blurRadius: 4.0,
                  offset: Offset(0, 1),
                ),
              ],
            );

        Widget arc = SizedBox(
          width: effectiveSize,
          height: effectiveSize,
          child: CircularProgressIndicator(
            value: arcProgress,
            color: effectiveColor,
            strokeWidth: effectiveStrokeWidth,
            strokeCap: StrokeCap.round,
            backgroundColor: effectiveBgColor,
          ),
        );

        if (widget.rotateArc) {
          arc = RotationTransition(
            turns: _rotationController,
            child: arc,
          );
        }

        return SizedBox(
          width: effectiveSize,
          height: effectiveSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              arc,
              if (showPercentage)
                Text(
                  '$percentage%',
                  style: effectiveTextStyle,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        );
      },
    );
  }
}
