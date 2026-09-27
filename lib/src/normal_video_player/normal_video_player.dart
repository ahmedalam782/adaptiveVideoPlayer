import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/video_player_web_safe.dart';

import '../youtube_player/models/player_config.dart';
import 'adaptive_controls.dart';
import 'model/video_config.dart';
import 'utils/file_utils_export.dart';
import 'utils/fullscreen_utils_export.dart';
import 'utils/subtitle_parser.dart';

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

  /// Analytics hook for external tracking of video events
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;

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
    this.viewerCount,
    this.styling,
    this.messages,
    this.visibility,
    this.playback,
    this.controlsBuilder,
    this.subtitleBuilder,
    this.onAnalyticsEvent,
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

  bool _isInFullscreen = false;
  OverlayEntry? _fullscreenOverlay;
  final GlobalKey _basePlayerKey = GlobalKey();

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
    listenToFullscreenChange((isFullscreen) {
      if (!isFullscreen && _isInFullscreen && mounted) {
        _closeFullscreen();
      }
    });
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

    final currentPosition =
        _videoPlayerController?.value.position ?? Duration.zero;
    final isPlaying = _videoPlayerController?.value.isPlaying ?? false;

    // Cleanup old controller
    await _videoPlayerController?.dispose();

    setState(() {
      _isInitialized = false;
      _currentQuality = newQuality;
      _updateEffectiveSource();
    });

    await _initializeVideo(startAt: currentPosition, wasPlaying: isPlaying);
  }

  /// Validates if the URL is a valid video source
  bool _isValidVideoUrl(String url) {
    if (url.isEmpty) return false;

    // Check if it's a data URL (base64)
    if (url.startsWith('data:')) return true;

    if (_useFileController) {
      return checkFileExists(url);
    }

    // Check if it's a valid URL format
    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        return false;
      }

      // Check for common video file extensions
      final path = uri.path.toLowerCase();
      final videoExtensions = [
        '.mp4',
        '.mov',
        '.avi',
        '.mkv',
        '.webm',
        '.m4v',
        '.3gp',
        '.flv',
        '.wmv',
        '.m9v',
        '.m3u8', // Added HLS support
      ];

      // If URL has extension, check if it's a video extension
      if (path.contains('.')) {
        return videoExtensions.any((ext) => path.endsWith(ext));
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

      final isHls = _effectiveSource.contains('.m3u8');
      final formatHint = isHls ? VideoFormat.hls : null;

      _videoPlayerController = _useFileController
          ? getFileVideoController(_effectiveSource)
          : VideoPlayerController.networkUrl(
              Uri.parse(_effectiveSource),
              formatHint: formatHint,
            );

      await _videoPlayerController!.initialize();

      if (startAt != null &&
          !_effectiveIsLive &&
          !startAt.isNegative &&
          startAt.inMilliseconds > 0) {
        await _videoPlayerController!.seekTo(startAt);
      }

      if (widget.playback?.loop ?? false) {
        _videoPlayerController!.setLooping(true);
      }

      if (wasPlaying || (widget.playback?.autoPlay ?? false)) {
        _videoPlayerController!.play();
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      log('Video initialization error: $e');
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
  void dispose() {
    _closeFullscreen();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        decoration: BoxDecoration(
          color: widget.styling?.backgroundColor ?? Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: widget.styling?.errorIconColor ??
                        const Color.fromRGBO(255, 0, 0, 0.7),
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage,
                    style: TextStyle(
                      color: widget.styling?.textColor ??
                          const Color.fromRGBO(255, 0, 0, 0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        decoration: BoxDecoration(
          color: widget.styling?.backgroundColor ?? Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Center(
            child: CircularProgressIndicator(
              color: widget.styling?.loadingIndicatorColor ??
                  const Color.fromRGBO(255, 0, 0, 0.7),
              strokeCap: StrokeCap.round,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: AspectRatio(
          aspectRatio: _videoPlayerController!.value.isInitialized
              ? _videoPlayerController!.value.aspectRatio
              : 16 / 9,
          child: _isInFullscreen
              ? const SizedBox()
              : _buildBasePlayer(isFullScreen: false),
        ),
      ),
    );
  }

  void _openFullscreen() async {
    if (_isInFullscreen) return;

    _fullscreenOverlay = OverlayEntry(
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox.expand(
              child: _buildBasePlayer(isFullScreen: true),
            ),
          ),
        );
      },
    );

    setState(() {
      _isInFullscreen = true;
    });

    Overlay.of(context).insert(_fullscreenOverlay!);
    enterBrowserFullscreen();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _closeFullscreen() async {
    if (!_isInFullscreen || _fullscreenOverlay == null) return;

    _fullscreenOverlay?.remove();
    _fullscreenOverlay?.dispose();
    _fullscreenOverlay = null;

    setState(() {
      _isInFullscreen = false;
    });

    exitBrowserFullscreen();

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  Widget _buildBasePlayer({bool isFullScreen = false}) {
    return BaseAdaptiveVideoPlayer(
      key: _basePlayerKey,
      controller: _videoPlayerController!,
      showControls: widget.visibility?.showControls ?? true,
      isFullScreen: isFullScreen,
      isLive: _effectiveIsLive,
      controlsBuilder: widget.controlsBuilder,
      subtitleBuilder: widget.subtitleBuilder,
      styling: widget.styling,
      messages: widget.messages,
      onAnalyticsEvent: widget.onAnalyticsEvent,
      qualities: widget.qualities,
      currentQuality: _currentQuality,
      onQualitySelected: _changeQuality,
      subtitles: widget.subtitles,
      currentSubtitleTrack: _currentSubtitleTrack,
      onSubtitleSelected: _changeSubtitleTrack,
      parsedSubtitles: _parsedSubtitles,
      viewerCount: widget.viewerCount,
      onEnterFullscreen: _openFullscreen,
      onExitFullscreen: _closeFullscreen,
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
