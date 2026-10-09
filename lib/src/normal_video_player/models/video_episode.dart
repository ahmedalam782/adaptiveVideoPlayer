/// Model representing a video episode in a series/season (SRP).
class VideoEpisode {
  /// Unique identifier for the episode
  final String id;

  /// Episode number (e.g., 1, 2, 6)
  final int number;

  /// Episode title (e.g., 'ذرة من الحقيقة', 'صديقتي العزيزة...')
  final String title;

  /// Optional synopsis / description of the episode
  final String? description;

  /// Optional thumbnail URL or asset path
  final String? thumbnailUrl;

  /// Total duration of the episode
  final Duration? duration;

  /// Watched progress fraction between 0.0 and 1.0 (for the red progress indicator)
  final double watchedProgress;

  /// Direct video playback URL for this episode
  final String? videoUrl;

  /// Additional custom metadata
  final Map<String, dynamic>? extra;

  const VideoEpisode({
    required this.id,
    required this.number,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.duration,
    this.watchedProgress = 0.0,
    this.videoUrl,
    this.extra,
  });

  VideoEpisode copyWith({
    String? id,
    int? number,
    String? title,
    String? description,
    String? thumbnailUrl,
    Duration? duration,
    double? watchedProgress,
    String? videoUrl,
    Map<String, dynamic>? extra,
  }) {
    return VideoEpisode(
      id: id ?? this.id,
      number: number ?? this.number,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      watchedProgress: watchedProgress ?? this.watchedProgress,
      videoUrl: videoUrl ?? this.videoUrl,
      extra: extra ?? this.extra,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoEpisode &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          number == other.number;

  @override
  int get hashCode => id.hashCode ^ number.hashCode;
}
