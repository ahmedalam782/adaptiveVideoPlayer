import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/youtube_player_config.dart';
import 'youtube_player_html.dart';

/// A unified YouTube player that uses InAppWebView + local HTTP server
/// on all non-web platforms (Android, iOS, Windows, macOS, Linux).
///
/// This approach ensures consistent behavior across all platforms
/// and avoids YouTube Error 153 on Desktop.
class YouTubeWebViewPlayer extends StatefulWidget {
  final String videoId;
  final YouTubePlayerConfig config;
  final int startAt;
  final bool? autoPlay;
  final VoidCallback? onEnded;
  final VoidCallback? onReady;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onExitFullscreen;
  final VoidCallback? onSeekForward;
  final VoidCallback? onSeekBackward;
  final VoidCallback? onToggleFullscreen;
  final VoidCallback? onTouchActivity;
  final ValueChanged<int>? onPositionUpdate;
  final ValueChanged<bool>? onPlayingStateChanged;

  const YouTubeWebViewPlayer({
    super.key,
    required this.videoId,
    required this.config,
    this.startAt = 0,
    this.autoPlay,
    this.onEnded,
    this.onReady,
    this.onEnterFullscreen,
    this.onExitFullscreen,
    this.onSeekForward,
    this.onSeekBackward,
    this.onToggleFullscreen,
    this.onTouchActivity,
    this.onPositionUpdate,
    this.onPlayingStateChanged,
  });

  @override
  State<YouTubeWebViewPlayer> createState() => YouTubeWebViewPlayerState();
}

class YouTubeWebViewPlayerState extends State<YouTubeWebViewPlayer> {
  final GlobalKey _inAppWebViewKey = GlobalKey();
  InAppWebViewController? _webViewController;
  HttpServer? _localServer;
  String? _serverUrl;
  int _currentPosition = 0;
  String _currentLang = 'en';
  String _currentDir = 'ltr';

  int get currentPosition => _currentPosition;

  (String, String) _resolveLangAndDir(BuildContext context) {
    final ambientDir = Directionality.maybeOf(context);
    final lang = widget.config.text.resolveLanguageCode(
      context,
      ambientDirection: ambientDir,
    );
    final dir = widget.config.text.resolveTextDirection(
      context,
      ambientDirection: ambientDir,
    );
    return (lang, dir == TextDirection.rtl ? 'rtl' : 'ltr');
  }

