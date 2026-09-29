/// Type of video source being played.
enum VideoSourceType {
  network,
  file,
  bytes,
  youtube,
  dataUrl;

  /// Detects source type based on input parameters
  static VideoSourceType detect({
    required String source,
    bool isFile = false,
    bool isBytes = false,
    bool isYouTube = false,
  }) {
    if (isBytes) return VideoSourceType.bytes;
    if (isFile) return VideoSourceType.file;
    if (isYouTube) return VideoSourceType.youtube;
    if (source.startsWith('data:')) return VideoSourceType.dataUrl;
    return VideoSourceType.network;
  }
}
