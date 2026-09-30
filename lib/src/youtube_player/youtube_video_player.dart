import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'coordinator/youtube_fullscreen_coordinator.dart';
import 'cubit/youtube_player_cubit.dart';
import 'models/youtube_player_config.dart';
import 'utils/player_utils.dart';
import 'utils/youtube_settings_helper.dart';
import 'utils/youtube_web_export.dart';
import 'views/youtube_desktop_player_view.dart';
import 'views/youtube_mobile_player_view.dart';
import 'widgets/player_controls.dart';
import 'widgets/youtube_desktop_overlay.dart';
import 'widgets/youtube_webview_player_export.dart';

/// A widget for playing YouTube videos with full YouTube controls.
/// Supports Mobile, Desktop, and Web with custom controls and settings.
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
  });

  @override
  YouTubeVideoPlayerState createState() => YouTubeVideoPlayerState();
}

class YouTubeVideoPlayerState extends State<YouTubeVideoPlayer> {
  YoutubePlayerController? _controller;
  late YoutubePlayerCubit _cubit;
  bool _hasError = false;
  String _errorMessage = '';
  String? _videoId;
  bool _isControllerDisposed = false;
  bool _isInFullscreen = false;
  Duration? _pendingSeekPosition;
  bool _hasRestoredPosition = false;
  bool _videoEnded = false;
  String? _webIframeId;
  final GlobalKey _webIframeKey = GlobalKey();
  final GlobalKey<YouTubeWebViewPlayerState> _desktopWebViewKey =
      GlobalKey<YouTubeWebViewPlayerState>();
  late final YouTubeDesktopFullscreenManager _desktopFullscreenManager;
  Duration _currentPosition = Duration.zero;
  StreamSubscription<YoutubeVideoState>? _videoStateSub;
  StreamSubscription<YoutubePlayerValue>? _playerValueSub;

  YouTubePlayerConfig get _cfg => widget.config;
  PlayerCubitState get _state => _cubit.state;

