import 'dart:async';
import 'package:flutter/widgets.dart';

/// Reusable mixin for Widgets managing autohiding video player controls overlays (SRP).
mixin ControlsVisibilityMixin<T extends StatefulWidget> on State<T> {
  bool isControlsVisible = true;
  Timer? _hideControlsTimer;

  Duration _customAutoHideTimeout = const Duration(seconds: 3);

  /// Duration before controls automatically hide - can be read or modified
  Duration get autoHideTimeout => _customAutoHideTimeout;
  set autoHideTimeout(Duration duration) => _customAutoHideTimeout = duration;

  @override
  void initState() {
    super.initState();
    resetHideTimer();
  }

  @override
  void dispose() {
    cancelHideTimer();
    super.dispose();
  }

  /// Show controls and reset the auto-hide timer
  void showControls() {
    if (!isControlsVisible) {
      setState(() {
        isControlsVisible = true;
      });
    }
    resetHideTimer();
  }

  /// Immediately hide controls and cancel any active timer
  void hideControls() {
    cancelHideTimer();
    if (isControlsVisible) {
      setState(() {
        isControlsVisible = false;
      });
    }
  }

  /// Toggle controls visibility
  void toggleControls() {
    if (isControlsVisible) {
      hideControls();
    } else {
      showControls();
    }
  }

  /// Reset the timer for auto-hiding controls
  void resetHideTimer([Duration? customTimeout]) {
    cancelHideTimer();
    if (isControlsVisible) {
      _hideControlsTimer = Timer(customTimeout ?? autoHideTimeout, () {
        if (mounted) {
          setState(() {
            isControlsVisible = false;
          });
        }
      });
    }
  }

  /// Cancel any pending auto-hide timer
  void cancelHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = null;
  }
}
