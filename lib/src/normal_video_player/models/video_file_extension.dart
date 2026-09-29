/// Supported video file extensions and container formats.
enum VideoFileExtension {
  mp4('.mp4', mimeType: 'video/mp4'),
  mov('.mov', mimeType: 'video/quicktime'),
  avi('.avi', mimeType: 'video/x-msvideo'),
  mkv('.mkv', mimeType: 'video/x-matroska'),
  webm('.webm', mimeType: 'video/webm'),
  m4v('.m4v', mimeType: 'video/x-m4v'),
  threeGp('.3gp', mimeType: 'video/3gpp'),
  flv('.flv', mimeType: 'video/x-flv'),
  wmv('.wmv', mimeType: 'video/x-ms-wmv'),
  m9v('.m9v', mimeType: 'video/m9v'),
  hls('.m3u8', mimeType: 'application/x-mpegURL', isStreaming: true),
  dash('.mpd', mimeType: 'application/dash+xml', isStreaming: true);

  final String extension;
  final String mimeType;
  final bool isStreaming;

  const VideoFileExtension(
    this.extension, {
    required this.mimeType,
    this.isStreaming = false,
  });

  /// Checks if a given path or URL matches this video extension
  bool matches(String pathOrUrl) {
    final clean = pathOrUrl.split('?').first.split('#').first.toLowerCase();
    return clean.endsWith(extension);
  }

  /// Finds matching VideoFileExtension from path or URL
  static VideoFileExtension? fromPath(String pathOrUrl) {
    final clean = pathOrUrl.split('?').first.split('#').first.toLowerCase();
    for (final ext in VideoFileExtension.values) {
      if (clean.endsWith(ext.extension)) {
        return ext;
      }
    }
    return null;
  }

  /// Whether a path or URL has a recognized video extension
  static bool isSupported(String pathOrUrl) {
    return fromPath(pathOrUrl) != null;
  }

  /// Set of all supported file extensions
  static Set<String> get supportedExtensions =>
      VideoFileExtension.values.map((f) => f.extension).toSet();
}
