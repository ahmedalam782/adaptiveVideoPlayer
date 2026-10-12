import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../models/video_config.dart';
import '../utils/subtitle_parser.dart';
import '../utils/video_player_web_safe.dart';
import '../utils/player_chrome_utils.dart';
import '../utils/player_surface_tier.dart';
import 'adaptive_audio_subtitles_popup.dart';
import 'adaptive_bottom_bar.dart';
import 'adaptive_center_play_pause.dart';
import 'adaptive_episodes_drawer.dart';
import 'adaptive_inline_bottom_bar.dart';
import 'adaptive_player_settings_sheet.dart';
import 'mobile/mobile_controls_surface.dart';
import 'responsive/responsive_filled_panels.dart';
import 'adaptive_progress_bar.dart';
import 'adaptive_speed_stepper_popup.dart';
import 'adaptive_top_bar.dart';

typedef AdaptiveControlsBuilder = Widget Function(
    BuildContext context, VideoPlayerController controller, bool isFullScreen);

typedef SubtitleBuilder = Widget Function(
    BuildContext context, String subtitleText);

/// A modern, feature-rich controls overlay layer for NormalVideoPlayer.
/// Composed of dedicated widget components (Composite Pattern, OOP, SRP).
class AdaptiveControlsLayer extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isFullScreen;
  final PlayerStyleConfig? styling;
  final PlayerTextConfig? messages;
  final PlayerVisibilityConfig? visibility;
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;
  final List<VideoQuality>? qualities;
  final VideoQuality? currentQuality;
  final void Function(VideoQuality)? onQualitySelected;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final void Function(SubtitleTrack?)? onSubtitleSelected;
  final List<SubtitleItem>? parsedSubtitles;
  final List<VideoChapter>? chapters;
  final AdaptiveControlsBuilder? controlsBuilder;
  final SubtitleBuilder? subtitleBuilder;
  final bool isLive;
  final String? viewerCount;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onExitFullscreen;
  final PlayerPlaybackConfig? playback;
  final VoidCallback? onMiniPlayerPressed;
  final String? title;
  final List<VideoEpisode>? episodes;
  final VideoEpisode? currentEpisode;
  final void Function(VideoEpisode)? onEpisodeSelected;
  final VoidCallback? onNextEpisode;
  final List<AudioTrack>? audioTracks;
  final AudioTrack? currentAudioTrack;
  final void Function(AudioTrack)? onAudioTrackSelected;
  final ValueNotifier<double>? brightnessListenable;
  final bool screenLocked;
  final VoidCallback? onToggleScreenLock;
  final VoidCallback? onHideControls;
  final ValueChanged<bool>? onControlsPinnedChanged;

  const AdaptiveControlsLayer({
    super.key,
    required this.controller,
    this.isFullScreen = false,
    this.styling,
    this.messages,
    this.visibility,
    this.playback,
    this.onAnalyticsEvent,
    this.qualities,
    this.currentQuality,
    this.onQualitySelected,
    this.subtitles,
    this.currentSubtitleTrack,
    this.onSubtitleSelected,
    this.parsedSubtitles,
    this.chapters,
    this.controlsBuilder,
    this.subtitleBuilder,
    this.isLive = false,
    this.viewerCount,
    this.onEnterFullscreen,
    this.onExitFullscreen,
    this.onMiniPlayerPressed,
    this.title,
    this.episodes,
    this.currentEpisode,
    this.onEpisodeSelected,
    this.onNextEpisode,
    this.audioTracks,
    this.currentAudioTrack,
    this.onAudioTrackSelected,
    this.brightnessListenable,
    this.screenLocked = false,
    this.onToggleScreenLock,
    this.onHideControls,
    this.onControlsPinnedChanged,
  });

  @override
  State<AdaptiveControlsLayer> createState() => _AdaptiveControlsLayerState();
}

class _AdaptiveControlsLayerState extends State<AdaptiveControlsLayer> {
  double? _dragPosition;
  bool _showSettingsMenu = false;
  bool _showEpisodesDrawer = false;
  bool _showAudioSubtitlesPopup = false;
  bool _showSpeedStepperPopup = false;
  Offset _settingsMenuOffset = Offset.zero;
  bool _lastPinned = false;

  bool get _panelsOpen =>
      _showSettingsMenu ||
      _showEpisodesDrawer ||
      _showAudioSubtitlesPopup ||
      _showSpeedStepperPopup;

