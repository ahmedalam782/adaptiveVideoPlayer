import '../../youtube_player/utils/duration_formatter.dart';

/// Extension methods for [Duration] providing clean, readable time formatting.
extension PlayerDurationExtensions on Duration {
  /// Format duration to MM:SS or HH:MM:SS
  String formatTime() {
    return durationFormatter(inMilliseconds);
  }

  /// Calculate remaining duration relative to [totalDuration]
  Duration remainingFrom(Duration totalDuration) {
    if (this >= totalDuration) return Duration.zero;
    return totalDuration - this;
  }

  /// Calculate percentage progress (0.0 to 1.0) relative to [totalDuration]
  double progressRatio(Duration totalDuration) {
    if (totalDuration.inMilliseconds <= 0) return 0.0;
    return (inMilliseconds / totalDuration.inMilliseconds).clamp(0.0, 1.0);
  }
}

/// Extension methods for [int] milliseconds
extension IntDurationExtensions on int {
  /// Format milliseconds directly to MM:SS or HH:MM:SS string
  String formatAsDuration() {
    return durationFormatter(this);
  }
}
