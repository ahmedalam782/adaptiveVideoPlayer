import 'dart:async';
import 'package:flutter/material.dart';

import '../../youtube_player/models/player_text_config.dart';
import '../adaptive_controls.dart';

/// Mixin handling user gestures (Double-tap seek feedback, Hold-to-2x speed, Volume HUD)
/// for [BaseAdaptiveVideoPlayer].
mixin AdaptivePlayerGesturesMixin on State<BaseAdaptiveVideoPlayer> {
  // Seek feedback state
  int seekDirection = 0; // -1 for backward, 1 for forward, 0 for none
  int seekSeconds = 10;
  Timer? seekResetTimer;

  // Volume feedback state
  double? feedbackVolume;
  Timer? volumeFeedbackTimer;

  // Hold-to-2x speed state
  bool isHold2xActive = false;
  double previousPlaybackSpeed = 1.0;

  void triggerSeekFeedback(int direction, VoidCallback onRestartHideTimer) {
    if (!mounted) return;
    seekResetTimer?.cancel();
    final skipSec = widget.visibility?.skipDuration.inSeconds ?? 10;
    setState(() {
      if (seekDirection == direction) {
        seekSeconds += skipSec;
      } else {
        seekDirection = direction;
        seekSeconds = skipSec;
      }
    });
    onRestartHideTimer();
    seekResetTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          seekDirection = 0;
          seekSeconds = widget.visibility?.skipDuration.inSeconds ?? 10;
        });
      }
    });
  }

  void showVolumeFeedback(double volume) {
    if (!(widget.visibility?.showVolumeFeedback ?? true)) return;
    volumeFeedbackTimer?.cancel();
    setState(() {
      feedbackVolume = volume;
    });
    final timeout = widget.visibility?.volumeFeedbackTimeout ??
        const Duration(milliseconds: 1200);
    volumeFeedbackTimer = Timer(timeout, () {
      if (mounted) setState(() => feedbackVolume = null);
    });
  }

  void handleDoubleTap(
      TapDownDetails details, VoidCallback onRestartHideTimer) {
    if (widget.isLive) return;

    final width = MediaQuery.of(context).size.width;
    final position = details.globalPosition.dx;
    final currentPosition = widget.controller.value.position;
    final wasPlaying = widget.controller.value.isPlaying;
    final duration = widget.controller.value.duration;
    final isRtl = (widget.messages ?? const PlayerTextConfig())
            .resolveTextDirection(context) ==
        TextDirection.rtl;
    final tappedRightHalf = position > width / 2;
    final isForward = isRtl ? !tappedRightHalf : tappedRightHalf;
    final skipDuration =
        widget.visibility?.skipDuration ?? const Duration(seconds: 10);

    if (isForward) {
      triggerSeekFeedback(1, onRestartHideTimer);
      final newPosition = currentPosition + skipDuration;
      widget.controller
          .seekTo(newPosition > duration ? duration : newPosition);
    } else {
      triggerSeekFeedback(-1, onRestartHideTimer);
      final newPosition = currentPosition - skipDuration;
      widget.controller
          .seekTo(newPosition.isNegative ? Duration.zero : newPosition);
    }

    if (wasPlaying) {
      widget.controller.play();
    }
  }

  void handleLongPressStart(LongPressStartDetails details) {
    if (widget.isLive) return;
    previousPlaybackSpeed = widget.controller.value.playbackSpeed;
    setState(() => isHold2xActive = true);
    widget.controller.setPlaybackSpeed(2.0);
    widget.onAnalyticsEvent?.call('playback_speed_hold_start', {'speed': 2.0});
  }

  void handleLongPressEnd(LongPressEndDetails details) {
    stopHold2xSpeed();
  }

  void stopHold2xSpeed() {
    if (!isHold2xActive) return;
    setState(() => isHold2xActive = false);
    widget.controller.setPlaybackSpeed(previousPlaybackSpeed);
    widget.onAnalyticsEvent
        ?.call('playback_speed_hold_end', {'speed': previousPlaybackSpeed});
  }

  void disposeGesturesTimers() {
    seekResetTimer?.cancel();
    volumeFeedbackTimer?.cancel();
  }
}