  void _publishPinned() {
    final pinned = _panelsOpen;
    if (pinned == _lastPinned) return;
    _lastPinned = pinned;
    widget.onControlsPinnedChanged?.call(pinned);
  }

  bool get _hasTopBarContent {
    if (widget.isFullScreen) return false;
    final showTitle = (widget.visibility?.showTitle ?? true) &&
        (widget.title?.isNotEmpty ?? false);
    return showTitle ||
        widget.isLive ||
        (widget.viewerCount?.isNotEmpty ?? false) ||
        (widget.visibility?.showActionsInTopBar ?? false) ||
        (widget.visibility?.showBackButton ?? false);
  }

  bool get _showCenterPlayPause =>
      (widget.visibility?.showCenterPlayPause ?? true) &&
      widget.styling?.bottomBarLayout != BottomBarLayout.inline;

  void _updateSettingsOffset(Offset delta, BoxConstraints constraints) {
    final dialogWidth = widget.isFullScreen ? 330.0 : 300.0;
    final dialogMaxHeight = widget.isFullScreen ? 380.0 : 220.0;
    final isRtl = (widget.messages ?? const PlayerTextConfig())
            .resolveTextDirection(context) ==
        TextDirection.rtl;
    final minX = isRtl ? -8.0 : -(constraints.maxWidth - dialogWidth - 32.0);
    final maxX = isRtl ? (constraints.maxWidth - dialogWidth - 32.0) : 8.0;
    final minY = -(constraints.maxHeight - dialogMaxHeight - 64.0);
    const maxY = 16.0;

    setState(() {
      final newX = (_settingsMenuOffset.dx + delta.dx).clamp(minX, maxX);
      final newY = (_settingsMenuOffset.dy + delta.dy).clamp(minY, maxY);
      _settingsMenuOffset = Offset(newX, newY);
    });
  }