  void _syncLanguage(BuildContext context) {
    final (nextLang, nextDir) = _resolveLangAndDir(context);
    if (_currentLang != nextLang || _currentDir != nextDir) {
      _currentLang = nextLang;
      _currentDir = nextDir;
      _webViewController?.evaluateJavascript(
        source: "setLanguage('$_currentLang', '$_currentDir');",
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.startAt;
    _startLocalServer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncLanguage(context);
  }

  @override
  void didUpdateWidget(covariant YouTubeWebViewPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncLanguage(context);
  }

  /// Start a local HTTP server to serve the YouTube player HTML.
  /// YouTube allows iframe embedding from http://localhost origins,
  /// which fixes Error 153 on Desktop and works on mobile too.
  Future<void> _startLocalServer() async {
    try {
      // Use embedded HTML from youtube_player_html.dart in this same directory
      final htmlContent = kYouTubePlayerHtml;

      // Start a local HTTP server on a random available port
      _localServer = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final port = _localServer!.port;
      log('YouTube local server started on port $port');

      _localServer!.listen((HttpRequest request) {
        request.response
          ..headers.contentType = ContentType.html
          ..headers.add('Access-Control-Allow-Origin', '*')
          ..headers.add('Referrer-Policy', 'no-referrer-when-downgrade')
          ..write(htmlContent)
          ..close();
      });

      if (mounted) {
        setState(() {
          _serverUrl = 'http://127.0.0.1:$port';
        });
      }
    } catch (e) {
      log('Error starting local server: $e');
    }
  }

  @override
  void dispose() {
    _localServer?.close(force: true);
    log('YouTube local server stopped');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_serverUrl == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    return InAppWebView(
      key: _inAppWebViewKey,
      initialUrlRequest: URLRequest(
        url: WebUri(_serverUrl!),
        headers: {
          'Referer': 'https://www.youtube.com/',
        },
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        allowsPictureInPictureMediaPlayback: false,
        isElementFullscreenEnabled: true,
        iframeAllowFullscreen: true,
        iframeAllow:
            "camera; microphone; playing; fullscreen; autoplay; encrypted-media; gyroscope; accelerometer; clipboard-write",
        userAgent: (Platform.isWindows || Platform.isMacOS || Platform.isLinux)
            ? "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
            : null,
        supportMultipleWindows:
            true, // Need this TRUE for onCreateWindow to fire on target="_blank"
        useShouldOverrideUrlLoading: true,
      ),
      initialUserScripts: UnmodifiableListView<UserScript>([
        UserScript(
          source: """
            (function() {
              function updatePlayerStyles() {
                try {
                  var vids = document.querySelectorAll('video');
                  for (var i = 0; i < vids.length; i++) {
                    var v = vids[i];
                    v.disablePictureInPicture = true;
                    v.setAttribute('disablePictureInPicture', '');
                    var cl = v.getAttribute('controlsList') || '';
                    if (cl.indexOf('nopip') === -1) {
                      v.setAttribute('controlsList', (cl + ' nopip').trim());
                    }
                  }

                  var isRtl = false;
                  try {
                    var doc = document.documentElement;
                    var lang = (doc && (doc.getAttribute('lang') || doc.lang)) || '';
                    var dir = (doc && (doc.getAttribute('dir') || doc.dir)) || '';
                    var loc = window.location ? (window.location.search || window.location.href || '') : '';
                    if (dir === 'rtl' || lang.toLowerCase().indexOf('ar') === 0 || loc.indexOf('hl=ar') !== -1) {
                      isRtl = true;
                    } else {
                      try {
                        if (window.parent && window.parent !== window && window.parent.document) {
                          var pDoc = window.parent.document.documentElement;
                          if (pDoc && (pDoc.dir === 'rtl' || (pDoc.lang && pDoc.lang.toLowerCase().indexOf('ar') === 0))) {
                            isRtl = true;
                          }
                        }
                      } catch (_) {}
                    }
                  } catch (_) {}

                  var styleId = 'yt-custom-injected-style';
                  var existing = document.getElementById(styleId);
                  var css = '.ytp-fullscreen-button { display: none !important; }';
                  if (isRtl) {
                    css += ' .ytp-progress-bar-container, .ytp-progress-bar { transform: scaleX(-1) !important; }';
                  }

                  if (!existing) {
                    var st = document.createElement('style');
                    st.id = styleId;
                    st.innerHTML = css;
                    (document.head || document.documentElement).appendChild(st);
                  } else if (existing.innerHTML !== css) {
                    existing.innerHTML = css;
                  }
                } catch(e) {}
              }
              updatePlayerStyles();
              if (window.MutationObserver) {
                new MutationObserver(updatePlayerStyles).observe(document.documentElement || document.body, {
                  childList: true,
                  subtree: true,
                  attributes: true,
                  attributeFilter: ['dir', 'lang']
                });
              }
              window.addEventListener('load', updatePlayerStyles);

              try {
                function onUserTouchActivity() {
                  try {
                    if (window.flutter_inappwebview) {
                      window.flutter_inappwebview.callHandler('YouTubePlayerHandler', { 'event': 'onTouchActivity' });
                    }
                  } catch(e) {}
                }
                window.addEventListener('touchstart', onUserTouchActivity, { passive: true, capture: true });
                window.addEventListener('pointerdown', onUserTouchActivity, { passive: true, capture: true });
                window.addEventListener('click', onUserTouchActivity, { passive: true, capture: true });
              } catch(e) {}
            })();
          """,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: false,
        ),
      ]),
      onPermissionRequest: (controller, request) async {
        return PermissionResponse(
            resources: request.resources,
            action: PermissionResponseAction.GRANT);
      },
      onEnterFullscreen: (controller) async {
        log('Entered fullscreen in YouTubeWebViewPlayer');
        widget.onEnterFullscreen?.call();
      },
      onExitFullscreen: (controller) async {
        log('Exited fullscreen in YouTubeWebViewPlayer');
        widget.onExitFullscreen?.call();
      },
      onCreateWindow: (controller, createWindowAction) async {
        final uri = createWindowAction.request.url;
        if (uri != null && widget.config.playback.allowExternalLinks) {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            log("Could not launch $uri");
          }
        }
        return true;
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final uri = navigationAction.request.url;
        if (uri == null) return NavigationActionPolicy.ALLOW;

        // Sub-frames (YouTube iframe, media streams, CDNs) must always be allowed
        if (!navigationAction.isForMainFrame) {
          return NavigationActionPolicy.ALLOW;
        }

        final isLocal = uri.host == '127.0.0.1' || uri.host == 'localhost';
        if (isLocal) {
          return NavigationActionPolicy.ALLOW;
        }

        // Top-level main frame navigation to external links
        if (widget.config.playback.allowExternalLinks) {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            log("Could not launch $uri");
          }
        }
        return NavigationActionPolicy.CANCEL;
      },
      onLoadStart: (controller, url) {
        log("YouTube WebView onLoadStart: $url");
      },
      onWebViewCreated: (controller) {
        _webViewController = controller;
        log("YouTube WebView created");

        // Register handler for JS → Dart communication
        controller.addJavaScriptHandler(
          handlerName: 'YouTubePlayerHandler',
          callback: (args) {
            if (args.isEmpty) return;
            final data = args[0];
            final event = data['event'];
            if (event == 'onReady') {
              log("YouTube player ready");
              widget.onReady?.call();
            } else if (event == 'onTimeUpdate') {
              final cur = data['currentTime'];
              if (cur is num) {
                _currentPosition = cur.toInt();
                widget.onPositionUpdate?.call(_currentPosition);
              }
            } else if (event == 'onStateChange') {
              final state = data['data'];
              widget.onPlayingStateChanged?.call(state == 1);
              if (state == 0) {
                // YT.PlayerState.ENDED
                widget.onEnded?.call();
              }
            } else if (event == 'onError') {
              log("YouTube player error: ${data['data']}");
            } else if (event == 'onEnterFullscreen') {
              log("YouTube player JS onEnterFullscreen");
              widget.onEnterFullscreen?.call();
            } else if (event == 'onExitFullscreen' || event == 'onEscapeKey') {
              log("YouTube player JS $event");
              widget.onExitFullscreen?.call();
            } else if (event == 'onSeekForward') {
              log("YouTube player JS onSeekForward");
              final next = _currentPosition + 10;
              seekTo(next);
              widget.onSeekForward?.call();
            } else if (event == 'onSeekBackward') {
              log("YouTube player JS onSeekBackward");
              final prev = (_currentPosition - 10).clamp(0, 999999);
              seekTo(prev);
              widget.onSeekBackward?.call();
            } else if (event == 'onToggleFullscreen') {
              widget.onToggleFullscreen?.call();
            } else if (event == 'onTouchActivity') {
              widget.onTouchActivity?.call();
            }
          },
        );
      },
      onLoadStop: (controller, url) {
        log("YouTube page loaded: $url");
        // Inject videoId and settings after page loads
        final isAutoPlay = widget.autoPlay ?? widget.config.playback.autoPlay;
        final autoplay = isAutoPlay ? 1 : 0;
        final mute = widget.config.playback.mute ? 1 : 0;
        final startAt = widget.startAt;
        final (lang, dir) = _resolveLangAndDir(context);
        _currentLang = lang;
        _currentDir = dir;
        controller.evaluateJavascript(
          source:
              "initPlayer('${widget.videoId}', $autoplay, $mute, $startAt, '$_currentLang', '$_currentDir');",
        );
      },
      onConsoleMessage: (controller, consoleMessage) {
        log("JS: ${consoleMessage.message}");
      },
    );
  }

