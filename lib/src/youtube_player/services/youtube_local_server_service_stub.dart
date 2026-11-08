/// Browser fallback: YouTube is served by the browser iframe, not a local server.
class YouTubeLocalServerService {
  /// Browsers do not start a loopback server.
  String? get serverUrl => null;

  /// No loopback server runs in browsers.
  bool get isRunning => false;

  /// Returns null because browser playback does not use a local server.
  Future<String?> start() async => null;

  /// No native server resources need to be released in browsers.
  void stop() {}
}
