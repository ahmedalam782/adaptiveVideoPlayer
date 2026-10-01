import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/services/native_pip_service.dart';
import '../youtube_player/models/youtube_player_config.dart';
import 'adaptive_controls.dart';
import 'coordinator/normal_fullscreen_coordinator.dart';
import 'models/video_config.dart';
import 'utils/file_utils_export.dart';
import 'utils/fullscreen_utils_export.dart';
import 'utils/subtitle_parser.dart';
import 'utils/video_player_web_safe.dart';
import 'views/normal_player_view.dart';
import 'widgets/normal_fullscreen_overlay.dart';
import 'widgets/normal_mini_player_overlay.dart';
import 'widgets/normal_player_error_widget.dart';
import 'widgets/normal_player_loading_widget.dart';

class NormalVideoPlayer extends StatefulWidget {
  final String videoSource;
  final bool isFile;
  final Uint8List? videoBytes;
  final bool isLive;

  /// External list of qualities / sources for resolution picker
  final List<VideoQuality>? qualities;

  /// Initial quality if qualities list is provided
  final VideoQuality? initialQuality;

  /// External list of subtitle tracks
  final List<SubtitleTrack>? subtitles;

  /// Initial subtitle track to activate
  final SubtitleTrack? initialSubtitle;

  /// Optional list of timeline chapters (similar to YouTube chapters)
  final List<VideoChapter>? chapters;

  /// Optional viewer count to display when stream is live
  final String? viewerCount;

  /// Styling configuration for the video player
  final PlayerStyleConfig? styling;

  /// Messages configuration for the video player
  final PlayerTextConfig? messages;

  /// Visibility configuration for the video player
  final PlayerVisibilityConfig? visibility;

  /// Playback configuration for the video player
  final PlayerPlaybackConfig? playback;

  /// Custom ui builder for rendering over the video
  final AdaptiveControlsBuilder? controlsBuilder;

  /// Custom builder for subtitles layer
  final SubtitleBuilder? subtitleBuilder;

  /// Custom loading widget builder
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Custom error widget builder
  final Widget Function(BuildContext context, String errorMessage)?
      errorBuilder;

  /// Analytics hook for external tracking of video events
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;

  /// Optional explicit video file extension (e.g. VideoFileExtension.hls)
  final VideoFileExtension? extension;

  /// Optional explicit video source type (e.g. VideoSourceType.network)
  final VideoSourceType? sourceType;

  /// Optional aspect ratio override for the video container
  final double? aspectRatio;

  const NormalVideoPlayer({
    super.key,
    required this.videoSource,
    this.isFile = false,
    this.isLive = false,
    this.videoBytes,
    this.qualities,
    this.initialQuality,
    this.subtitles,
    this.initialSubtitle,
    this.chapters,
    this.viewerCount,
    this.styling,
    this.messages,
    this.visibility,
    this.playback,
    this.controlsBuilder,
    this.subtitleBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.onAnalyticsEvent,
    this.extension,
    this.sourceType,
    this.aspectRatio,
  });

  @override
  NormalVideoPlayerState createState() => NormalVideoPlayerState();
}

