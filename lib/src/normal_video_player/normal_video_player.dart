import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final GlobalKey _playerViewKey = GlobalKey();
  OverlayEntry? _miniPlayerOverlayEntry;
  bool _transferredToBackgroundMini = false;

  bool get _isInMiniPlayer => _miniPlayerOverlayEntry != null;
  bool get _effectiveIsLive => _currentQuality?.isLive ?? widget.isLive;

  @override
  void initState() {
    super.initState();
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

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    if (_fullscreenCoordinator.isInFullscreen) {
      _fullscreenCoordinator.rebuildOverlay();
    }
  }

  @override
  void dispose() {
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
      _videoPlayerController?.dispose();
    }
    super.dispose();
  }

  PlayerTextConfig _resolveEffectiveMessages(BuildContext context) {
    final ambientDir = Directionality.maybeOf(context);
    final msg = widget.messages;
    if (msg == null || msg.isDefaultUnmodified) {
      final resolvedDir = (msg ?? const PlayerTextConfig())
          .resolveTextDirection(context, ambientDirection: ambientDir);
      final resolvedLang = (msg ?? const PlayerTextConfig())
          .resolveLanguageCode(context, ambientDirection: ambientDir);
      if (resolvedLang.toLowerCase() == 'ar' ||
          resolvedDir == TextDirection.rtl) {
        return PlayerTextConfig.arabic(
          languageCode: resolvedLang,
          textDirection: resolvedDir,
        );
      }
      return PlayerTextConfig.english(
        languageCode: resolvedLang,
        textDirection: resolvedDir,
      );
    }
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
            textDirection: TextDirection.ltr,
            onExitFullscreen: _handleCloseFullscreen,
            child: NormalPlayerErrorWidget(
              errorMessage: _errorMessage,
              styling: widget.styling,
              customBuilder: widget.errorBuilder,
            ),
          );
        }

        if (!_isInitialized || _videoPlayerController == null) {
          return NormalFullscreenOverlay(
            textDirection: TextDirection.ltr,
            onExitFullscreen: _handleCloseFullscreen,
            child: NormalPlayerLoadingWidget(
              styling: widget.styling,
              customBuilder: widget.loadingBuilder,
            ),
          );
        }

        return NormalFullscreenOverlay(
          textDirection: TextDirection.ltr,
          onExitFullscreen: _handleCloseFullscreen,
          child: NormalPlayerView(
            key: _playerViewKey,
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

  void _handleOpenMiniPlayer() {
    if (_isInMiniPlayer || _videoPlayerController == null) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    // Clean up any older background mini-player before opening a new one
    _disposeBackgroundMiniPlayer();

    final wasPlaying = _videoPlayerController!.value.isPlaying;
    final controller = _videoPlayerController!;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayCtx) {
        final activeCtx = mounted ? context : overlayCtx;
        final effectiveMessages = _resolveEffectiveMessages(activeCtx);
        return NormalMiniPlayerOverlay(
          controller: controller,
          messages: effectiveMessages,
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

    _ensurePlaybackContinues(wasPlaying);
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
      );
    }

    if (!_isInitialized) {
      return NormalPlayerLoadingWidget(
        styling: widget.styling,
        customBuilder: widget.loadingBuilder,
      );
    }

    final effectiveMessages = _resolveEffectiveMessages(context);

    final playerView = NormalPlayerView(
      key: _playerViewKey,
      controller: _videoPlayerController!,
      showControls: widget.visibility?.showControls ?? true,
      isFullScreen: _fullscreenCoordinator.isInFullscreen,
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
      onEnterFullscreen: _handleOpenFullscreen,
      onExitFullscreen: _handleCloseFullscreen,
      onMiniPlayerPressed: _handleOpenMiniPlayer,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: AspectRatio(
          aspectRatio: (_videoPlayerController!.value.isInitialized &&
                  _videoPlayerController!.value.aspectRatio > 0)
              ? _videoPlayerController!.value.aspectRatio
              : 16 / 9,
          child: _fullscreenCoordinator.isInFullscreen
              ? const SizedBox()
              : _isInMiniPlayer
                  ? Container(
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
                    )
                  : playerView,
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
