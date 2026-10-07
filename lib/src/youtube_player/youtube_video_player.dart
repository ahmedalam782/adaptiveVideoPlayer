import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/services/native_pip_service.dart';
import 'cubit/youtube_player_cubit.dart';
import 'mixins/youtube_player_pip_mixin.dart';
import 'mixins/youtube_player_web_iframe_mixin.dart';
import 'models/youtube_player_config.dart';
import 'utils/player_utils.dart';
import 'utils/youtube_web_export.dart';
import 'views/youtube_desktop_player_view.dart';
import 'views/youtube_web_player_view.dart';
import 'widgets/player_error_widget.dart';
import 'widgets/player_loading_widget.dart';
import 'widgets/youtube_desktop_overlay.dart';
import 'widgets/youtube_desktop_pip_placeholder.dart';
import 'widgets/youtube_webview_player_export.dart';

/// A widget for playing YouTube videos natively across all supported platforms.
///
/// - On **Web**, embeds the video using the browser's native `HTMLIFrameElement`.
/// - On **Mobile (Android/iOS)** and **Desktop (Windows/macOS/Linux)**, embeds the video
///   using the native `InAppWebView` with a localized origin server to guarantee full
///   controls, bypass embedding restrictions, and avoid YouTube Error 150/153.
class YouTubeVideoPlayer extends StatefulWidget {
  final String videoSource;
  final YouTubePlayerConfig config;
  final VoidCallback? onEnded;
  final String? viewerCount;
  final bool isLive;
  final YouTubeLoadingBuilder? loadingBuilder;
  final YouTubeErrorBuilder? errorBuilder;
  final YouTubeReplayBuilder? replayBuilder;
  final YouTubeLiveBadgeBuilder? liveBadgeBuilder;
  final double? aspectRatio;

  const YouTubeVideoPlayer({
    super.key,
    required this.videoSource,
    this.config = const YouTubePlayerConfig(),
    this.onEnded,
    this.viewerCount,
    this.isLive = false,
    this.loadingBuilder,
    this.errorBuilder,
    this.replayBuilder,
    this.liveBadgeBuilder,
    this.aspectRatio,
  });

  @override
  YouTubeVideoPlayerState createState() => YouTubeVideoPlayerState();
}

