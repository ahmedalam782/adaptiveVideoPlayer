/// Platform initialization stub for non-IO platforms (Web).
class AdaptiveVideoPlayerPlatform {
  AdaptiveVideoPlayerPlatform._();

  /// Ensures that the video player platform backends are initialized.
  ///
  /// On Web, this is a no-op since video playback is handled natively by the browser.
  static void ensureInitialized() {}
}
