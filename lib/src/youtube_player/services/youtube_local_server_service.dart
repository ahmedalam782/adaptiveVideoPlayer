import 'dart:developer';
import 'dart:io';

import '../widgets/youtube_player_html.dart';

/// Service managing the local loopback HTTP server used by YouTube WebView on desktop/mobile.
///
/// Follows Single Responsibility Principle (SRP) by isolating socket/server
/// lifecycle management completely away from presentation widgets.
class YouTubeLocalServerService {
  HttpServer? _server;
  String? _serverUrl;

  /// Active local server URL (e.g. `http://127.0.0.1:54321`) or `null` if not running.
  String? get serverUrl => _serverUrl;

  /// Whether the HTTP server is currently bound and listening.
  bool get isRunning => _server != null;

  /// Starts the local HTTP server on a random available port and serves [kYouTubePlayerHtml].
  Future<String?> start() async {
    if (_server != null) return _serverUrl;
    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final port = _server!.port;
      log('YouTube local server started on port $port');

      _server!.listen((HttpRequest request) {
        request.response
          ..headers.contentType = ContentType.html
          ..headers.add('Access-Control-Allow-Origin', '*')
          ..headers.add('Referrer-Policy', 'strict-origin-when-cross-origin')
          ..write(kYouTubePlayerHtml)
          ..close();
      });

      _serverUrl = 'http://127.0.0.1:$port';
      return _serverUrl;
    } catch (e) {
      log('Error starting local server: $e');
      return null;
    }
  }

  /// Stops and tears down the local HTTP server.
  void stop() {
    _server?.close(force: true);
    _server = null;
    _serverUrl = null;
    log('YouTube local server stopped');
  }
}
