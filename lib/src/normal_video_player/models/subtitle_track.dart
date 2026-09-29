/// Represents a subtitle or closed caption track (SRP)
class SubtitleTrack {
  final String id;
  final String title;

  /// The subtitle raw content (srt or vtt format)
  final String? content;

  /// A callback to fetch the content if not provided upfront
  final Future<String> Function()? fetcher;

  const SubtitleTrack({
    required this.id,
    required this.title,
    this.content,
    this.fetcher,
  });
}
