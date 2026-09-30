import 'package:flutter/material.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../utils/fullscreen_utils_export.dart';
import '../utils/video_player_web_safe.dart';
import 'adaptive_video_surface.dart';

/// Floating draggable Picture-in-Picture (Mini-Player) overlay for NormalVideoPlayer.
class NormalMiniPlayerOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onExpand;
  final VoidCallback onClose;
  final PlayerTextConfig? messages;

  const NormalMiniPlayerOverlay({
    super.key,
    required this.controller,
    required this.onExpand,
    required this.onClose,
    this.messages,
  });

  @override
  State<NormalMiniPlayerOverlay> createState() =>
      _NormalMiniPlayerOverlayState();
}

class _NormalMiniPlayerOverlayState extends State<NormalMiniPlayerOverlay> {
  Offset _offset = Offset.zero;
  bool _controlsVisible = true;

  Widget _buildMiniPlayerContent(bool isOsPipWindow) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (isOsPipWindow) {
          moveDesktopPipWindow(
            details.delta.dx.round(),
            details.delta.dy.round(),
          );
        } else {
          setState(() {
            _offset += details.delta;
          });
        }
      },
      onTap: () {
        setState(() {
          _controlsVisible = !_controlsVisible;
        });
      },
      child: Material(
        color: Colors.transparent,
        elevation: isOsPipWindow ? 0 : 14,
        borderRadius: BorderRadius.circular(isOsPipWindow ? 0 : 12),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: isOsPipWindow ? double.infinity : 280,
          height: isOsPipWindow ? double.infinity : 158,
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
                        Container(
                          color: Colors.black.withValues(alpha: 0.38),
                          child: Stack(
                            children: [
                              // Top bar: Expand & Close buttons
                              Positioned(
                                top: 6,
                                left: 8,
                                right: 8,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildMiniIconButton(
                                      icon: Icons.open_in_full_rounded,
                                      tooltip: widget.messages?.expandPlayerText ??
                                          'Expand player',
                                      onTap: widget.onExpand,
                                    ),
                                    _buildMiniIconButton(
                                      icon: Icons.close_rounded,
                                      tooltip:
                                          widget.messages?.closeMiniPlayerText ??
                                              'Close miniplayer',
                                      onTap: widget.onClose,
                                    ),
                                  ],
                                ),
                              ),
                              // Center Play/Pause button
                              Center(
                                child: _buildMiniIconButton(
                                  icon: value.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  tooltip: value.isPlaying
                                      ? (widget.messages?.pauseText ?? 'Pause')
                                      : (widget.messages?.playText ?? 'Play'),
                                  size: 26,
                                  buttonSize: 42,
                                  onTap: () {
                                    if (value.isPlaying) {
                                      widget.controller.pause();
                                    } else {
                                      widget.controller.play();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Bottom red progress bar
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 3,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFF0033),
                          ),
                        ),
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
    final isOsPipWindow = isDesktopPipMode();
    if (isOsPipWindow) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SizedBox.expand(
            child: _buildMiniPlayerContent(true),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: 16 - _offset.dx,
            bottom: 24 - _offset.dy,
            child: _buildMiniPlayerContent(false),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    double size = 18,
    double buttonSize = 30,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: const BoxDecoration(
            color: Color(0x99000000),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: Colors.white,
            size: size,
          ),
        ),
      ),
    );
  }
}
