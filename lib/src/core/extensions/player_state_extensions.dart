import '../../youtube_player/cubit/youtube_player_state.dart';
import '../models/player_state.dart';
import 'player_duration_extensions.dart';

/// Extension methods on [PlayerState] for UI convenience
extension UnifiedPlayerStateExtensions on PlayerState {
  /// Remaining time in video
  Duration get remainingDuration =>
      duration > position ? duration - position : Duration.zero;

  /// Progress as a normalized value from 0.0 to 1.0
  double get progressRatio =>
      duration.inMilliseconds > 0
          ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
          : 0.0;

  /// Formatted position string (MM:SS or HH:MM:SS)
  String get formattedPosition => position.formatTime();

  /// Formatted duration string (MM:SS or HH:MM:SS)
  String get formattedDuration => duration.formatTime();

  /// Formatted remaining time string
  String get formattedRemaining => remainingDuration.formatTime();
}

/// Extension methods on [PlayerCubitState] for unified convenience & conversion
extension PlayerCubitStateExtensions on PlayerCubitState {
  /// Remaining time in video
  Duration get remainingDuration =>
      duration > position ? duration - position : Duration.zero;

  /// Progress as a normalized value from 0.0 to 1.0
  double get progressRatio =>
      duration.inMilliseconds > 0
          ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
          : 0.0;

  /// Formatted position string
  String get formattedPosition => position.formatTime();

  /// Formatted duration string
  String get formattedDuration => duration.formatTime();

  /// Formatted remaining time string
  String get formattedRemaining => remainingDuration.formatTime();

  /// Whether state contains an error
  bool get hasError => errorMessage != null;

  /// Convert to unified immutable [PlayerState] model
  PlayerState toUnifiedState({bool isLive = false}) {
    return PlayerState(
      position: position,
      duration: duration,
      isPlaying: isPlaying,
      isMuted: isMuted,
      volume: isMuted ? 0.0 : 1.0,
      isReady: isReady,
      hasError: hasError,
      errorMessage: errorMessage,
      isLive: isLive,
    );
  }
}
