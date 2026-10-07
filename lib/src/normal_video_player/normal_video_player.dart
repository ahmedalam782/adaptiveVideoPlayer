import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../core/services/native_pip_service.dart';
import '../youtube_player/models/youtube_player_config.dart';
import 'adaptive_controls.dart';
import 'mixins/normal_player_controller_mixin.dart';
import 'mixins/normal_player_fullscreen_mixin.dart';
import 'mixins/normal_player_pip_mixin.dart';
import 'mixins/normal_player_playback_resilience_mixin.dart';
import 'mixins/normal_player_subtitles_mixin.dart';
import 'models/normal_player_display_mode.dart';
import 'models/video_config.dart';
import 'utils/video_player_web_safe.dart';
import 'views/normal_player_view.dart';
import 'widgets/normal_fullscreen_overlay.dart';
import 'widgets/normal_mini_player_placeholder.dart';
import 'widgets/normal_native_pip_view.dart';
import 'widgets/normal_player_error_widget.dart';
import 'widgets/normal_player_loading_widget.dart';

class NormalVideoPlayer extends StatefulWidget {
  /// Unified configuration model for the normal video player.
  final VideoConfig config;

  /// Creates a [NormalVideoPlayer] directly from a unified [VideoConfig] model.
  const NormalVideoPlayer.fromConfig({
    super.key,
    required this.config,
  });

  const NormalVideoPlayer._internal({
    super.key,
    required this.config,
  });

  /// Creates a [NormalVideoPlayer].
  ///
  /// Accepts either a unified [config] model or individual parameters for
  /// seamless backwards compatibility.
  factory NormalVideoPlayer({
    Key? key,
    VideoConfig? config,
    String? videoSource,
    bool isFile = false,
    bool isLive = false,
    Uint8List? videoBytes,
    List<VideoQuality>? qualities,
    VideoQuality? initialQuality,
    List<SubtitleTrack>? subtitles,
    SubtitleTrack? initialSubtitle,
    List<VideoChapter>? chapters,
    String? viewerCount,
    PlayerStyleConfig? styling,
    PlayerTextConfig? messages,
    PlayerVisibilityConfig? visibility,
    PlayerPlaybackConfig? playback,
    AdaptiveControlsBuilder? controlsBuilder,
    SubtitleBuilder? subtitleBuilder,
    Widget Function(BuildContext context)? loadingBuilder,
    Widget Function(BuildContext context, String errorMessage)? errorBuilder,
    void Function(String event, Map<String, dynamic> data)? onAnalyticsEvent,
    VideoFileExtension? extension,
    VideoSourceType? sourceType,
    double? aspectRatio,
  }) {
    if (config != null) {
      return NormalVideoPlayer._internal(
        key: key,
        config: config,
      );
    }
    return NormalVideoPlayer._internal(
      key: key,
      config: VideoConfig(
        videoUrl: videoSource ?? '',
        isFile: isFile,
        isLive: isLive,
        videoBytes: videoBytes,
        qualities: qualities,
        initialQuality: initialQuality,
        subtitles: subtitles,
        initialSubtitle: initialSubtitle,
        chapters: chapters,
        viewerCount: viewerCount,
        controlsBuilder: controlsBuilder,
        subtitleBuilder: subtitleBuilder,
        loadingBuilder: loadingBuilder,
        errorBuilder: errorBuilder,
        onAnalyticsEvent: onAnalyticsEvent,
        extension: extension,
        sourceType: sourceType,
        aspectRatio: aspectRatio,
        playerConfig: YouTubePlayerConfig(
          style: styling ?? const PlayerStyleConfig(),
          text: messages ?? const PlayerTextConfig(),
          visibility: visibility ?? const PlayerVisibilityConfig(),
          playback: playback ?? const PlayerPlaybackConfig(),
        ),
      ),
    );
  }

  // Delegated getters to maintain clean property access and backwards compatibility
  String get videoSource => config.videoUrl;
  bool get isFile => config.isFile;
  bool get isLive => config.isLive;
  Uint8List? get videoBytes => config.videoBytes;
  List<VideoQuality>? get qualities => config.qualities;
  VideoQuality? get initialQuality => config.initialQuality;
  List<SubtitleTrack>? get subtitles => config.subtitles;
  SubtitleTrack? get initialSubtitle => config.initialSubtitle;
  List<VideoChapter>? get chapters => config.chapters;
  String? get viewerCount => config.viewerCount;
  PlayerStyleConfig get styling => config.styling;
  PlayerTextConfig get messages => config.messages;
  PlayerVisibilityConfig get visibility => config.visibility;
  PlayerPlaybackConfig get playback => config.playback;
  AdaptiveControlsBuilder? get controlsBuilder => config.controlsBuilder;
  SubtitleBuilder? get subtitleBuilder => config.subtitleBuilder;
  Widget Function(BuildContext context)? get loadingBuilder =>
      config.loadingBuilder;
  Widget Function(BuildContext context, String errorMessage)?
      get errorBuilder => config.errorBuilder;
  void Function(String event, Map<String, dynamic> data)?
      get onAnalyticsEvent => config.onAnalyticsEvent;
  VideoFileExtension? get extension => config.extension;
  VideoSourceType? get sourceType => config.sourceType;
  double? get aspectRatio => config.aspectRatio;

