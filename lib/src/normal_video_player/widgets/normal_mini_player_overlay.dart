import 'package:flutter/material.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../utils/fullscreen_utils_export.dart';
import '../utils/video_player_web_safe.dart';
import 'adaptive_video_surface.dart';
import 'pip_playback_chrome.dart';

/// Floating draggable Picture-in-Picture (Mini-Player) overlay for NormalVideoPlayer.
class NormalMiniPlayerOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onExpand;
  final VoidCallback onClose;
  final PlayerTextConfig? messages;
  final PlayerStyleConfig? styling;

  const NormalMiniPlayerOverlay({
    super.key,
    required this.controller,
    required this.onExpand,
    required this.onClose,
    this.messages,
    this.styling,
  });

  @override
  State<NormalMiniPlayerOverlay> createState() =>
      _NormalMiniPlayerOverlayState();
}

class _NormalMiniPlayerOverlayState extends State<NormalMiniPlayerOverlay> {
  Offset _offset = Offset.zero;
  bool _controlsVisible = true;

  Widget _buildMiniPlayerContent(bool isOsPipWindow) {
    final screenWidth = MediaQuery.maybeSizeOf(context)?.width ?? 360.0;
    final miniWidth = isOsPipWindow
        ? double.infinity
        : (screenWidth < 600
            ? (screenWidth * 0.58).clamp(190.0, 240.0)
            : 280.0);
    final miniHeight = isOsPipWindow ? double.infinity : (miniWidth * 9 / 16);

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerMove: (event) {
        if (event.buttons == 0) return;
        if (isOsPipWindow) {
          moveDesktopPipWindow(
            event.delta.dx.round(),
            event.delta.dy.round(),
          );
        } else {
          setState(() {
            _offset += event.delta;
          });
        }
      },
      child: Material(
        color: Colors.transparent,
        elevation: isOsPipWindow ? 0 : 14,
        borderRadius: BorderRadius.circular(isOsPipWindow ? 0 : 12),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: miniWidth,
          height: miniHeight,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(isOsPipWindow ? 0 : 12),
            border: isOsPipWindow
                ? null
                : Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                    width: 1,
                  ),
          ),
          child: ValueListenableBuilder(
            valueListenable: widget.controller,
            builder: (context, VideoPlayerValue value, _) {
              final durationMs = value.duration.inMilliseconds.toDouble();
              final positionMs = value.position.inMilliseconds.toDouble();
              final progress = durationMs > 0
                  ? (positionMs / durationMs).clamp(0.0, 1.0)
                  : 0.0;

              return Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio:
                          (value.isInitialized && value.aspectRatio > 0)
                              ? value.aspectRatio
                              : 16 / 9,
                      child: VideoPlayer(
                        widget.controller,
                        key: AdaptiveVideoSurface.keyForController(
                          widget.controller,
                        ),
                      ),
                    ),
                  ),
                  if (_controlsVisible)
                    PipPlaybackChrome(
                      isPlaying: value.isPlaying,
                      progress: progress,
                      closeTooltip: widget.messages?.closeMiniPlayerText ??
                          'Close miniplayer',
                      expandTooltip:
                          widget.messages?.expandPlayerText ?? 'Expand player',
                      playTooltip: widget.messages?.playText ?? 'Play',
                      pauseTooltip: widget.messages?.pauseText ?? 'Pause',
                      onClose: widget.onClose,
                      onExpand: widget.onExpand,
                      onPlayPause: () {
                        if (value.isPlaying) {
                          widget.controller.pause();
                        } else {
                          widget.controller.play();
                        }
                      },
                      onSeekBackward: () => _seekBy(-10),
                      onSeekForward: () => _seekBy(10),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = widget.messages?.resolveTextDirection(context) ??
        Directionality.maybeOf(context) ??
        TextDirection.ltr;
    final isRtl = textDirection == TextDirection.rtl;
    final isOsPipWindow = isDesktopPipMode();

    if (isOsPipWindow) {
      return Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SizedBox.expand(
            child: _buildMiniPlayerContent(true),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: textDirection,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: isRtl ? (16 + _offset.dx) : null,
            right: isRtl ? null : (16 - _offset.dx),
            bottom: 24 - _offset.dy,
            child: _buildMiniPlayerContent(false),
          ),
        ],
      ),
    );
  }

  void _seekBy(int seconds) {
    final value = widget.controller.value;
    var target = value.position + Duration(seconds: seconds);
    if (target.isNegative) target = Duration.zero;
    if (value.duration > Duration.zero && target > value.duration) {
      target = value.duration;
    }
    widget.controller.seekTo(target);
  }
}