  bool get _useDesktopPlayer {
    if (kIsWeb) return false;
    final isDesktopPlatform = defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS;
    return isDesktopPlatform || _cfg.playback.forceDesktopMode;
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

    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant YouTubeVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoSource != widget.videoSource) {
      _desktopFullscreenManager.currentPositionSeconds = 0;
      _desktopFullscreenManager.wasPlaying = null;
      _disposeController();
      _initializePlayer();
      return;
    }
    if (oldWidget.config != widget.config ||
        oldWidget.viewerCount != widget.viewerCount ||
        oldWidget.isLive != widget.isLive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _mobilePipOverlayEntry?.markNeedsBuild();
        _desktopFullscreenManager.markOverlaysNeedBuild();
      });
    }
  }

  void _disposeController() {
    _videoStateSub?.cancel();
    _playerValueSub?.cancel();
    if (_controller != null && !_isControllerDisposed) {
      _isControllerDisposed = true;
      PlayerUtils.disposeController(
        _controller,
        onError: (e) => log('Error disposing controller: $e'),
      );
      _controller = null;
    }
  }

  bool get _isControllerSafe =>
      _controller != null && !_isControllerDisposed && mounted;

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

      if (kIsWeb) {
        _webIframeId =
            'youtube-iframe-$_videoId-${DateTime.now().millisecondsSinceEpoch}';
        registerYoutubeWebIframe(
          _webIframeId!,
          _videoId!,
          _state.autoPlay,
          mute: _state.isMuted,
          loop: _state.loop,
          enableCaption: _state.enableCaption,
          languageCode: _cfg.text.languageCode ?? 'en',
        );
        if (mounted) setState(() => _isControllerDisposed = false);
        return;
      }

      if (_useDesktopPlayer) {
        if (mounted) setState(() => _isControllerDisposed = false);
        return;
      }

      final startAtSeconds = _pendingSeekPosition?.inSeconds ?? 0;
      final controller = PlayerUtils.createController(
        videoId: _videoId!,
        autoPlay: _state.autoPlay,
        mute: _state.isMuted,
        loop: _state.loop,
        forceHD: _state.forceHD,
        enableCaption: _state.enableCaption,
        showControls: _cfg.visibility.showControls,
        startAt: startAtSeconds,
      );

      _videoStateSub?.cancel();
      _videoStateSub = controller.videoStateStream.listen((state) {
        if (mounted) setState(() => _currentPosition = state.position);
      });

      _playerValueSub?.cancel();
      _playerValueSub = controller.stream.listen((value) {
        if (!_isControllerDisposed && mounted) {
          if (PlayerUtils.isReady(controller) &&
              !_hasRestoredPosition &&
              _pendingSeekPosition != null) {
            _hasRestoredPosition = true;
            final targetPosition = _pendingSeekPosition!;
            _pendingSeekPosition = null;
            Future.microtask(() {
              if (!_isControllerDisposed && mounted && _controller != null) {
                PlayerUtils.seekTo(_controller!, targetPosition);
              }
            });
          }

          if (value.playerState == PlayerState.ended) {
            widget.onEnded?.call();

            if (_state.loop && !_isControllerDisposed && mounted) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (!_isControllerDisposed && mounted && _controller != null) {
                  _videoEnded = false;
                  PlayerUtils.seekTo(_controller!, Duration.zero);
                  PlayerUtils.play(_controller);
                }
              });
            } else {
              if (mounted) setState(() => _videoEnded = true);
            }
          }

          if (value.playerState == PlayerState.playing && _videoEnded) {
            if (mounted) setState(() => _videoEnded = false);
          }
        }
      });

      if (mounted) {
        setState(() {
          _controller = controller;
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

  Future<void> _openFullScreen() async {
    final controller = _controller;
    if (controller == null || _isControllerDisposed) return;

    final effectiveConfig = _resolveEffectiveConfig(context);
    _isInFullscreen = true;
    await YouTubeFullscreenCoordinator.openFullScreen(
      context: context,
      controller: controller,
      videoId: _videoId!,
      currentPosition: _currentPosition,
      cubit: _cubit,
      config: effectiveConfig,
      isLive: widget.isLive,
      viewerCount: widget.viewerCount,
      onEnded: widget.onEnded,
      isControllerSafe: () => _isControllerSafe,
      onReloadPlayer: _reloadPlayerWithSettings,
      onVideoEndedChanged: (ended) {
        if (mounted) setState(() => _videoEnded = ended);
      },
    );
    _isInFullscreen = false;
  }

  void _restartVideo() {
    if (!mounted || _isControllerDisposed || _controller == null) return;
    setState(() => _videoEnded = false);
    PlayerUtils.seekTo(_controller!, Duration.zero);
    PlayerUtils.play(_controller);
  }

  void _toggleMute() {
    if (!mounted || _isControllerDisposed || _controller == null) return;
    final newMuteState = PlayerUtils.toggleMute(
      _controller!,
      _state.isMuted,
      onError: (e) => log('Toggle mute error: $e'),
    );
    _cubit.setMuted(newMuteState);
    setState(() {});
  }

  void _seekForward() {
    if (!mounted || _isControllerDisposed || _controller == null) return;
    PlayerUtils.seekForward(
      _controller!,
      onError: (e) => log('Seek forward error: $e'),
    );
  }

  void _seekBackward() {
    if (!mounted || _isControllerDisposed || _controller == null) return;
    PlayerUtils.seekBackward(
      _controller!,
      onError: (e) => log('Seek backward error: $e'),
    );
  }

  YouTubePlayerConfig _resolveEffectiveConfig(BuildContext context) {
    final ambientDirection = Directionality.maybeOf(context);
    final resolvedDir = _cfg.text.resolveTextDirection(
      context,
      ambientDirection: ambientDirection,
    );
    final resolvedLang = _cfg.text.resolveLanguageCode(
      context,
      ambientDirection: ambientDirection,
    );

    if (resolvedDir == TextDirection.rtl && _cfg.text.isDefaultUnmodified) {
      return YouTubePlayerConfig(
        style: _cfg.style,
        text: const PlayerTextConfig.arabic().copyWith(
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

  void _showSettingsBottomSheet() {
    final effectiveConfig = _resolveEffectiveConfig(context);
    YouTubeSettingsHelper.openSettingsSheet(
      context: context,
      config: effectiveConfig,
      state: _state,
      cubit: _cubit,
      onReloadPlayer: _reloadPlayerWithSettings,
      onMutedChanged: (value) {
        if (_state.isMuted != value) {
          _cubit.setMuted(value);
          if (_controller != null) {
            PlayerUtils.setMute(_controller!, _state.isMuted);
          }
        }
      },
    );
  }

  Future<void> _reloadPlayerWithSettings({Duration? targetPosition}) async {
    if (_controller == null || _isControllerDisposed) return;
    Duration currentPosition = targetPosition ?? Duration.zero;
    bool wasPlaying = false;
    try {
      if (targetPosition == null) {
        currentPosition = _currentPosition;
      }
      wasPlaying = PlayerUtils.isPlaying(_controller);
    } catch (e) {
      log('Error getting current state before reload: $e');
    }
    _pendingSeekPosition = currentPosition;
    _hasRestoredPosition = false;
    _disposeController();
    setState(() => _isControllerDisposed = false);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _initializePlayer();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted &&
        _controller != null &&
        !_isControllerDisposed &&
        wasPlaying) {
      await Future.delayed(const Duration(milliseconds: 100));
      PlayerUtils.play(_controller);
    }
  }

  OverlayEntry? _mobilePipOverlayEntry;
  bool get _isInMobilePip => _mobilePipOverlayEntry != null;

  void _openMobilePip() {
    if (_isInMobilePip) return;
    if (!kIsWeb && (_controller == null || _isControllerDisposed)) return;
    if (kIsWeb && _webIframeId == null) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final controller = _controller;
    Offset offset = Offset.zero;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setOverlayState) {
          final currentText = mounted
              ? _resolveEffectiveConfig(context).text
              : _cfg.text;
          return Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  right: 16 - offset.dx,
                  bottom: 24 - offset.dy,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setOverlayState(() {
                        offset += details.delta;
                      });
                    },
                    child: Material(
                      color: Colors.black,
                      elevation: 14,
                      borderRadius: BorderRadius.circular(12),
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        width: 280,
                        height: 158,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (kIsWeb && _webIframeId != null)
                              buildYoutubeWebIframe(
                                _webIframeId!,
                                key: _webIframeKey,
                              )
                            else if (controller != null)
                              YoutubePlayer(controller: controller),
                            Positioned(
                              top: 6,
                              left: 8,
                              right: 8,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Tooltip(
                                    message: currentText.expandPlayerText,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _closeMobilePip(pauseOnClose: false),
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          color: Color(0xAA000000),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.open_in_full_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Tooltip(
                                    message: currentText.closeMiniPlayerText,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _closeMobilePip(pauseOnClose: true),
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          color: Color(0xAA000000),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    _mobilePipOverlayEntry = entry;
    overlay.insert(entry);
    if (mounted) setState(() {});
  }

  void _closeMobilePip({bool pauseOnClose = false}) {
    if (!_isInMobilePip) return;
    _mobilePipOverlayEntry?.remove();
    _mobilePipOverlayEntry = null;
    if (pauseOnClose && _controller != null && !_isControllerDisposed) {
      PlayerUtils.pause(_controller);
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _mobilePipOverlayEntry?.remove();
    _mobilePipOverlayEntry = null;
    _desktopFullscreenManager.dispose();
    _videoStateSub?.cancel();
    _playerValueSub?.cancel();
    _disposeController();
    _cubit.close();
    if (!_isInFullscreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
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
          );
    }
    final controller = _controller;

    if (_videoId == null || _isControllerDisposed) {
      return (widget.loadingBuilder ?? _cfg.loadingBuilder)?.call(context) ??
          PlayerLoadingWidget(
            loadingIndicatorColor: _cfg.style.loadingIndicatorColor,
            backgroundColor: _cfg.style.backgroundColor,
          );
    }
    if (!kIsWeb && !_useDesktopPlayer && controller == null) {
      return (widget.loadingBuilder ?? _cfg.loadingBuilder)?.call(context) ??
          PlayerLoadingWidget(
            loadingIndicatorColor: _cfg.style.loadingIndicatorColor,
            backgroundColor: _cfg.style.backgroundColor,
          );
    }

    final effectiveConfig = _resolveEffectiveConfig(context);

    return ValueListenableBuilder<PlayerCubitState>(
      valueListenable: _cubit,
      builder: (context, state, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isInMobilePip)
                    Container(
                      color: Colors.black87,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.picture_in_picture_alt_rounded,
                            color: Colors.white54,
                            size: 36,
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () =>
                                _closeMobilePip(pauseOnClose: false),
                            icon: const Icon(
                              Icons.open_in_full_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            label: Text(
                              effectiveConfig.text.restorePlayerText,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (kIsWeb && _webIframeId != null)
                    Stack(
                      fit: StackFit.expand,
                      children: [
                        buildYoutubeWebIframe(
                          _webIframeId!,
                          key: _webIframeKey,
                        ),
                        if (effectiveConfig.visibility.showControls)
                          Positioned(
                            bottom: 77,
                            right: 60,
                            child: Tooltip(
                              message: effectiveConfig.text.miniPlayerText,
                              child: Material(
                                color: const Color(0x99000000),
                                shape: const CircleBorder(),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _openMobilePip,
                                  child: const SizedBox(
                                    width: 33,
                                    height: 33,
                                    child: Center(
                                      child: Icon(
                                        Icons.picture_in_picture_alt_rounded,
                                        color: Colors.white,
                                        size: 17,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  else if (_useDesktopPlayer)
                    YouTubeDesktopPlayerView(
                      desktopWebViewKey: _desktopWebViewKey,
                      videoId: _videoId!,
                      config: effectiveConfig,
                      fullscreenManager: _desktopFullscreenManager,
                      onReady: () => log('Desktop YouTube player ready'),
                      onEnded: () => widget.onEnded?.call(),
                    )
                  else
                    YouTubeMobilePlayerView(
                      controller: controller!,
                      config: effectiveConfig,
                      isLive: widget.isLive,
                      viewerCount: widget.viewerCount,
                      isMuted: state.isMuted,
                      videoEnded: _videoEnded,
                      onFullscreenTap: _openFullScreen,
                      onMuteTap: _toggleMute,
                      onSettingsTap: _showSettingsBottomSheet,
                      onPipTap: _openMobilePip,
                      onSeekBackward: _seekBackward,
                      onSeekForward: _seekForward,
                      onRestartVideo: _restartVideo,
                      liveBadgeBuilder: widget.liveBadgeBuilder,
                      replayBuilder: widget.replayBuilder,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void play() => PlayerUtils.play(_controller);
  void pause() => PlayerUtils.pause(_controller);
  void stop() => PlayerUtils.reset(_controller);
  void seekTo(Duration position) => PlayerUtils.seekTo(_controller!, position);
  void mute() {
    PlayerUtils.setMute(_controller!, true);
    _cubit.setMuted(true);
  }

  void unMute() {
    PlayerUtils.setMute(_controller!, false);
    _cubit.setMuted(false);
  }

  void setPlaybackRate(double rate) =>
      PlayerUtils.setPlaybackRate(_controller, rate);
  Duration get currentPosition => _currentPosition;
  Duration get duration => PlayerUtils.getDuration(_controller);
  bool get isPlaying => PlayerUtils.isPlaying(_controller);
  void enterFullScreen() => _openFullScreen();
  void loadVideo(String videoSource) {
    final newVideoId = PlayerUtils.extractVideoId(videoSource);
    if (newVideoId != null && _controller != null) {
      PlayerUtils.loadVideo(_controller, newVideoId);
    }
  }
}