  // Public control methods
  void play() => _webViewController?.evaluateJavascript(source: "playVideo();");
  void pause() =>
      _webViewController?.evaluateJavascript(source: "pauseVideo();");
  void seekTo(int seconds) =>
      _webViewController?.evaluateJavascript(source: "seekTo($seconds);");
  void mute() => _webViewController?.evaluateJavascript(source: "muteVideo();");
  void unMute() =>
      _webViewController?.evaluateJavascript(source: "unMuteVideo();");
  void exitFullscreen() {
    _webViewController?.evaluateJavascript(
        source:
            "if (document.fullscreenElement) { document.exitFullscreen(); } else if (document.webkitFullscreenElement) { document.webkitExitFullscreen(); }");
  }

  Future<int?> getCurrentTime() async {
    try {
      final result = await _webViewController?.evaluateJavascript(
        source:
            "player && typeof player.getCurrentTime === 'function' ? Math.floor(player.getCurrentTime()) : 0;",
      );
      if (result is num) {
        _currentPosition = result.toInt();
        return _currentPosition;
      }
    } catch (e) {
      log('Error getting current time: $e');
    }
    return _currentPosition;
  }

  Future<bool> isPlaying() async {
    try {
      final result = await _webViewController?.evaluateJavascript(
        source:
            "player && typeof player.getPlayerState === 'function' ? (player.getPlayerState() === 1 || player.getPlayerState() === 3) : false;",
      );
      if (result is bool) return result;
      if (result is int) return result == 1;
    } catch (e) {
      log('Error checking isPlaying: $e');
    }
    return true;
  }
}