class YouTubeVideoPlayerState extends State<YouTubeVideoPlayer>
    with YouTubePlayerPipMixin, YouTubePlayerWebIframeMixin {
  late YoutubePlayerCubit _cubit;
  bool _hasError = false;
  String _errorMessage = '';
  String? _videoId;
  bool _isControllerDisposed = false;

  final GlobalKey<YouTubeWebViewPlayerState> _desktopWebViewKey =
      GlobalKey<YouTubeWebViewPlayerState>();
  late final YouTubeDesktopFullscreenManager _desktopFullscreenManager;

  YouTubePlayerConfig get _cfg => widget.config;
  PlayerCubitState get _state => _cubit.state;

  @override
  String? get currentVideoId => _videoId;

  @override
  String? get currentWebIframeId => webIframeId;

  @override
  bool get isMuted => _state.isMuted;

  @override
  bool get isLooping => _state.loop;

  @override
  bool get isCaptionEnabled => _state.enableCaption;

  @override
  void onPauseVideo() => pause();

  @override
  void onAfterClosePip(bool pauseOnClose) {
    if (kIsWeb && _videoId != null) {
      final effectiveConfig = mounted ? resolveEffectiveConfig(context) : _cfg;
      final isRtl = effectiveConfig.text.resolveTextDirection(context) ==
          TextDirection.rtl;
      final currentLang =
          isRtl ? 'ar' : (effectiveConfig.text.languageCode ?? 'en');
      webIframeId =
          'youtube-iframe-$_videoId-${DateTime.now().millisecondsSinceEpoch}';
      registerYoutubeWebIframe(
        webIframeId!,
        _videoId!,
        !pauseOnClose,
        mute: _state.isMuted,
        loop: _state.loop,
        enableCaption: _state.enableCaption,
        languageCode: currentLang,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _cubit = YoutubePlayerCubit();
    _cubit.updateSettings(
      autoPlay: _cfg.playback.autoPlay,
      loop: _cfg.playback.loop,
      forceHD: _cfg.playback.forceHD,
      enableCaption: _cfg.playback.enableCaption,
    );
    _cubit.setMuted(_cfg.playback.mute);

    _desktopFullscreenManager = YouTubeDesktopFullscreenManager(
      getContext: () => context,
      onStateChange: () {
        if (mounted) setState(() {});
      },
      desktopWebViewKey: _desktopWebViewKey,
    );

    NativePipService.isInPip.addListener(_onNativePipChanged);
    _initializePlayer();
  }

  void _onNativePipChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    syncWebIframe(
      context: context,
      videoId: _videoId,
      autoPlay: _state.autoPlay,
      isMuted: _state.isMuted,
      loop: _state.loop,
      enableCaption: _state.enableCaption,
      resolveConfig: resolveEffectiveConfig,
    );
  }

  @override
  void didUpdateWidget(covariant YouTubeVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoSource != widget.videoSource) {
      loadVideo(widget.videoSource);
    }
  }

  void _initializePlayer() {
    try {
      _videoId = PlayerUtils.extractVideoId(widget.videoSource);

      if (_videoId == null || _videoId!.isEmpty) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = _cfg.text.invalidYoutubeUrlText;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _hasError = false;
          _isControllerDisposed = false;
        });
      }
    } catch (e) {
      log('YouTube player initialization error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = _cfg.text.videoLoadFailedText;
        });
      }
    }
  }

  @override
  YouTubePlayerConfig resolveEffectiveConfig(BuildContext context) {
    final ambientDirection = Directionality.maybeOf(context);
    final resolvedDir = _cfg.text.resolveTextDirection(
      context,
      ambientDirection: ambientDirection,
    );
    final resolvedLang = _cfg.text.resolveLanguageCode(
      context,
      ambientDirection: ambientDirection,
    );

    if (_cfg.text.textDirection == resolvedDir &&
        _cfg.text.languageCode == resolvedLang) {
      return _cfg;
    }

    return YouTubePlayerConfig(
      style: _cfg.style,
      text: _cfg.text.copyWith(
        languageCode: resolvedLang,
        textDirection: resolvedDir,
      ),
      visibility: _cfg.visibility,
      playback: _cfg.playback,
      loadingBuilder: _cfg.loadingBuilder,
      errorBuilder: _cfg.errorBuilder,
      replayBuilder: _cfg.replayBuilder,
      liveBadgeBuilder: _cfg.liveBadgeBuilder,
    );
  }

  @override
  void dispose() {
    NativePipService.isInPip.removeListener(_onNativePipChanged);
    disposeMobilePip();
    _desktopFullscreenManager.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return (widget.errorBuilder ?? _cfg.errorBuilder)?.call(
            context,
            _errorMessage,
          ) ??
          PlayerErrorWidget(
            errorMessage: _errorMessage,
            errorIconColor: _cfg.style.errorIconColor,
            backgroundColor: _cfg.style.backgroundColor,
            textColor: _cfg.style.textColor,
            errorTextStyle: _cfg.style.errorTextStyle,
            errorIcon: _cfg.style.icons.errorIcon,
          );
    }

    if (_videoId == null || _isControllerDisposed) {
      return (widget.loadingBuilder ?? _cfg.loadingBuilder)?.call(context) ??
          PlayerLoadingWidget(
            loadingIndicatorColor: _cfg.style.loadingIndicatorColor,
            backgroundColor: _cfg.style.backgroundColor,
            strokeWidth: _cfg.style.loadingIndicatorStrokeWidth,
            size: _cfg.style.loadingIndicatorSize,
            builder: _cfg.style.loadingIndicatorBuilder,
          );
    }

    final effectiveConfig = resolveEffectiveConfig(context);

    if (kIsWeb) {
      if (isInMobilePip) {
        return YouTubeDesktopPipPlaceholder(
          onRestore: () => closeMobilePip(pauseOnClose: false),
          restorePlayerText: effectiveConfig.text.restorePlayerText,
        );
      }

      if (webIframeId == null) {
        return const SizedBox.shrink();
      }

      return YouTubeWebPlayerView(
        viewId: webIframeId!,
        videoId: _videoId!,
        config: effectiveConfig,
        aspectRatio: widget.aspectRatio,
        isLive: widget.isLive,
        viewerCount: widget.viewerCount,
        liveBadgeBuilder: widget.liveBadgeBuilder,
        onOpenPip: openPip,
        onToggleFullscreen: enterFullScreen,
        isInFullscreen: isYoutubeWebFullscreen(),
        onPlay: play,
        onPause: pause,
        onMute: mute,
        onUnMute: unMute,
      );
    }

    // Unified native WebView player on Android, iOS, Windows, macOS, Linux
    return YouTubeDesktopPlayerView(
      desktopWebViewKey: _desktopWebViewKey,
      videoId: _videoId!,
      config: effectiveConfig,
      fullscreenManager: _desktopFullscreenManager,
      aspectRatio: widget.aspectRatio,
      isLive: widget.isLive,
      viewerCount: widget.viewerCount,
      liveBadgeBuilder: widget.liveBadgeBuilder,
      onReady: () => log('Native YouTube player ready'),
      onEnded: () => widget.onEnded?.call(),
    );
  }

  // Unified public playback control API
  void play() {
    if (kIsWeb && webIframeId != null) {
      sendYoutubeWebCommand(webIframeId!, 'playVideo');
    } else {
      _desktopWebViewKey.currentState?.play();
    }
  }

  void pause() {
    if (kIsWeb && webIframeId != null) {
      sendYoutubeWebCommand(webIframeId!, 'pauseVideo');
    } else {
      _desktopWebViewKey.currentState?.pause();
    }
  }

  void stop() {
    if (kIsWeb && webIframeId != null) {
      sendYoutubeWebCommand(webIframeId!, 'pauseVideo');
      sendYoutubeWebCommand(webIframeId!, 'seekTo', [0, true]);
    } else {
      _desktopWebViewKey.currentState?.pause();
      _desktopWebViewKey.currentState?.seekTo(0);
    }
  }

  void seekTo(Duration position) {
    if (kIsWeb && webIframeId != null) {
      sendYoutubeWebCommand(webIframeId!, 'seekTo', [position.inSeconds, true]);
    } else {
      _desktopWebViewKey.currentState?.seekTo(position.inSeconds);
    }
  }

  void mute() {
    if (kIsWeb && webIframeId != null) {
      sendYoutubeWebCommand(webIframeId!, 'mute');
    } else {
      _desktopWebViewKey.currentState?.mute();
    }
    _cubit.setMuted(true);
  }

  void unMute() {
    if (kIsWeb && webIframeId != null) {
      sendYoutubeWebCommand(webIframeId!, 'unMute');
    } else {
      _desktopWebViewKey.currentState?.unMute();
    }
    _cubit.setMuted(false);
  }

  void setPlaybackRate(double rate) {
    if (kIsWeb && webIframeId != null) {
      sendYoutubeWebCommand(webIframeId!, 'setPlaybackRate', [rate]);
    } else {
      _desktopWebViewKey.currentState?.setPlaybackRate(rate);
    }
  }

  Duration get currentPosition =>
      Duration(seconds: _desktopFullscreenManager.currentPositionSeconds);

  Duration get duration => Duration.zero;

  bool get isPlaying => _desktopFullscreenManager.wasPlaying ?? false;

  void enterFullScreen() {
    if (kIsWeb) {
      if (webIframeId != null) {
        toggleYoutubeWebFullscreen(webIframeId!);
      }
      return;
    }
    final effectiveConfig = resolveEffectiveConfig(context);
    _desktopFullscreenManager.openFullscreen(
      desktopPlayerBuilder: () => YouTubeDesktopPlayerView(
        desktopWebViewKey: _desktopWebViewKey,
        videoId: _videoId!,
        config: effectiveConfig,
        fullscreenManager: _desktopFullscreenManager,
        isLive: widget.isLive,
        viewerCount: widget.viewerCount,
        liveBadgeBuilder: widget.liveBadgeBuilder,
        onReady: () => log('Native YouTube player fullscreen ready'),
        onEnded: () => widget.onEnded?.call(),
      ),
      textDirection: effectiveConfig.text.resolveTextDirection(context),
    );
  }

  void openPip() => openMobilePip();

  void loadVideo(String videoSource) {
    final newVideoId = PlayerUtils.extractVideoId(videoSource);
    if (newVideoId != null && newVideoId != _videoId) {
      setState(() {
        _videoId = newVideoId;
        _isControllerDisposed = false;
        resetWebIframe();
      });
      _initializePlayer();
    }
  }
}
