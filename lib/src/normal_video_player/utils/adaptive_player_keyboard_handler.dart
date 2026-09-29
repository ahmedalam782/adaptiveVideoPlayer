import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'video_player_web_safe.dart';

/// Keyboard shortcut handler for normal adaptive video player.
class AdaptivePlayerKeyboardHandler {
  final VideoPlayerController controller;
  final bool isLive;
  final bool isFullScreen;
  final VoidCallback onTogglePlay;
  final void Function(int direction) onSeek;
  final void Function(double volume) onVolumeChanged;
  final VoidCallback? onEnterFullscreen;
  final VoidCallback? onExitFullscreen;

  const AdaptivePlayerKeyboardHandler({
    required this.controller,
    required this.isLive,
    required this.isFullScreen,
    required this.onTogglePlay,
    required this.onSeek,
    required this.onVolumeChanged,
    this.onEnterFullscreen,
    this.onExitFullscreen,
  });

  KeyEventResult handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.keyK) {
      onTogglePlay();
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.keyJ) {
      if (!isLive) {
        final currentPos = controller.value.position;
        final newPos = currentPos - const Duration(seconds: 10);
        controller.seekTo(newPos.isNegative ? Duration.zero : newPos);
        onSeek(-1);
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.keyL) {
      if (!isLive) {
        final currentPos = controller.value.position;
        final duration = controller.value.duration;
        final newPos = currentPos + const Duration(seconds: 10);
        controller.seekTo(newPos > duration ? duration : newPos);
        onSeek(1);
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      final newVol = (controller.value.volume + 0.1).clamp(0.0, 1.0);
      controller.setVolume(newVol);
      onVolumeChanged(newVol);
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      final newVol = (controller.value.volume - 0.1).clamp(0.0, 1.0);
      controller.setVolume(newVol);
      onVolumeChanged(newVol);
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.keyM) {
      final isMuted = controller.value.volume == 0;
      final newVol = isMuted ? 1.0 : 0.0;
      controller.setVolume(newVol);
      onVolumeChanged(newVol);
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.keyF) {
      if (isFullScreen) {
        onExitFullscreen?.call();
      } else {
        onEnterFullscreen?.call();
      }
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.escape) {
      if (onExitFullscreen != null) {
        onExitFullscreen?.call();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }
}
