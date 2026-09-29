import 'package:flutter/material.dart';
import '../utils/video_player_web_safe.dart';

/// Custom painter for rendering buffered video progress ranges (SRP)
class BufferPainter extends CustomPainter {
  final List<DurationRange> buffered;
  final Duration duration;

  BufferPainter(this.buffered, this.duration);

  @override
  void paint(Canvas canvas, Size size) {
    if (duration.inMilliseconds == 0) return;

    final paint = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.fill;

    for (final range in buffered) {
      final startX =
          (range.start.inMilliseconds / duration.inMilliseconds) * size.width;
      final endX =
          (range.end.inMilliseconds / duration.inMilliseconds) * size.width;

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
    return oldDelegate.buffered != buffered || oldDelegate.duration != duration;
  }
}

/// Gradient track shape for progress slider
class GradientSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  const GradientSliderTrackShape({
    this.gradient = const LinearGradient(
      colors: [Color(0xFFFF007F), Color(0xFF00E5FF)],
    ),
  });

  final LinearGradient gradient;

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

    final activeTrackRect = Rect.fromLTRB(
        trackRect.left, trackRect.top, thumbCenter.dx, trackRect.bottom);
    final inactiveTrackRect = Rect.fromLTRB(
        thumbCenter.dx, trackRect.top, trackRect.right, trackRect.bottom);

    final Paint activePaint = Paint()
      ..shader = gradient.createShader(trackRect);
    final Paint inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor!;

    if (inactiveTrackRect.width > 0) {
      context.canvas.drawRRect(
        RRect.fromRectAndRadius(
            inactiveTrackRect, Radius.circular(trackRect.height / 2)),
        inactivePaint,
      );
    }
    if (activeTrackRect.width > 0) {
      context.canvas.drawRRect(
        RRect.fromRectAndRadius(
            activeTrackRect, Radius.circular(trackRect.height / 2)),
        activePaint,
      );
    }
  }
}
