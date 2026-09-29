/// Represents a chapter marker on the video timeline (similar to YouTube chapters).
class VideoChapter {
  /// Display title of the chapter (e.g. "Introduction", "Key Concepts").
  final String title;

  /// Timestamp where this chapter begins.
  final Duration startTime;

  const VideoChapter({
    required this.title,
    required this.startTime,
  });

  /// Finds the active [VideoChapter] for a given playback [position].
  static VideoChapter? findChapterAt(
    List<VideoChapter>? chapters,
    Duration position,
  ) {
    if (chapters == null || chapters.isEmpty) return null;
    VideoChapter? active;
    for (final chapter in chapters) {
      if (position >= chapter.startTime) {
        if (active == null || chapter.startTime >= active.startTime) {
          active = chapter;
        }
      }
    }
    return active;
  }
}
