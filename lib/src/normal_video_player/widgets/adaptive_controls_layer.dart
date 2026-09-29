import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../models/video_config.dart';
import '../utils/subtitle_parser.dart';
import '../utils/video_player_web_safe.dart';
import 'adaptive_bottom_bar.dart';
import 'adaptive_center_play_pause.dart';
import 'adaptive_player_settings_sheet.dart';
import 'adaptive_progress_bar.dart';
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
  final void Function(String event, Map<String, dynamic> data)?
      onAnalyticsEvent;
  final List<VideoQuality>? qualities;
  final VideoQuality? currentQuality;
  final void Function(VideoQuality)? onQualitySelected;
  final List<SubtitleTrack>? subtitles;
  final SubtitleTrack? currentSubtitleTrack;
  final void Function(SubtitleTrack?)? onSubtitleSelected;
  final List<SubtitleItem>? parsedSubtitles;
  final AdaptiveControlsBuilder? controlsBuilder;
  final SubtitleBuilder? subtitleBuilder;
  final bool isLive;
  final String? viewerCount;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onExitFullscreen;

  const AdaptiveControlsLayer({
    super.key,
    required this.controller,
    this.isFullScreen = false,
    this.styling,
    this.messages,
    this.onAnalyticsEvent,
    this.qualities,
    this.currentQuality,
    this.onQualitySelected,
    this.subtitles,
    this.currentSubtitleTrack,
    this.onSubtitleSelected,
    this.parsedSubtitles,
    this.controlsBuilder,
    this.subtitleBuilder,
    this.isLive = false,
    this.viewerCount,
    this.onEnterFullscreen,
    this.onExitFullscreen,
  });

  @override
  State<AdaptiveControlsLayer> createState() => _AdaptiveControlsLayerState();
}

class _AdaptiveControlsLayerState extends State<AdaptiveControlsLayer> {
  double? _dragPosition;
  bool _showSettingsMenu = false;

  bool get _hasTopBarContent {
    final showBack = widget.isFullScreen &&
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    return showBack || widget.isLive || widget.viewerCount != null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top Bar with YouTube-style subtle dark gradient (only if content present)
        if (_hasTopBarContent)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                top: 16,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC000000),
                    Color(0x66000000),
                    Colors.transparent,
                  ],
                ),
              ),
              child: AdaptiveTopBar(
                isFullScreen: widget.isFullScreen,
                onExitFullscreen: widget.onExitFullscreen,
                isLive: widget.isLive,
                viewerCount: widget.viewerCount,
                qualities: widget.qualities,
                onQualitySelected: widget.onQualitySelected,
                onAnalyticsEvent: widget.onAnalyticsEvent,
              ),
            ),
          ),

        // Center Play/Pause Indicator
        Align(
          alignment: Alignment.center,
          child: AdaptiveCenterPlayPause(
            controller: widget.controller,
            styling: widget.styling,
            onAnalyticsEvent: widget.onAnalyticsEvent,
          ),
        ),

        // Bottom Controls Layer with YouTube-style dark gradient
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xEE000000),
                  Color(0x88000000),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              bottom: widget.isFullScreen,
              left: widget.isFullScreen,
              right: widget.isFullScreen,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!widget.isLive)
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
                      onAnalyticsEvent: widget.onAnalyticsEvent,
                    ),
                  AdaptiveBottomBar(
                    controller: widget.controller,
                    isFullScreen: widget.isFullScreen,
                    isLive: widget.isLive,
                    styling: widget.styling,
                    messages: widget.messages,
                    qualities: widget.qualities,
                    currentQuality: widget.currentQuality,
                    onQualitySelected: widget.onQualitySelected,
                    subtitles: widget.subtitles,
                    currentSubtitleTrack: widget.currentSubtitleTrack,
                    onSubtitleSelected: widget.onSubtitleSelected,
                    onAnalyticsEvent: widget.onAnalyticsEvent,
                    onEnterFullscreen: widget.onEnterFullscreen,
                    onExitFullscreen: widget.onExitFullscreen,
                    onSettingsPressed: () =>
                        setState(() => _showSettingsMenu = !_showSettingsMenu),
                  ),
                ],
              ),
            ),
          ),
        ),

        // YouTube-style Floating Settings Dialog (rendered directly inside the player above the gear button)
        if (_showSettingsMenu) ...[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _showSettingsMenu = false),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            bottom: widget.isFullScreen ? 56 : 48,
            right: 16,
            child: CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.escape): () {
                  setState(() => _showSettingsMenu = false);
                },
              },
              child: Focus(
                autofocus: true,
                child: Container(
                  width: widget.isFullScreen ? 280 : 250,
                  constraints: BoxConstraints(
                    maxHeight: widget.isFullScreen ? 380 : 200,
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
                child: AdaptivePlayerSettingsSheet(
                  styling: widget.styling,
                  messages: widget.messages,
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
                  onDismiss: () => setState(() => _showSettingsMenu = false),
                  onAnalyticsEvent: widget.onAnalyticsEvent,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  ],
);
  }
}
