/// Represents a video stream quality/resolution (e.g. 1080p, 720p, Auto) (SRP)
class VideoQuality {
  final String title;
  final String url;

  /// Whether this specific quality/source is a live stream
  final bool isLive;

  const VideoQuality({
    required this.title,
    required this.url,
    this.isLive = false,
  });
}
