import 'dart:async';
import 'package:flutter/material.dart';

/// Builder callback for customizable volume feedback indicator UI
typedef VolumeFeedbackBuilder = Widget Function(
    BuildContext context, double volume);

/// Reusable mixin for handling temporary volume HUD feedback overlays with full customization.
mixin VolumeFeedbackMixin<T extends StatefulWidget> on State<T> {
  double? feedbackVolume;
  Timer? _volumeFeedbackTimer;

  Duration _customVolumeFeedbackTimeout = const Duration(milliseconds: 1200);

  /// Duration to show the volume indicator - can be read or changed at runtime
  Duration get volumeFeedbackTimeout => _customVolumeFeedbackTimeout;
  set volumeFeedbackTimeout(Duration duration) =>
      _customVolumeFeedbackTimeout = duration;

  @override
  void dispose() {
    _volumeFeedbackTimer?.cancel();
    super.dispose();
  }

  /// Show volume feedback indicator for [volume] (0.0 to 1.0)
  void showVolumeFeedback(double volume, [Duration? customTimeout]) {
    _volumeFeedbackTimer?.cancel();
    setState(() {
      feedbackVolume = volume.clamp(0.0, 1.0);
    });
    _volumeFeedbackTimer =
        Timer(customTimeout ?? volumeFeedbackTimeout, () {
      if (mounted) {
        setState(() {
          feedbackVolume = null;
        });
      }
    });
  }

  /// Immediately dismiss volume feedback
  void hideVolumeFeedback() {
    _volumeFeedbackTimer?.cancel();
    if (feedbackVolume != null) {
      setState(() {
        feedbackVolume = null;
      });
    }
  }

  /// Helper to build either user-provided custom widget or the default volume HUD
  Widget buildVolumeFeedback(
    BuildContext context, {
    VolumeFeedbackBuilder? customBuilder,
    Color? backgroundColor,
    Color? iconColor,
    Color? progressColor,
  }) {
    if (feedbackVolume == null) return const SizedBox.shrink();
    if (customBuilder != null) {
      return customBuilder(context, feedbackVolume!);
    }
    return DefaultVolumeFeedbackWidget(
      volume: feedbackVolume!,
      backgroundColor: backgroundColor,
      iconColor: iconColor,
      progressColor: progressColor,
    );
  }
}

/// Customizable default HUD widget for displaying volume feedback overlays
class DefaultVolumeFeedbackWidget extends StatelessWidget {
  final double volume;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? progressColor;
  final TextStyle? textStyle;

  const DefaultVolumeFeedbackWidget({
    super.key,
    required this.volume,
    this.backgroundColor,
    this.iconColor,
    this.progressColor,
    this.textStyle,
  });

  IconData get _icon {
    if (volume == 0) return Icons.volume_off;
    if (volume < 0.5) return Icons.volume_down;
    return Icons.volume_up;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.black87,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, color: iconColor ?? Colors.white, size: 24),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: volume,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressColor ?? Colors.red,
                  ),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(volume * 100).toInt()}%',
              style: textStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