  @override
  NormalVideoPlayerState createState() => NormalVideoPlayerState();
}

class NormalVideoPlayerState extends State<NormalVideoPlayer>
    with
        NormalPlayerControllerMixin,
        NormalPlayerSubtitlesMixin,
        NormalPlayerPlaybackResilienceMixin,
        NormalPlayerFullscreenMixin,
        NormalPlayerPipMixin {
  @override
  VideoPlayerController? get resilienceController =>
      videoPlayerController ??
      NormalPlayerPipMixin.activeBackgroundMiniController;

  @override
  VideoPlayerController? get activePipController => videoPlayerController;

  @override
  void onHoldPlayback() => holdPlayback();

  @override
  void onResumeHeldPlayback() => resumeHeldPlayback();

  @override
  void onEnsurePlaybackContinues(bool wasPlaying) =>
      ensurePlaybackContinues(wasPlaying);

  @override
  void initState() {
    super.initState();
    initPipListeners();
    initControllerState();
    initializeVideo(
      onPlaybackUpdate: _handlePlayerControllerUpdate,
      onEnsurePlayback: ensurePlaybackContinues,
    );
    initSubtitles();
    initFullscreenCoordinator();
  }

  @override
  void didUpdateWidget(covariant NormalVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncQualityOnUpdate(oldWidget);
    syncSubtitlesOnUpdate(oldWidget);

    if (isInFullscreen || isInMiniPlayer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        rebuildFullscreenOverlayIfNeeded();
        if (isInMiniPlayer) {
          miniPlayerOverlayEntry?.markNeedsBuild();
        }
      });
    }
  }

  void _handlePlayerControllerUpdate() {
    handleControllerPlaybackUpdate(handlePipControllerUpdate);
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    rebuildFullscreenOverlayIfNeeded();
  }

  @override
  void dispose() {
    disposeFullscreenCoordinator();
    handlePipDisposal(() {
      videoPlayerController?.removeListener(_handlePlayerControllerUpdate);
      videoPlayerController?.dispose();
    });
    super.dispose();
  }

  @override
  PlayerTextConfig resolveEffectiveMessages(BuildContext context) {
    final ambientDir = Directionality.maybeOf(context);
    final msg = widget.messages;
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
    openFullscreenView(
      builder: (overlayContext) {
        final activeCtx = mounted ? context : overlayContext;
        final effectiveMessages = resolveEffectiveMessages(activeCtx);
        if (hasError) {
          return NormalFullscreenOverlay(
            textDirection: effectiveMessages.resolveTextDirection(activeCtx),
            onExitFullscreen: _handleCloseFullscreen,
            child: NormalPlayerErrorWidget(
              errorMessage: errorMessage,
              styling: widget.styling,
              customBuilder: widget.errorBuilder,
              onRetry: () {
                setState(() {
                  hasError = false;
                  isInitialized = false;
                });
                initializeVideo(
                  onPlaybackUpdate: _handlePlayerControllerUpdate,
                  onEnsurePlayback: ensurePlaybackContinues,
                );
              },
            ),
          );
        }

        if (!isInitialized || videoPlayerController == null) {
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
            controller: videoPlayerController!,
            showControls: widget.visibility.showControls,
            isFullScreen: true,
            isLive: effectiveIsLive,
            controlsBuilder: widget.controlsBuilder,
            subtitleBuilder: widget.subtitleBuilder,
            styling: widget.styling,
            messages: effectiveMessages,
            visibility: widget.visibility,
            onAnalyticsEvent: widget.onAnalyticsEvent,
            qualities: widget.qualities,
            currentQuality: currentQuality,
            onQualitySelected: (q) => changeQuality(
              q,
              onPlaybackUpdate: _handlePlayerControllerUpdate,
              onEnsurePlayback: ensurePlaybackContinues,
            ),
            subtitles: widget.subtitles,
            currentSubtitleTrack: currentSubtitleTrack,
            onSubtitleSelected: changeSubtitleTrack,
            parsedSubtitles: parsedSubtitles,
            chapters: widget.chapters,
            viewerCount: widget.viewerCount,
            onEnterFullscreen: () {},
            onExitFullscreen: _handleCloseFullscreen,
          ),
        );
      },
      onBeforeOpen: holdPlayback,
      onAfterOpen: resumeHeldPlayback,
    );
  }

  void _handleCloseFullscreen() {
    closeFullscreenView(
      onBeforeClose: holdPlayback,
      onAfterClose: resumeHeldPlayback,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return NormalPlayerErrorWidget(
        errorMessage: errorMessage,
        styling: widget.styling,
        customBuilder: widget.errorBuilder,
        onRetry: () {
          setState(() {
            hasError = false;
            isInitialized = false;
          });
          initializeVideo(
            onPlaybackUpdate: _handlePlayerControllerUpdate,
            onEnsurePlayback: ensurePlaybackContinues,
          );
        },
      );
    }

    if (!isInitialized) {
      return NormalPlayerLoadingWidget(
        styling: widget.styling,
        customBuilder: widget.loadingBuilder,
      );
    }

    final effectiveMessages = resolveEffectiveMessages(context);
    final inNativePip = NativePipService.isInPip.value;
    final showControls = !inNativePip && widget.visibility.showControls;

    final playerView = NormalPlayerView(
      controller: videoPlayerController!,
      showControls: showControls,
      isFullScreen: isInFullscreen,
      isLive: effectiveIsLive,
      controlsBuilder: widget.controlsBuilder,
      subtitleBuilder: widget.subtitleBuilder,
      styling: widget.styling,
      messages: effectiveMessages,
      visibility: widget.visibility,
      playback: widget.playback,
      onAnalyticsEvent: widget.onAnalyticsEvent,
      qualities: widget.qualities,
      currentQuality: currentQuality,
      onQualitySelected: (q) => changeQuality(
        q,
        onPlaybackUpdate: _handlePlayerControllerUpdate,
        onEnsurePlayback: ensurePlaybackContinues,
      ),
      subtitles: widget.subtitles,
      currentSubtitleTrack: currentSubtitleTrack,
      onSubtitleSelected: changeSubtitleTrack,
      parsedSubtitles: parsedSubtitles,
      chapters: widget.chapters,
      viewerCount: widget.viewerCount,
      onEnterFullscreen: _handleOpenFullscreen,
      onExitFullscreen: _handleCloseFullscreen,
      onMiniPlayerPressed: openMiniPlayer,
    );

    final resolvedAspectRatio = widget.aspectRatio ??
        ((videoPlayerController!.value.isInitialized &&
                videoPlayerController!.value.aspectRatio > 0 &&
                !videoPlayerController!.value.size.isEmpty &&
                videoPlayerController!.value.size.width > 0 &&
                videoPlayerController!.value.size.height > 0)
            ? videoPlayerController!.value.aspectRatio
            : 16 / 9);

    final displayMode = inNativePip
        ? NormalPlayerDisplayMode.nativePip
        : isInFullscreen
            ? NormalPlayerDisplayMode.fullscreen
            : isInMiniPlayer
                ? NormalPlayerDisplayMode.miniPlayer
                : NormalPlayerDisplayMode.normal;

    final Widget contentChild = switch (displayMode) {
      NormalPlayerDisplayMode.fullscreen => const SizedBox.shrink(),
      NormalPlayerDisplayMode.miniPlayer => NormalMiniPlayerPlaceholder(
          restoreText: effectiveMessages.restorePlayerText,
          onRestore: () => closeMiniPlayer(pauseOnClose: false),
        ),
      NormalPlayerDisplayMode.nativePip => NormalNativePipView(
          controller: videoPlayerController!,
          playerView: playerView,
          messages: effectiveMessages,
          onClose: () {
            videoPlayerController?.pause();
            NativePipService.closePip();
          },
          onExpand: NativePipService.exitPip,
          onPlayPause: () {
            final ctrl = videoPlayerController;
            if (ctrl == null) return;
            if (ctrl.value.isPlaying) {
              ctrl.pause();
            } else {
              ctrl.play();
            }
            lastReportedPipPlaying = !ctrl.value.isPlaying;
            NativePipService.updatePlaybackState(
              isPlaying: !ctrl.value.isPlaying,
            );
          },
          onSeekBackward: () => pipSeek(-10),
          onSeekForward: () => pipSeek(10),
        ),
      NormalPlayerDisplayMode.normal => playerView,
    };

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

  // Public playback API
  void play() => videoPlayerController?.play();
  void pause() => videoPlayerController?.pause();
  void seekTo(Duration position) => videoPlayerController?.seekTo(position);
  Duration get currentPosition =>
      videoPlayerController?.value.position ?? Duration.zero;
  Duration get duration =>
      videoPlayerController?.value.duration ?? Duration.zero;
  bool get isPlaying => videoPlayerController?.value.isPlaying ?? false;
  void setPlaybackSpeed(double speed) =>
      videoPlayerController?.setPlaybackSpeed(speed);
}
