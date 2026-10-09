import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/youtube_js_constants.dart';
import '../../normal_video_player/utils/fullscreen_utils_export.dart';
import '../models/youtube_player_config.dart';
import '../services/youtube_local_server_service.dart';

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
  final void Function(int position, int duration)? onPositionUpdate;
  final ValueChanged<bool>? onPlayingStateChanged;
  final ValueChanged<bool>? onControlsVisibilityChanged;

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
    this.onControlsVisibilityChanged,
  });

  @override
  State<YouTubeWebViewPlayer> createState() => YouTubeWebViewPlayerState();
}

class YouTubeWebViewPlayerState extends State<YouTubeWebViewPlayer> {
  final GlobalKey _inAppWebViewKey = GlobalKey();
  final YouTubeLocalServerService _serverService = YouTubeLocalServerService();
  InAppWebViewController? _webViewController;
  String? _serverUrl;

  /// A real http://127.0.0.1 page. Injecting the HTML with a fake
  /// https://www.youtube.com base URL makes YouTube return error 152-4.
  bool get _usesLocalServer => true;

  bool get _usesDesktopUserAgent =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  int _currentPosition = 0;
  int _duration = 0;
  String _currentLang = 'en';
  String _currentDir = 'ltr';

  int get currentPosition => _currentPosition;
  int get duration => _duration;

