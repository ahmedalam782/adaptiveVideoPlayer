import 'package:flutter/material.dart';

import '../coordinator/normal_fullscreen_coordinator.dart';
import '../normal_video_player.dart';

/// Mixin handling fullscreen management and overlay coordination for [NormalVideoPlayer].
mixin NormalPlayerFullscreenMixin on State<NormalVideoPlayer> {
  final NormalFullscreenCoordinator fullscreenCoordinator =
      NormalFullscreenCoordinator();

  bool get isInFullscreen => fullscreenCoordinator.isInFullscreen;

  void initFullscreenCoordinator({VoidCallback? onFullscreenChanged}) {
    fullscreenCoordinator.initialize(
      onFullscreenChanged: () {
        if (mounted) {
          setState(() {});
          onFullscreenChanged?.call();
        }
      },
    );
  }

  void disposeFullscreenCoordinator() {
    fullscreenCoordinator.dispose();
  }

  void rebuildFullscreenOverlayIfNeeded() {
    if (fullscreenCoordinator.isInFullscreen) {
      fullscreenCoordinator.rebuildOverlay();
    }
  }

  void openFullscreenView({
    required Widget Function(BuildContext overlayContext) builder,
    VoidCallback? onBeforeOpen,
    VoidCallback? onAfterOpen,
  }) {
    onBeforeOpen?.call();
    fullscreenCoordinator.openFullscreen(
      context: context,
      builder: builder,
    );
    onAfterOpen?.call();
  }

  void closeFullscreenView({
    VoidCallback? onBeforeClose,
    VoidCallback? onAfterClose,
  }) {
    onBeforeClose?.call();
    fullscreenCoordinator.closeFullscreen();
    onAfterClose?.call();
  }
}