class NormalVideoPlayerState extends State<NormalVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  late final bool _hasInMemoryData;
  late final bool _useFileController;
  late String _effectiveSource;
  VideoQuality? _currentQuality;
  SubtitleTrack? _currentSubtitleTrack;
  List<SubtitleItem> _parsedSubtitles = [];

  static OverlayEntry? _activeBackgroundMiniEntry;
  static VideoPlayerController? _activeBackgroundMiniController;

  static void _disposeBackgroundMiniPlayer() {
    exitDesktopPipMode();
    _activeBackgroundMiniEntry?.remove();
    _activeBackgroundMiniEntry = null;
    _activeBackgroundMiniController?.dispose();
    _activeBackgroundMiniController = null;
  }

  final NormalFullscreenCoordinator _fullscreenCoordinator =
      NormalFullscreenCoordinator();
  OverlayEntry? _miniPlayerOverlayEntry;
  bool _transferredToBackgroundMini = false;
  bool? _lastReportedPipPlaying;

  bool get _isInMiniPlayer => _miniPlayerOverlayEntry != null;
  bool get _effectiveIsLive => _currentQuality?.isLive ?? widget.isLive;

  @override
  void initState() {
    super.initState();
    NativePipService.isInPip.addListener(_onNativePipModeChanged);
    NativePipService.pipAction.addListener(_onPipActionReceived);
    _currentQuality = widget.initialQuality ?? widget.qualities?.firstOrNull;
    _currentSubtitleTrack = widget.initialSubtitle;
    _hasInMemoryData = widget.videoBytes != null;
    _updateEffectiveSource();
    _useFileController = widget.isFile && !_hasInMemoryData;
    _initializeVideo();
    _loadSubtitleTrack();
    _fullscreenCoordinator.initialize(
      onFullscreenChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  void _onNativePipModeChanged() {
    if (mounted) {
      setState(() {});
      if (NativePipService.isInPip.value && _videoPlayerController != null) {
        final currentPlaying = _videoPlayerController!.value.isPlaying;
        _lastReportedPipPlaying = currentPlaying;
        NativePipService.updatePlaybackState(isPlaying: currentPlaying);
      }
    }
  }

  void _onPipActionReceived() {
    if (!mounted) return;
    final action = NativePipService.pipAction.value;
    if (action == 'toggle_play') {
      final ctrl = _videoPlayerController;
      if (ctrl != null) {
        final isPlaying = ctrl.value.isPlaying;
        if (isPlaying) {
          ctrl.pause();
        } else {
          ctrl.play();
        }
        _lastReportedPipPlaying = !isPlaying;
        NativePipService.updatePlaybackState(isPlaying: !isPlaying);
        if (mounted) setState(() {});
      }
    }
  }


  @override
  void didUpdateWidget(covariant NormalVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Sync selected quality label when qualities list updates (e.g. language change)
    if (widget.qualities != null &&
        widget.qualities!.isNotEmpty &&
        _currentQuality != null) {
      final oldList = oldWidget.qualities;
      final oldIndex =
          oldList != null ? oldList.indexOf(_currentQuality!) : -1;
      if (oldIndex >= 0 && oldIndex < widget.qualities!.length) {
        _currentQuality = widget.qualities![oldIndex];
      } else {
        final byUrl = widget.qualities!
            .where((q) =>
                q.url == _currentQuality!.url &&
                q.isLive == _currentQuality!.isLive)
            .firstOrNull;
        if (byUrl != null) {
          _currentQuality = byUrl;
        }
      }
    }

    // Sync selected subtitle track when subtitles list updates (e.g. language change)
    if (widget.subtitles != null && _currentSubtitleTrack != null) {
      final byId = widget.subtitles!
          .where((s) => s.id == _currentSubtitleTrack!.id)
          .firstOrNull;
      if (byId != null && byId != _currentSubtitleTrack) {
        _currentSubtitleTrack = byId;
        _loadSubtitleTrack();
      }
    }

    if (_fullscreenCoordinator.isInFullscreen || _isInMiniPlayer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_fullscreenCoordinator.isInFullscreen) {
          _fullscreenCoordinator.rebuildOverlay();
        }
        if (_isInMiniPlayer) {
          _miniPlayerOverlayEntry?.markNeedsBuild();
        }
      });
    }
  }

  Future<void> _loadSubtitleTrack() async {
    if (_currentSubtitleTrack == null) {
      if (mounted) setState(() => _parsedSubtitles = []);
      return;
    }

    try {
      String subtitleContent = '';
      if (_currentSubtitleTrack!.content != null &&
          _currentSubtitleTrack!.content!.isNotEmpty) {
        subtitleContent = _currentSubtitleTrack!.content!;
      } else if (_currentSubtitleTrack!.fetcher != null) {
        subtitleContent = await _currentSubtitleTrack!.fetcher!();
      }

      if (mounted) {
        setState(() {
          _parsedSubtitles = SubtitleParser.parse(subtitleContent);
        });
      }
    } catch (e) {
      log('Error parsing subtitles: $e');
    }
  }

  void _changeSubtitleTrack(SubtitleTrack? newTrack) {
    if (_currentSubtitleTrack == newTrack) return;
    setState(() {
      _currentSubtitleTrack = newTrack;
      _parsedSubtitles = []; // clear while loading
    });
    _loadSubtitleTrack();
  }

  void _updateEffectiveSource() {
    if (_hasInMemoryData) {
      _effectiveSource =
          'data:video/mp4;base64,${base64Encode(widget.videoBytes!)}';
    } else if (_currentQuality != null) {
      _effectiveSource = _currentQuality!.url;
    } else {
      _effectiveSource = widget.videoSource;
    }
  }

  Future<void> _changeQuality(VideoQuality newQuality) async {
    if (_currentQuality == newQuality || !mounted) return;

    // Immediately update current quality so UI controls (e.g. checkmark in settings menu) reflect the selection
    setState(() {
      _currentQuality = newQuality;
    });

    // If identical URL, just update state without re-creating controller
    if (newQuality.url == _effectiveSource) {
      return;
    }

    final currentPosition =
        _videoPlayerController?.value.position ?? Duration.zero;
    final isPlaying = _videoPlayerController?.value.isPlaying ?? false;
    final currentVolume = _videoPlayerController?.value.volume ?? 1.0;
    final currentSpeed = _videoPlayerController?.value.playbackSpeed ?? 1.0;
    final oldController = _videoPlayerController;

    try {
      final isHls = widget.extension == VideoFileExtension.hls ||
          newQuality.url.contains('.m3u8');
      final isDash = widget.extension == VideoFileExtension.dash ||
          newQuality.url.contains('.mpd');
      final formatHint = isHls
          ? VideoFormat.hls
          : isDash
              ? VideoFormat.dash
              : null;

      final newController = _useFileController
          ? getFileVideoController(newQuality.url)
          : VideoPlayerController.networkUrl(
              Uri.parse(newQuality.url),
              formatHint: formatHint,
              videoPlayerOptions: VideoPlayerOptions(
                allowBackgroundPlayback: true,
                mixWithOthers: true,
              ),
            );

      await newController.initialize();
      newController.addListener(_handlePlayerControllerUpdate);
      if (!newQuality.isLive && currentPosition > Duration.zero) {
        await newController.seekTo(currentPosition);
      }
      await newController.setVolume(currentVolume);
      if (currentSpeed != 1.0) {
        await newController.setPlaybackSpeed(currentSpeed);
      }
      if (widget.playback?.loop ?? false) {
        await newController.setLooping(true);
      }
      if (isPlaying) {
        await newController.play();
      }

      if (mounted) {
        setState(() {
          _videoPlayerController = newController;
          _currentQuality = newQuality;
          _effectiveSource = newQuality.url;
        });
      }

      // Dispose old controller only after new controller is safely active
      oldController?.removeListener(_handlePlayerControllerUpdate);
      await oldController?.dispose();
    } catch (e) {
      log('Error during seamless quality change: $e');
      // Fallback to standard initialization if seamless switch failed
      _currentQuality = newQuality;
      _updateEffectiveSource();
      await oldController?.dispose();
      await _initializeVideo(startAt: currentPosition, wasPlaying: isPlaying);
    }
  }

  /// Validates if the URL is a valid video source
  bool _isValidVideoUrl(String url) {
    if (url.isEmpty) return false;

    // Check if it's a data URL (base64)
    if (url.startsWith('data:')) return true;

    if (_useFileController) {
      return checkFileExists(url);
    }

    // If extension is explicitly declared, it is valid
    if (widget.extension != null) return true;

    // Check if it's a valid URL format
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return false;
      }

      // Check for supported video file extensions using VideoFileExtension enum
      final path = uri.path.toLowerCase();
      if (path.contains('.')) {
        return VideoFileExtension.isSupported(path);
      }

      // If no extension, assume it might be a streaming URL
      return true;
    } catch (e) {
      log('URL validation error: $e');
      return false;
    }
  }

  Future<void> _initializeVideo(
      {Duration? startAt, bool wasPlaying = false}) async {
    try {
      // Validate URL first
      if (!_isValidVideoUrl(_effectiveSource)) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = widget.messages?.videoLoadFailedText ?? '';
          });
        } else {
          _hasError = true;
          _errorMessage = widget.messages?.videoLoadFailedText ?? '';
        }
        return;
      }

      final bool isNetworkSource = !_useFileController;
      if (isNetworkSource &&
          !_effectiveSource.startsWith('data:') &&
          _effectiveSource.startsWith('http://')) {
        log(
          'Warning: Using HTTP URL for video. Consider using HTTPS for production.',
        );
      }

      log(
        _hasInMemoryData
            ? 'Playing in-memory video source'
            : 'Playing video from: $_effectiveSource',
      );

      final isHls = widget.extension == VideoFileExtension.hls ||
          _effectiveSource.contains('.m3u8');
      final isDash = widget.extension == VideoFileExtension.dash ||
          _effectiveSource.contains('.mpd');
      final formatHint = isHls
          ? VideoFormat.hls
          : isDash
              ? VideoFormat.dash
              : null;

      _videoPlayerController = _useFileController
          ? getFileVideoController(_effectiveSource)
          : VideoPlayerController.networkUrl(
              Uri.parse(_effectiveSource),
              formatHint: formatHint,
              videoPlayerOptions: VideoPlayerOptions(
                allowBackgroundPlayback: true,
                mixWithOthers: true,
              ),
            );

      await _videoPlayerController!.initialize();
      _videoPlayerController!.addListener(_handlePlayerControllerUpdate);

      if (startAt != null && !_effectiveIsLive) {
        await _videoPlayerController!.seekTo(startAt);
      }

      if (widget.playback?.loop ?? false) {
        await _videoPlayerController!.setLooping(true);
      }

      if (widget.playback?.isMuted ?? false) {
        await _videoPlayerController!.setVolume(0.0);
      }

      final speed = widget.playback?.playbackSpeed;
      if (speed != null && speed > 0) {
        await _videoPlayerController!.setPlaybackSpeed(speed);
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }

      if (wasPlaying || (widget.playback?.autoPlay ?? true)) {
        try {
          await _videoPlayerController!.play();
        } catch (playError) {
          log('Unmuted autoplay blocked by browser, falling back to muted autoplay: $playError');
          try {
            await _videoPlayerController!.setVolume(0.0);
            await _videoPlayerController!.play();
          } catch (_) {}
        }
        _ensurePlaybackContinues(true);
      }
    } catch (e) {
      log('Video player initialization error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          if (e is PlatformException) {
            final errorMsg = e.message ?? e.toString();
            if (errorMsg.contains('MediaCodec') ||
                errorMsg.contains('ExoPlaybackException') ||
                errorMsg.contains('MEDIA_ERR_SRC_NOT_SUPPORTED') ||
                errorMsg.contains('DEMUXER_ERROR') ||
                errorMsg.contains('not supported')) {
              _errorMessage = widget.messages?.videoNotCompatibleText ??
                  'Video Not Compatible';
            } else {
              _errorMessage =
                  widget.messages?.videoCannotBeLoadedSecurityPolicyText ??
                      'Video Cannot Be Loaded Security Policy';
            }
          } else {
            _errorMessage =
                widget.messages?.videoLoadFailedText ?? 'Video Load Failed';
          }
        });
      }
    }
  }

  void _handlePlayerControllerUpdate() {
    if (!mounted || _videoPlayerController == null) return;
    if (_videoPlayerController!.value.hasError && !_hasError) {
      final errorMsg = _videoPlayerController!.value.errorDescription ?? '';
      log('Controller reported playback error: $errorMsg');
      setState(() {
        _hasError = true;
        if (errorMsg.contains('MediaCodec') ||
            errorMsg.contains('ExoPlaybackException') ||
            errorMsg.contains('MEDIA_ERR_SRC_NOT_SUPPORTED') ||
            errorMsg.contains('DEMUXER_ERROR') ||
            errorMsg.contains('not supported')) {
          _errorMessage = widget.messages?.videoNotCompatibleText ??
              'Video Not Compatible';
        } else {
          _errorMessage = widget.messages?.videoLoadFailedText ??
              (errorMsg.isNotEmpty ? errorMsg : 'Video Load Failed');
        }
      });
    }
    if (NativePipService.isInPip.value && _videoPlayerController != null) {
      final currentPlaying = _videoPlayerController!.value.isPlaying;
      if (_lastReportedPipPlaying != currentPlaying) {
        _lastReportedPipPlaying = currentPlaying;
        NativePipService.updatePlaybackState(isPlaying: currentPlaying);
      }
    }
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    if (_fullscreenCoordinator.isInFullscreen) {
      _fullscreenCoordinator.rebuildOverlay();
    }
  }

  @override
  void dispose() {
    NativePipService.isInPip.removeListener(_onNativePipModeChanged);
    NativePipService.pipAction.removeListener(_onPipActionReceived);
    _fullscreenCoordinator.dispose();
    if (_isInMiniPlayer && _videoPlayerController != null) {
      // Keep mini-player and controller alive in background when page pops
      _activeBackgroundMiniEntry = _miniPlayerOverlayEntry;
      _activeBackgroundMiniController = _videoPlayerController;
      _miniPlayerOverlayEntry = null;
      _videoPlayerController = null;
      _transferredToBackgroundMini = true;
    } else if (!_transferredToBackgroundMini) {
      _miniPlayerOverlayEntry?.remove();
      _miniPlayerOverlayEntry = null;
      _videoPlayerController?.removeListener(_handlePlayerControllerUpdate);
      _videoPlayerController?.dispose();
    }
    super.dispose();
  }

  PlayerTextConfig _resolveEffectiveMessages(BuildContext context) {
    final ambientDir = Directionality.maybeOf(context);
    final msg = widget.messages ?? const PlayerTextConfig();
    final resolvedDir =
        msg.resolveTextDirection(context, ambientDirection: ambientDir);
    final resolvedLang =
        msg.resolveLanguageCode(context, ambientDirection: ambientDir);
    return msg.copyWith(
      languageCode: resolvedLang,
      textDirection: resolvedDir,
    );
  }

  void _handleOpenFullscreen() {
    final wasPlaying = _videoPlayerController?.value.isPlaying ?? false;
    _fullscreenCoordinator.openFullscreen(
      context: context,
      builder: (overlayContext) {
        final activeCtx = mounted ? context : overlayContext;
        final effectiveMessages = _resolveEffectiveMessages(activeCtx);
        if (_hasError) {
          return NormalFullscreenOverlay(
            textDirection: effectiveMessages.resolveTextDirection(activeCtx),
            onExitFullscreen: _handleCloseFullscreen,
            child: NormalPlayerErrorWidget(
              errorMessage: _errorMessage,
              styling: widget.styling,
              customBuilder: widget.errorBuilder,
              onRetry: () {
                setState(() {
                  _hasError = false;
                  _isInitialized = false;
                });
                _initializeVideo();
              },
            ),
          );
        }

        if (!_isInitialized || _videoPlayerController == null) {
          return NormalFullscreenOverlay(
            textDirection: effectiveMessages.resolveTextDirection(activeCtx),
            onExitFullscreen: _handleCloseFullscreen,
            child: NormalPlayerLoadingWidget(
              styling: widget.styling,
              customBuilder: widget.loadingBuilder,
            ),
          );
        }

        return NormalFullscreenOverlay(
          textDirection: effectiveMessages.resolveTextDirection(activeCtx),
          onExitFullscreen: _handleCloseFullscreen,
          child: NormalPlayerView(
            controller: _videoPlayerController!,
            showControls: widget.visibility?.showControls ?? true,
            isFullScreen: true,
            isLive: _effectiveIsLive,
            controlsBuilder: widget.controlsBuilder,
            subtitleBuilder: widget.subtitleBuilder,
            styling: widget.styling,
            messages: effectiveMessages,
            visibility: widget.visibility,
            onAnalyticsEvent: widget.onAnalyticsEvent,
            qualities: widget.qualities,
            currentQuality: _currentQuality,
            onQualitySelected: _changeQuality,
            subtitles: widget.subtitles,
            currentSubtitleTrack: _currentSubtitleTrack,
            onSubtitleSelected: _changeSubtitleTrack,
            parsedSubtitles: _parsedSubtitles,
            chapters: widget.chapters,
            viewerCount: widget.viewerCount,
            onEnterFullscreen: () {},
            onExitFullscreen: _handleCloseFullscreen,
          ),
        );
      },
    );

    _ensurePlaybackContinues(wasPlaying);
  }

  void _handleCloseFullscreen() {
    final wasPlaying = _videoPlayerController?.value.isPlaying ?? false;
    _fullscreenCoordinator.closeFullscreen();
    _ensurePlaybackContinues(wasPlaying);
  }

  void _handleOpenMiniPlayer() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final entered = await NativePipService.enterPip();
      if (entered) return;
    }
    if (!mounted) return;
    if (_isInMiniPlayer || _videoPlayerController == null) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    // Clean up any older background mini-player before opening a new one
    _disposeBackgroundMiniPlayer();

    final wasPlaying = _videoPlayerController!.value.isPlaying;
    final controller = _videoPlayerController!;
    final initialMessages = _resolveEffectiveMessages(context);
    final initialStyling = widget.styling;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayCtx) {
        final effectiveMessages =
            mounted ? _resolveEffectiveMessages(context) : initialMessages;
        final styling = mounted ? widget.styling : initialStyling;
        final activeCtrl = _videoPlayerController ??
            _activeBackgroundMiniController ??
            controller;
        return NormalMiniPlayerOverlay(
          controller: activeCtrl,
          messages: effectiveMessages,
          styling: styling,
          onExpand: () {
            if (mounted) {
              _handleCloseMiniPlayer(pauseOnClose: false);
            } else {
              exitDesktopPipMode();
              entry.remove();
              if (_activeBackgroundMiniEntry == entry) {
                _activeBackgroundMiniEntry = null;
              }
            }
          },
          onClose: () {
            if (mounted) {
              _handleCloseMiniPlayer(pauseOnClose: true);
            } else {
              _disposeBackgroundMiniPlayer();
            }
          },
        );
      },
    );
    _miniPlayerOverlayEntry = entry;
    overlay.insert(entry);
    if (mounted) setState(() {});

    // Activate OS-level Picture-in-Picture (Windows always-on-top PiP window or Web native PiP)
    enterDesktopPipMode();
    entry.markNeedsBuild();

    if (wasPlaying) {
      _ensurePlaybackContinues(true);
    } else {
      // Refresh current position frame for mobile texture attachment
      controller.seekTo(controller.value.position);
    }
    widget.onAnalyticsEvent?.call('mini_player_opened', {});
  }

  void _handleCloseMiniPlayer({bool pauseOnClose = false}) {
    if (!_isInMiniPlayer) return;
    final wasPlaying = _videoPlayerController?.value.isPlaying ?? false;
    exitDesktopPipMode();
    _miniPlayerOverlayEntry?.remove();
    _miniPlayerOverlayEntry = null;
    if (pauseOnClose) {
      _videoPlayerController?.pause();
    } else {
      _ensurePlaybackContinues(wasPlaying);
    }
    if (mounted) setState(() {});
    widget.onAnalyticsEvent?.call('mini_player_closed', {'paused': pauseOnClose});
  }

  void _ensurePlaybackContinues(bool wasPlaying) {
    if (!wasPlaying) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = _videoPlayerController ?? _activeBackgroundMiniController;
      if (ctrl != null && !ctrl.value.isPlaying) {
        ctrl.play();
      }
    });
    Future.delayed(const Duration(milliseconds: 120), () {
      final ctrl = _videoPlayerController ?? _activeBackgroundMiniController;
      if (ctrl != null && !ctrl.value.isPlaying) {
        ctrl.play();
      }
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      final ctrl = _videoPlayerController ?? _activeBackgroundMiniController;
      if (ctrl != null && !ctrl.value.isPlaying) {
        ctrl.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return NormalPlayerErrorWidget(
        errorMessage: _errorMessage,
        styling: widget.styling,
        customBuilder: widget.errorBuilder,
        onRetry: () {
          setState(() {
            _hasError = false;
            _isInitialized = false;
          });
          _initializeVideo();
        },
      );
    }

    if (!_isInitialized) {
      return NormalPlayerLoadingWidget(
        styling: widget.styling,
        customBuilder: widget.loadingBuilder,
      );
    }

    final effectiveMessages = _resolveEffectiveMessages(context);

    final inNativePip = NativePipService.isInPip.value;
    final showControls =
        !inNativePip && (widget.visibility?.showControls ?? true);

    final playerView = NormalPlayerView(
      controller: _videoPlayerController!,
      showControls: showControls,
      isFullScreen: _fullscreenCoordinator.isInFullscreen,
      isLive: _effectiveIsLive,
      controlsBuilder: widget.controlsBuilder,
      subtitleBuilder: widget.subtitleBuilder,
      styling: widget.styling,
      messages: effectiveMessages,
      visibility: widget.visibility,
      playback: widget.playback,
      onAnalyticsEvent: widget.onAnalyticsEvent,
      qualities: widget.qualities,
      currentQuality: _currentQuality,
      onQualitySelected: _changeQuality,
      subtitles: widget.subtitles,
      currentSubtitleTrack: _currentSubtitleTrack,
      onSubtitleSelected: _changeSubtitleTrack,
      parsedSubtitles: _parsedSubtitles,
      chapters: widget.chapters,
      viewerCount: widget.viewerCount,
      onEnterFullscreen: _handleOpenFullscreen,
      onExitFullscreen: _handleCloseFullscreen,
      onMiniPlayerPressed: _handleOpenMiniPlayer,
    );

    final resolvedAspectRatio = widget.aspectRatio ??
        ((_videoPlayerController!.value.isInitialized &&
                _videoPlayerController!.value.aspectRatio > 0 &&
                !_videoPlayerController!.value.size.isEmpty &&
                _videoPlayerController!.value.size.width > 0 &&
                _videoPlayerController!.value.size.height > 0)
            ? _videoPlayerController!.value.aspectRatio
            : 16 / 9);

    final Widget contentChild;
    if (inNativePip) {
      contentChild = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final ctrl = _videoPlayerController;
          if (ctrl != null) {
            final isPlaying = ctrl.value.isPlaying;
            if (isPlaying) {
              ctrl.pause();
            } else {
              ctrl.play();
            }
            _lastReportedPipPlaying = !isPlaying;
            NativePipService.updatePlaybackState(isPlaying: !isPlaying);
            if (mounted) setState(() {});
          }
        },
        child: playerView,
      );
    } else if (_fullscreenCoordinator.isInFullscreen) {
      contentChild = const SizedBox();
    } else if (_isInMiniPlayer) {
      contentChild = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleCloseMiniPlayer(pauseOnClose: false),
        child: Material(
          color: Colors.black87,
          child: InkWell(
            onTap: () => _handleCloseMiniPlayer(pauseOnClose: false),
            hoverColor: Colors.white.withValues(alpha: 0.05),
            splashColor: Colors.white.withValues(alpha: 0.1),
            child: Center(
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
                        _handleCloseMiniPlayer(pauseOnClose: false),
                    icon: const Icon(
                      Icons.open_in_full_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    label: Text(
                      effectiveMessages.restorePlayerText,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      contentChild = playerView;
    }

    return ClipRRect(
      borderRadius: inNativePip ? BorderRadius.zero : BorderRadius.circular(8),
      child: Directionality(
        textDirection: effectiveMessages.resolveTextDirection(context),
        child: AspectRatio(
          aspectRatio: resolvedAspectRatio,
          child: contentChild,
        ),
      ),
    );
  }

  // Public methods
  void play() => _videoPlayerController?.play();
  void pause() => _videoPlayerController?.pause();
  void seekTo(Duration position) => _videoPlayerController?.seekTo(position);
  Duration get currentPosition =>
      _videoPlayerController?.value.position ?? Duration.zero;
  Duration get duration =>
      _videoPlayerController?.value.duration ?? Duration.zero;
  bool get isPlaying => _videoPlayerController?.value.isPlaying ?? false;
  void setPlaybackSpeed(double speed) =>
      _videoPlayerController?.setPlaybackSpeed(speed);
}