  int _secondsOf(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return double.tryParse(value)?.toInt() ?? 0;
    return 0;
  }

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
        source: YouTubeJsCommands.setLanguage(_currentLang, _currentDir),
      );
    }
  }

  static WebViewEnvironment? _sharedWebViewEnvironment;
  static bool? _isWebViewAvailableOnWindows;
  bool _isCheckingEnvironment = false;
  String? _initErrorMessage;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.startAt;
    if (_usesLocalServer) {
      _startLocalServer();
    }
    if (Platform.isWindows) {
      _checkWindowsWebViewEnvironment();
    }
  }

  Future<void> _checkWindowsWebViewEnvironment() async {
    if (!Platform.isWindows) return;
    if (_isWebViewAvailableOnWindows != null && _sharedWebViewEnvironment != null) {
      return;
    }
    _isCheckingEnvironment = true;
    try {
      final version = await WebViewEnvironment.getAvailableVersion();
      if (version == null) {
        _isWebViewAvailableOnWindows = false;
        _initErrorMessage =
            'Microsoft Edge WebView2 Runtime is required for YouTube playback on Windows.\nPlease install WebView2 Runtime from Microsoft.';
      } else {
        _isWebViewAvailableOnWindows = true;
        if (_sharedWebViewEnvironment == null) {
          final localAppData = Platform.environment['LOCALAPPDATA'] ??
              Platform.environment['TEMP'] ??
              Directory.systemTemp.path;
          final userDataDir = '$localAppData\\AdaptiveVideoPlayer_WebView2';
          _sharedWebViewEnvironment = await WebViewEnvironment.create(
            settings: WebViewEnvironmentSettings(userDataFolder: userDataDir),
          );
        }
      }
    } catch (e) {
      log('WebViewEnvironment check failed: $e');
      _initErrorMessage = 'Failed to initialize WebView2: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingEnvironment = false;
        });
      }
    }
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

  Future<void> _startLocalServer() async {
    final url = await _serverService.start();
    if (url != null && mounted) {
      setState(() {
        _serverUrl = url;
      });
    }
  }

  @override
  void dispose() {
    _serverService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      if (_isCheckingEnvironment &&
          _sharedWebViewEnvironment == null &&
          _isWebViewAvailableOnWindows != false) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.red),
        );
      }
      if (_isWebViewAvailableOnWindows == false || _initErrorMessage != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.web_asset_off_rounded,
                    color: Colors.orangeAccent, size: 48),
                const SizedBox(height: 12),
                Text(
                  _initErrorMessage ??
                      'Microsoft Edge WebView2 Runtime is required for YouTube playback on Windows.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Download WebView2 Runtime'),
                  onPressed: () {
                    launchUrl(
                      Uri.parse(
                          'https://developer.microsoft.com/en-us/microsoft-edge/webview2/'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }
    }

    if (_usesLocalServer && _serverUrl == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    return InAppWebView(
      key: _inAppWebViewKey,
      webViewEnvironment: _sharedWebViewEnvironment,
      initialUrlRequest: URLRequest(
        url: WebUri(_serverUrl!),
        headers: const {
          'Referer': 'https://www.youtube.com/',
        },
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        thirdPartyCookiesEnabled: true,
        domStorageEnabled: true,
        allowsPictureInPictureMediaPlayback: false,
        isElementFullscreenEnabled: false,
        iframeAllowFullscreen: false,
        iframeAllow: YouTubeJsScripts.iframeAllowPermissions,
        userAgent: _usesDesktopUserAgent
            ? YouTubeJsScripts.desktopUserAgent
            : null,
        supportMultipleWindows:
            true, // Need this TRUE for onCreateWindow to fire on target="_blank"
        useShouldOverrideUrlLoading: true,
        useHybridComposition: true,
      ),
      initialUserScripts: UnmodifiableListView<UserScript>([
        UserScript(
          source: YouTubeJsScripts.injectedPlayerScript,
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

        final host = uri.host;
        final isPlayerDocument = host == '127.0.0.1' ||
            host == 'localhost' ||
            host == 'www.youtube.com' ||
            host == 'youtube.com' ||
            host == 'www.youtube-nocookie.com' ||
            uri.scheme == 'about' ||
            uri.scheme == 'data';
        if (isPlayerDocument) {
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
          handlerName: YouTubeJsHandler.handlerName,
          callback: (args) {
            if (args.isEmpty) return;
            final data = args[0];
            final event = data['event'];
            if (event == YouTubeJsHandler.onReady) {
              log("YouTube player ready");
              widget.onReady?.call();
              final shouldPlay =
                  (widget.autoPlay ?? widget.config.playback.autoPlay) ||
                      isDesktopPipMode();
              if (shouldPlay) {
                play();
              }
            } else if (event == YouTubeJsHandler.onTimeUpdate) {
              final cur = _secondsOf(data['currentTime']);
              final dur = _secondsOf(data['duration']);
              _currentPosition = cur;
              if (dur > 0) _duration = dur;
              widget.onPositionUpdate?.call(_currentPosition, _duration);
            } else if (event == YouTubeJsHandler.onStateChange) {
              final state = data['data'];
              widget.onPlayingStateChanged?.call(state == 1);
              if (state == 0) {
                // YT.PlayerState.ENDED
                widget.onEnded?.call();
              }
            } else if (event == YouTubeJsHandler.onError) {
              log("YouTube player error: ${data['data']}");
            } else if (event == YouTubeJsHandler.onEnterFullscreen) {
              log("YouTube player JS onEnterFullscreen");
              widget.onEnterFullscreen?.call();
            } else if (event == YouTubeJsHandler.onExitFullscreen ||
                event == YouTubeJsHandler.onEscapeKey) {
              log("YouTube player JS $event");
              widget.onExitFullscreen?.call();
            } else if (event == YouTubeJsHandler.onSeekForward) {
              log("YouTube player JS onSeekForward");
              final next = _currentPosition + 10;
              seekTo(next);
              widget.onSeekForward?.call();
            } else if (event == YouTubeJsHandler.onSeekBackward) {
              log("YouTube player JS onSeekBackward");
              final prev = (_currentPosition - 10).clamp(0, 999999);
              seekTo(prev);
              widget.onSeekBackward?.call();
            } else if (event == YouTubeJsHandler.onToggleFullscreen) {
              widget.onToggleFullscreen?.call();
            } else if (event == YouTubeJsHandler.onTouchActivity) {
              widget.onTouchActivity?.call();
            } else if (event == YouTubeJsHandler.onControlsVisibilityChanged) {
              final visible = data['visible'] as bool? ?? true;
              widget.onControlsVisibilityChanged?.call(visible);
            }
          },
        );
      },
      onLoadStop: (controller, url) {
        log("YouTube page loaded: $url");
        // Inject videoId and settings after page loads
        final isAutoPlay =
            (widget.autoPlay ?? widget.config.playback.autoPlay) ||
                isDesktopPipMode();
        final autoplay = isAutoPlay ? 1 : 0;
        final mute = widget.config.playback.mute ? 1 : 0;
        final startAt = widget.startAt;
        final (lang, dir) = _resolveLangAndDir(context);
        _currentLang = lang;
        _currentDir = dir;
        controller.evaluateJavascript(
          source: YouTubeJsCommands.initPlayer(
            videoId: widget.videoId,
            autoPlay: autoplay,
            mute: mute,
            startAt: startAt,
            lang: _currentLang,
            dir: _currentDir,
          ),
        );
      },
      onConsoleMessage: (controller, consoleMessage) {
        log("JS: ${consoleMessage.message}");
      },
    );
  }

  // Public control methods
  void play() =>
      _webViewController?.evaluateJavascript(source: YouTubeJsCommands.playVideo);
  void pause() =>
      _webViewController?.evaluateJavascript(source: YouTubeJsCommands.pauseVideo);
  void seekTo(int seconds) => _webViewController?.evaluateJavascript(
      source: YouTubeJsCommands.seekTo(seconds));
  void mute() =>
      _webViewController?.evaluateJavascript(source: YouTubeJsCommands.muteVideo);
  void unMute() => _webViewController?.evaluateJavascript(
      source: YouTubeJsCommands.unMuteVideo);
  void setPlaybackRate(double rate) => _webViewController?.evaluateJavascript(
      source: YouTubeJsCommands.setPlaybackRate(rate));
  void exitFullscreen() {
    _webViewController?.evaluateJavascript(
        source: YouTubeJsCommands.exitFullscreen);
  }

  Future<int?> getCurrentTime() async {
    try {
      final result = await _webViewController?.evaluateJavascript(
        source: YouTubeJsCommands.getCurrentTime,
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
        source: YouTubeJsCommands.isPlaying,
      );
      if (result is bool) return result;
      if (result is int) return result == 1;
      if (result is String) {
        return result.toLowerCase() == 'true' || result == '1';
      }
    } catch (e) {
      log('Error checking isPlaying: $e');
    }
    return false;
  }
}