  void _toggle(VoidCallback change) {
    setState(change);
    _publishPinned();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tier = playerSurfaceTierOf(
          context,
          Size(constraints.maxWidth, constraints.maxHeight),
        );
        if (tier == PlayerSurfaceTier.phone) {
          final isRtl = (widget.messages ?? const PlayerTextConfig())
                  .resolveTextDirection(context) ==
              TextDirection.rtl;
          return MobileControlsSurface(
            controller: widget.controller,
            isFullScreen: widget.isFullScreen,
            isLive: widget.isLive,
            screenLocked: widget.screenLocked,
            isRtl: isRtl,
            showAudioSubtitles: _showAudioSubtitlesPopup,
            showEpisodes: _showEpisodesDrawer,
            showSpeed: _showSpeedStepperPopup,
            showSettings: _showSettingsMenu,
            styling: widget.styling,
            messages: widget.messages,
            visibility: widget.visibility,
            playback: widget.playback,
            chapters: widget.chapters,
            onAnalyticsEvent: widget.onAnalyticsEvent,
            title: widget.title,
            currentEpisode: widget.currentEpisode,
            episodes: widget.episodes,
            audioTracks: widget.audioTracks,
            currentAudioTrack: widget.currentAudioTrack,
            subtitles: widget.subtitles,
            currentSubtitleTrack: widget.currentSubtitleTrack,
            qualities: widget.qualities,
            currentQuality: widget.currentQuality,
            dragPosition: _dragPosition,
            brightnessListenable: widget.brightnessListenable,
            onDragChanged: (val) => setState(() => _dragPosition = val),
            onDragEnd: (val) {
              widget.controller.seekTo(Duration(milliseconds: val.toInt()));
              setState(() => _dragPosition = null);
            },
            onEnterFullscreen: widget.onEnterFullscreen,
            onExitFullscreen: widget.onExitFullscreen,
            onMiniPlayerPressed: widget.onMiniPlayerPressed,
            onNextEpisode: widget.onNextEpisode,
            onEpisodesPressed: () => _toggle(() {
              _showEpisodesDrawer = !_showEpisodesDrawer;
              _showAudioSubtitlesPopup = false;
              _showSpeedStepperPopup = false;
              _showSettingsMenu = false;
            }),
            onAudioSubtitlesPressed: () => _toggle(() {
              _showAudioSubtitlesPopup = !_showAudioSubtitlesPopup;
              _showEpisodesDrawer = false;
              _showSpeedStepperPopup = false;
              _showSettingsMenu = false;
            }),
            onSpeedPressed: () => _toggle(() {
              _showSpeedStepperPopup = !_showSpeedStepperPopup;
              _showEpisodesDrawer = false;
              _showAudioSubtitlesPopup = false;
              _showSettingsMenu = false;
            }),
            onSettingsPressed: () => _toggle(() {
              _showSettingsMenu = !_showSettingsMenu;
              _showEpisodesDrawer = false;
              _showAudioSubtitlesPopup = false;
              _showSpeedStepperPopup = false;
            }),
            onLockPressed: widget.onToggleScreenLock,
            onUnlock: widget.onToggleScreenLock,
            onHideControls: widget.onHideControls,
            onAudioTrackSelected: widget.onAudioTrackSelected,
            onSubtitleSelected: widget.onSubtitleSelected,
            onEpisodeSelected: (episode) {
              widget.onEpisodeSelected?.call(episode);
              _toggle(() => _showEpisodesDrawer = false);
            },
            onQualitySelected: widget.onQualitySelected,
            onCloseAudioSubtitles: () =>
                _toggle(() => _showAudioSubtitlesPopup = false),
            onCloseEpisodes: () => _toggle(() => _showEpisodesDrawer = false),
            onCloseSpeed: () => _toggle(() => _showSpeedStepperPopup = false),
            onCloseSettings: () => _toggle(() => _showSettingsMenu = false),
          );
        }
        final tabletFit = tier == PlayerSurfaceTier.tablet;

        final bottomControls = Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xB3000000),
                Color(0x4D000000),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            bottom: widget.isFullScreen,
            left: widget.isFullScreen,
            right: widget.isFullScreen,
            child: widget.styling?.bottomBarLayout == BottomBarLayout.inline
                ? AdaptiveInlineBottomBar(
                    controller: widget.controller,
                    isFullScreen: widget.isFullScreen,
                    isLive: widget.isLive,
                    styling: widget.styling,
                    messages: widget.messages,
                    visibility: widget.visibility,
                    qualities: widget.qualities,
                    currentQuality: widget.currentQuality,
                    onQualitySelected: widget.onQualitySelected,
                    subtitles: widget.subtitles,
                    currentSubtitleTrack: widget.currentSubtitleTrack,
                    onSubtitleSelected: widget.onSubtitleSelected,
                    chapters: widget.chapters,
                    onAnalyticsEvent: widget.onAnalyticsEvent,
                    onEnterFullscreen: widget.onEnterFullscreen,
                    onExitFullscreen: widget.onExitFullscreen,
                    onMiniPlayerPressed: widget.onMiniPlayerPressed,
                    showSkipButtons:
                        widget.visibility?.showSkipButtons ?? true,
                    skipDuration: widget.visibility?.skipDuration ??
                        const Duration(seconds: 10),
                    onSettingsPressed: () => setState(
                        () => _showSettingsMenu = !_showSettingsMenu),
                    dragPosition: _dragPosition,
                    onDragChanged: (val) =>
                        setState(() => _dragPosition = val),
                    onDragEnd: (val) {
                      widget.controller
                          .seekTo(Duration(milliseconds: val.toInt()));
                      setState(() => _dragPosition = null);
                    },
                    title: widget.title,
                    episodes: widget.episodes,
                    onNextEpisode: widget.onNextEpisode,
                    onEpisodesPressed: () => setState(() {
                      _showEpisodesDrawer = !_showEpisodesDrawer;
                      _showAudioSubtitlesPopup = false;
                      _showSpeedStepperPopup = false;
                      _showSettingsMenu = false;
                    }),
                    audioTracks: widget.audioTracks,
                    onAudioSubtitlesPressed: () => setState(() {
                      _showAudioSubtitlesPopup = !_showAudioSubtitlesPopup;
                      _showEpisodesDrawer = false;
                      _showSpeedStepperPopup = false;
                      _showSettingsMenu = false;
                    }),
                    onSpeedPressed: () => setState(() {
                      _showSpeedStepperPopup = !_showSpeedStepperPopup;
                      _showEpisodesDrawer = false;
                      _showAudioSubtitlesPopup = false;
                      _showSettingsMenu = false;
                    }),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!widget.isLive &&
                          (widget.visibility?.showProgressBar ?? true))
                        AdaptiveProgressBar(
                          controller: widget.controller,
                          dragPosition: _dragPosition,
                          onDragChanged: (val) =>
                              setState(() => _dragPosition = val),
                          onDragEnd: (val) {
                            widget.controller
                                .seekTo(Duration(milliseconds: val.toInt()));
                            setState(() => _dragPosition = null);
                          },
                          styling: widget.styling,
                          chapters: widget.chapters,
                          playback: widget.playback,
                          messages: widget.messages,
                          visibility: widget.visibility,
                          onAnalyticsEvent: widget.onAnalyticsEvent,
                        ),
                      AdaptiveBottomBar(
                        controller: widget.controller,
                        isFullScreen: widget.isFullScreen,
                        isLive: widget.isLive,
                        styling: widget.styling,
                        messages: widget.messages,
                        visibility: widget.visibility,
                        qualities: widget.qualities,
                        currentQuality: widget.currentQuality,
                        onQualitySelected: widget.onQualitySelected,
                        subtitles: widget.subtitles,
                        currentSubtitleTrack: widget.currentSubtitleTrack,
                        onSubtitleSelected: widget.onSubtitleSelected,
                        chapters: widget.chapters,
                        onAnalyticsEvent: widget.onAnalyticsEvent,
                        onEnterFullscreen: widget.onEnterFullscreen,
                        onExitFullscreen: widget.onExitFullscreen,
                        onMiniPlayerPressed: widget.onMiniPlayerPressed,
                        showSkipButtons:
                            widget.visibility?.showSkipButtons ?? true,
                        skipDuration: widget.visibility?.skipDuration ??
                            const Duration(seconds: 10),
                        title: widget.title,
                        episodes: widget.episodes,
                        onNextEpisode: widget.onNextEpisode,
                        onEpisodesPressed: () => setState(() {
                          _showEpisodesDrawer = !_showEpisodesDrawer;
                          _showAudioSubtitlesPopup = false;
                          _showSpeedStepperPopup = false;
                          _showSettingsMenu = false;
                        }),
                        audioTracks: widget.audioTracks,
                        onAudioSubtitlesPressed: () => setState(() {
                          _showAudioSubtitlesPopup = !_showAudioSubtitlesPopup;
                          _showEpisodesDrawer = false;
                          _showSpeedStepperPopup = false;
                          _showSettingsMenu = false;
                        }),
                        onSpeedPressed: () => setState(() {
                          _showSpeedStepperPopup = !_showSpeedStepperPopup;
                          _showEpisodesDrawer = false;
                          _showAudioSubtitlesPopup = false;
                          _showSettingsMenu = false;
                        }),
                        onSettingsPressed: () => setState(
                            () => _showSettingsMenu = !_showSettingsMenu),
                      ),
                    ],
                  ),
          ),
        );

        return Stack(
          children: [
        if (!widget.isFullScreen)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: !_hasTopBarContent,
            child: Container(
            padding: const EdgeInsets.only(
              top: 16,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.styling?.topBarColor ?? const Color(0xCC000000),
                  (widget.styling?.topBarColor ?? const Color(0xCC000000))
                      .withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
            child: _hasTopBarContent
                ? SafeArea(
                    bottom: false,
                    top: widget.isFullScreen,
                    left: widget.isFullScreen,
                    right: widget.isFullScreen,
                    child: AdaptiveTopBar(
                      isFullScreen: widget.isFullScreen,
                      onExitFullscreen: widget.onExitFullscreen,
                      isLive: widget.isLive,
                      viewerCount: widget.viewerCount,
                      qualities: widget.qualities,
                      onQualitySelected: widget.onQualitySelected,
                      onAnalyticsEvent: widget.onAnalyticsEvent,
                      messages: widget.messages,
                      styling: widget.styling,
                      visibility: widget.visibility,
                      title: widget.title,
                      subtitle: PlayerChromeUtils.episodeSubtitle(
                        title: widget.title,
                        episodeTitle: widget.currentEpisode?.title,
                      ),
                      episodes: widget.episodes,
                      onEpisodesPressed: () => setState(() {
                        _showEpisodesDrawer = !_showEpisodesDrawer;
                        _showAudioSubtitlesPopup = false;
                        _showSpeedStepperPopup = false;
                        _showSettingsMenu = false;
                      }),
                      audioTracks: widget.audioTracks,
                      subtitles: widget.subtitles,
                      currentSubtitleTrack: widget.currentSubtitleTrack,
                      onSubtitleSelected: widget.onSubtitleSelected,
                      onAudioSubtitlesPressed: () => setState(() {
                        _showAudioSubtitlesPopup = !_showAudioSubtitlesPopup;
                        _showEpisodesDrawer = false;
                        _showSpeedStepperPopup = false;
                        _showSettingsMenu = false;
                      }),
                      onSpeedPressed: () => setState(() {
                        _showSpeedStepperPopup = !_showSpeedStepperPopup;
                        _showEpisodesDrawer = false;
                        _showAudioSubtitlesPopup = false;
                        _showSettingsMenu = false;
                      }),
                      onSettingsPressed: () => setState(
                          () => _showSettingsMenu = !_showSettingsMenu),
                      onMiniPlayerPressed: widget.onMiniPlayerPressed,
                    ),
                  )
                : const SizedBox(height: 28),
            ),
          ),
        ),

        Positioned.fill(
          child: Column(
            children: [
              if (_showCenterPlayPause)
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AdaptiveCenterPlayPause(
                      controller: widget.controller,
                      styling: widget.styling,
                      onAnalyticsEvent: widget.onAnalyticsEvent,
                      isFullScreen: widget.isFullScreen,
                    ),
                  ),
                )
              else
                const Spacer(),
              bottomControls,
            ],
          ),
        ),

        if (tabletFit && _panelsOpen)
          Positioned.fill(
            child: ResponsiveFilledPanels(
              showAudioSubtitles: _showAudioSubtitlesPopup,
              showEpisodes: _showEpisodesDrawer,
              showSpeed: _showSpeedStepperPopup,
              showSettings: _showSettingsMenu,
              controller: widget.controller,
              audioTracks: widget.audioTracks,
              currentAudioTrack: widget.currentAudioTrack,
              onAudioTrackSelected: widget.onAudioTrackSelected,
              subtitles: widget.subtitles,
              currentSubtitleTrack: widget.currentSubtitleTrack,
              onSubtitleSelected: widget.onSubtitleSelected,
              episodes: widget.episodes,
              currentEpisode: widget.currentEpisode,
              onEpisodeSelected: (episode) {
                widget.onEpisodeSelected?.call(episode);
                _toggle(() => _showEpisodesDrawer = false);
              },
              qualities: widget.qualities,
              currentQuality: widget.currentQuality,
              onQualitySelected: widget.onQualitySelected,
              styling: widget.styling,
              messages: widget.messages,
              visibility: widget.visibility,
              onAnalyticsEvent: widget.onAnalyticsEvent,
              onCloseAudioSubtitles: () =>
                  _toggle(() => _showAudioSubtitlesPopup = false),
              onCloseEpisodes: () => _toggle(() => _showEpisodesDrawer = false),
              onCloseSpeed: () =>
                  _toggle(() => _showSpeedStepperPopup = false),
              onCloseSettings: () => _toggle(() => _showSettingsMenu = false),
            ),
          ),

        if (!tabletFit && _showSettingsMenu) ...[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _showSettingsMenu = false),
              child: const SizedBox.expand(),
            ),
          ),
          PositionedDirectional(
            bottom: widget.isFullScreen ? 56 : 48,
            end: 16,
            child: Transform.translate(
              offset: _settingsMenuOffset,
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.escape): () {
                    setState(() => _showSettingsMenu = false);
                  },
                },
                child: Focus(
                  autofocus: true,
                  child: Container(
                    width: math.min(
                        widget.isFullScreen ? 330.0 : 300.0,
                        constraints.maxWidth - 24.0),
                    constraints: BoxConstraints(
                      maxHeight: math.min(
                        widget.isFullScreen ? 380.0 : 280.0,
                        math.max(140.0, constraints.maxHeight - 64),
                      ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: widget.styling?.settingsBackgroundColor ??
                          const Color(0xF21F1F1F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Sleek drag handle to move the settings dialog freely across screen
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanUpdate: (details) =>
                                _updateSettingsOffset(details.delta, constraints),
                            onDoubleTap: () =>
                                setState(() => _settingsMenuOffset = Offset.zero),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.move,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(top: 8, bottom: 6),
                                color: Colors.transparent,
                                child: Center(
                                  child: Container(
                                    width: 38,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: AdaptivePlayerSettingsSheet(
                              styling: widget.styling,
                              messages: widget.messages,
                              visibility: widget.visibility,
                              qualities: widget.qualities,
                              currentQuality: widget.currentQuality,
                              onQualitySelected: (q) {
                                widget.onQualitySelected?.call(q);
                                setState(() => _showSettingsMenu = false);
                              },
                              subtitles: widget.subtitles,
                              currentSubtitleTrack: widget.currentSubtitleTrack,
                              onSubtitleSelected: (s) {
                                widget.onSubtitleSelected?.call(s);
                                setState(() => _showSettingsMenu = false);
                              },
                              onDismiss: () =>
                                  setState(() => _showSettingsMenu = false),
                              onAnalyticsEvent: widget.onAnalyticsEvent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],

        // Netflix-style Speed Stepper Popup (Image 3)
        if (!tabletFit && _showSpeedStepperPopup) ...[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _showSpeedStepperPopup = false),
              child: const SizedBox.expand(),
            ),
          ),
          PositionedDirectional(
              bottom: widget.isFullScreen ? 60 : 52,
              end: 20,
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.escape): () {
                    setState(() => _showSpeedStepperPopup = false);
                  },
                },
                child: Focus(
                  autofocus: true,
                  child: AdaptiveSpeedStepperPopup(
                    controller: widget.controller,
                    styling: widget.styling,
                    messages: widget.messages,
                    maxWidth: math.min(420, constraints.maxWidth - 32),
                    onClose: () =>
                        setState(() => _showSpeedStepperPopup = false),
                  ),
                ),
              ),
            ),
        ],

        // Netflix-style Dual-Column Audio & Subtitles Popup (Image 1)
        if (!tabletFit && _showAudioSubtitlesPopup) ...[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _showAudioSubtitlesPopup = false),
              child: const SizedBox.expand(),
            ),
          ),
          PositionedDirectional(
              bottom: widget.isFullScreen ? 60 : 52,
              end: 20,
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.escape): () {
                    setState(() => _showAudioSubtitlesPopup = false);
                  },
                },
                child: Focus(
                  autofocus: true,
                  child: AdaptiveAudioSubtitlesPopup(
                    maxWidth: math.min(520, constraints.maxWidth - 32),
                    maxHeight: math.min(
                      380,
                      math.max(160, constraints.maxHeight - 80),
                    ),
                    audioTracks: widget.audioTracks,
                    currentAudioTrack: widget.currentAudioTrack,
                    onAudioTrackSelected: (track) {
                      widget.onAudioTrackSelected?.call(track);
                      setState(() => _showAudioSubtitlesPopup = false);
                    },
                    subtitles: widget.subtitles,
                    currentSubtitleTrack: widget.currentSubtitleTrack,
                    onSubtitleSelected: (track) {
                      widget.onSubtitleSelected?.call(track);
                      setState(() => _showAudioSubtitlesPopup = false);
                    },
                    styling: widget.styling,
                    messages: widget.messages,
                    onClose: () =>
                        setState(() => _showAudioSubtitlesPopup = false),
                  ),
                ),
              ),
            ),
        ],

        // Netflix-style Episodes Drawer (Image 5)
        if (!tabletFit && _showEpisodesDrawer && widget.episodes != null) ...[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _showEpisodesDrawer = false),
              child: const SizedBox.expand(),
            ),
          ),
          PositionedDirectional(
              bottom: widget.isFullScreen ? 60 : 52,
              end: 20,
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.escape): () {
                    setState(() => _showEpisodesDrawer = false);
                  },
                },
                child: Focus(
                  autofocus: true,
                  child: AdaptiveEpisodesDrawer(
                    maxWidth: math.min(440, constraints.maxWidth - 32),
                    maxHeight: math.min(
                      520,
                      math.max(180, constraints.maxHeight - 80),
                    ),
                    episodes: widget.episodes!,
                    currentEpisode: widget.currentEpisode,
                    onEpisodeSelected: (ep) {
                      widget.onEpisodeSelected?.call(ep);
                      setState(() => _showEpisodesDrawer = false);
                    },
                    styling: widget.styling,
                    messages: widget.messages,
                    onClose: () => setState(() => _showEpisodesDrawer = false),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
      },
    );
  }
}

