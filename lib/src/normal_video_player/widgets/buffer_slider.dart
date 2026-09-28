import 'package:flutter/material.dart';
import '../utils/video_player_web_safe.dart';

/// Custom painter for rendering buffered video progress ranges (SRP)
class BufferPainter extends CustomPainter {
  final List<DurationRange> buffered;
  final Duration duration;
  final TextDirection textDirection;

  BufferPainter(
    this.buffered,
    this.duration, {
    this.textDirection = TextDirection.ltr,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (duration.inMilliseconds == 0) return;

    final paint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.fill;

    for (final range in buffered) {
      final startFraction =
          (range.start.inMilliseconds / duration.inMilliseconds)
              .clamp(0.0, 1.0);
      final endFraction =
          (range.end.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
      final double startX;
      final double endX;
      if (textDirection == TextDirection.rtl) {
        startX = size.width * (1.0 - endFraction);
        endX = size.width * (1.0 - startFraction);
      } else {
        startX = size.width * startFraction;
        endX = size.width * endFraction;
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(startX, size.height / 2 - 1, endX, size.height / 2 + 1),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BufferPainter oldDelegate) {
    return oldDelegate.buffered != buffered ||
        oldDelegate.duration != duration ||
        oldDelegate.textDirection != textDirection;
  }
}

/// Track shape for YouTube-style progress slider with buffered progress and red active bar
class GradientSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  const GradientSliderTrackShape({
    this.gradient = const LinearGradient(
      colors: [Color(0xFFFF0033), Color(0xFFFF0033)],
    ),
    this.buffered = const [],
    this.duration = Duration.zero,
  });

  final LinearGradient gradient;
  final List<DurationRange> buffered;
  final Duration duration;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);

    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final radius = Radius.circular(trackRect.height / 2);

    // 1. Draw full inactive background track
    final Paint inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor!;
    if (trackRect.width > 0) {
      context.canvas.drawRRect(
        RRect.fromRectAndRadius(trackRect, radius),
        inactivePaint,
      );
    }

    // 2. Draw buffered ranges (YouTube light grey bar)
    if (duration.inMilliseconds > 0 && buffered.isNotEmpty) {
      final Paint bufferPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.fill;

      for (final range in buffered) {
        final startFraction =
            (range.start.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0);
        final endFraction =
            (range.end.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0);
        final double startX;
        final double endX;
        if (textDirection == TextDirection.rtl) {
          startX = trackRect.right - endFraction * trackRect.width;
          endX = trackRect.right - startFraction * trackRect.width;
        } else {
          startX = trackRect.left + startFraction * trackRect.width;
          endX = trackRect.left + endFraction * trackRect.width;
        }
        if (endX > startX) {
          context.canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTRB(startX, trackRect.top, endX, trackRect.bottom),
              radius,
            ),
            bufferPaint,
          );
        }
      }
    }

    // 3. Draw active played track
    final Rect activeTrackRect = textDirection == TextDirection.rtl
        ? Rect.fromLTRB(
            thumbCenter.dx, trackRect.top, trackRect.right, trackRect.bottom)
        : Rect.fromLTRB(
            trackRect.left, trackRect.top, thumbCenter.dx, trackRect.bottom);
    final Paint activePaint = Paint()
      ..shader = gradient.createShader(trackRect);

    if (activeTrackRect.width > 0) {
      context.canvas.drawRRect(
        RRect.fromRectAndRadius(activeTrackRect, radius),
        activePaint,
      );
    }
  }
}
