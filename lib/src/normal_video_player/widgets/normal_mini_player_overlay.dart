  import 'package:flutter/material.dart';
import '../../youtube_player/models/youtube_player_config.dart';
import '../utils/fullscreen_utils_export.dart';
import '../utils/video_player_web_safe.dart';
import 'normal_mini_player_content.dart';

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
  final bool _controlsVisible = true;

  void _onDragDelta(Offset delta, bool isOsPipWindow) {
    if (isOsPipWindow) {
      moveDesktopPipWindow(
        delta.dx.round(),
        delta.dy.round(),
      );
    } else {
      setState(() {
        _offset += delta;
      });
    }
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
            child: NormalMiniPlayerContent(
              controller: widget.controller,
              isOsPipWindow: true,
              messages: widget.messages,
              controlsVisible: _controlsVisible,
              onClose: widget.onClose,
              onExpand: widget.onExpand,
              onSeekBy: _seekBy,
              onDragDelta: (delta) => _onDragDelta(delta, true),
            ),
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
            child: NormalMiniPlayerContent(
              controller: widget.controller,
              isOsPipWindow: false,
              messages: widget.messages,
              controlsVisible: _controlsVisible,
              onClose: widget.onClose,
              onExpand: widget.onExpand,
              onSeekBy: _seekBy,
              onDragDelta: (delta) => _onDragDelta(delta, false),
            ),
          ),
        ],
      ),
    );
  }
}
