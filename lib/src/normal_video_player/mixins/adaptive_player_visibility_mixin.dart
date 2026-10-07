import 'dart:async';
import 'package:flutter/material.dart';

import '../adaptive_controls.dart';

/// Mixin handling controls auto-hiding timer and visibility state for [BaseAdaptiveVideoPlayer].
mixin AdaptivePlayerVisibilityMixin on State<BaseAdaptiveVideoPlayer> {
  bool controlsVisible = true;
  Timer? hideTimer;

  void startHideTimer() {
    hideTimer?.cancel();
    final timeout = widget.visibility?.controlsHideTimeout ??
        const Duration(seconds: 3);
    hideTimer = Timer(timeout, () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => controlsVisible = false);
      }
    });
  }

  void toggleControls() {
    setState(() {
      controlsVisible = !controlsVisible;
      if (controlsVisible) {
        startHideTimer();
      } else {
        hideTimer?.cancel();
      }
    });
  }

  void disposeVisibilityTimer() {
    hideTimer?.cancel();
  }
}
