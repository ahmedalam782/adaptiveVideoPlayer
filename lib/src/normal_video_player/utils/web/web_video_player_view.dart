import 'package:flutter/material.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart'
    as platform_interface;

import '../video_player_web_safe_web.dart';

/// A web-safe widget to render the video player on Web.
class VideoPlayer extends StatefulWidget {
  /// Creates a [VideoPlayer] widget.
  const VideoPlayer(this.controller, {super.key});

  /// The controller driving this player widget.
  final VideoPlayerController controller;

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late int _playerId;

  void _controllerDidUpdateValue() {
    final int newPlayerId = widget.controller.playerId;
    if (newPlayerId != _playerId) {
      setState(() {
        _playerId = newPlayerId;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _playerId = widget.controller.playerId;
    if (!widget.controller.isDisposed) {
      try {
        widget.controller.addListener(_controllerDidUpdateValue);
      } catch (_) {}
    }
  }

  @override
  void didUpdateWidget(VideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.controller.isDisposed) {
      try {
        oldWidget.controller.removeListener(_controllerDidUpdateValue);
      } catch (_) {}
    }
    _playerId = widget.controller.playerId;
    if (!widget.controller.isDisposed) {
      try {
        widget.controller.addListener(_controllerDidUpdateValue);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    if (!widget.controller.isDisposed) {
      try {
        widget.controller.removeListener(_controllerDidUpdateValue);
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_playerId == -1) return Container();
    final rotation = widget.controller.value.rotationCorrection;
    final view =
        platform_interface.VideoPlayerPlatform.instance.buildViewWithOptions(
      platform_interface.VideoViewOptions(playerId: _playerId),
    );
    if (rotation == 0) return view;
    return RotatedBox(
      quarterTurns: (rotation / 90).round(),
      child: view,
    );
  }
}
