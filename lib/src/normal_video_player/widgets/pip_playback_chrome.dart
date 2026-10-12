import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/player_strings.dart';
import 'pip_circle_button.dart';

/// YouTube-style controls drawn over a picture-in-picture window.
///
/// The video stays clear. Buttons appear while the pointer is over the window.
class PipPlaybackChrome extends StatefulWidget {
  final bool isPlaying;
  final double progress;
  final VoidCallback onClose;
  final VoidCallback onExpand;
  final VoidCallback onPlayPause;
  final VoidCallback? onSeekBackward;
  final VoidCallback? onSeekForward;
  final GestureDragUpdateCallback? onDragUpdate;
  final String closeTooltip;
  final String expandTooltip;
  final String playTooltip;
  final String pauseTooltip;

  const PipPlaybackChrome({
    super.key,
    required this.isPlaying,
    required this.progress,
    required this.onClose,
    required this.onExpand,
    required this.onPlayPause,
    this.onSeekBackward,
    this.onSeekForward,
    this.onDragUpdate,
    this.closeTooltip = PlayerStrings.close,
    this.expandTooltip = PlayerStrings.expand,
    this.playTooltip = PlayerStrings.play,
    this.pauseTooltip = PlayerStrings.pause,
  });

  @override
  State<PipPlaybackChrome> createState() => _PipPlaybackChromeState();
}

class _PipPlaybackChromeState extends State<PipPlaybackChrome> {
  bool _showControls = false;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _show() {
    _hideTimer?.cancel();
    if (!_showControls) setState(() => _showControls = true);
  }

  void _hideSoon() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _show(),
      onExit: (_) {
        _hideTimer?.cancel();
        if (_showControls) setState(() => _showControls = false);
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) {
          _show();
          _hideSoon();
        },
        onPointerMove: widget.onDragUpdate == null
            ? null
            : (event) {
                if (event.buttons == 0) return;
                widget.onDragUpdate!(
                  DragUpdateDetails(
                    globalPosition: event.position,
                    localPosition: event.localPosition,
                    delta: event.delta,
                    sourceTimeStamp: event.timeStamp,
                  ),
                );
              },
        child: Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              ignoring: !_showControls,
              child: AnimatedOpacity(
                opacity: _showControls ? 1 : 0,
                duration: const Duration(milliseconds: 140),
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.28),
                  child: _PipPlaybackButtons(chrome: widget),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 3,
                  child: LinearProgressIndicator(
                    value: widget.progress.clamp(0.0, 1.0),
                    backgroundColor: const Color(0x66FFFFFF),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PipPlaybackButtons extends StatelessWidget {
  final PipPlaybackChrome chrome;

  const _PipPlaybackButtons({required this.chrome});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 150;
        final side = compact ? 32.0 : 40.0;
        final skip = compact ? 40.0 : 52.0;
        final play = compact ? 52.0 : 68.0;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            compact ? 8 : 12,
            compact ? 6 : 10,
            compact ? 8 : 12,
            compact ? 14 : 18,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PipCircleButton(
                    icon: Icons.close_rounded,
                    tooltip: chrome.closeTooltip,
                    onTap: chrome.onClose,
                    size: side,
                    iconSize: compact ? 16 : 20,
                  ),
                  PipCircleButton(
                    icon: Icons.picture_in_picture_alt_rounded,
                    tooltip: chrome.expandTooltip,
                    onTap: chrome.onExpand,
                    size: side,
                    iconSize: compact ? 16 : 18,
                  ),
                ],
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: chrome.onPlayPause,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PipCircleButton(
                        icon: Icons.replay_10_rounded,
                        tooltip: PlayerStrings.back10Seconds,
                        onTap: chrome.onSeekBackward,
                        size: skip,
                        iconSize: compact ? 20 : 26,
                      ),
                      SizedBox(width: compact ? 12 : 22),
                      PipCircleButton(
                        icon: chrome.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        tooltip: chrome.isPlaying
                            ? chrome.pauseTooltip
                            : chrome.playTooltip,
                        onTap: chrome.onPlayPause,
                        size: play,
                        iconSize: compact ? 28 : 36,
                      ),
                      SizedBox(width: compact ? 12 : 22),
                      PipCircleButton(
                        icon: Icons.forward_10_rounded,
                        tooltip: PlayerStrings.forward10Seconds,
                        onTap: chrome.onSeekForward,
                        size: skip,
                        iconSize: compact ? 20 : 26,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
