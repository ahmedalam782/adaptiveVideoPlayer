import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/fullscreen_utils_export.dart';

/// Coordinates fullscreen transitions, overlays, system UI modes, and device orientations for normal video player.
class NormalFullscreenCoordinator extends ChangeNotifier {
  OverlayEntry? _fullscreenOverlay;
  bool _isInFullscreen = false;
  VoidCallback? _onFullscreenChanged;

  /// Whether the player is currently in fullscreen mode
  bool get isInFullscreen => _isInFullscreen;

  /// Trigger a rebuild of the active fullscreen overlay
  void rebuildOverlay() {
    if (_isInFullscreen && _fullscreenOverlay != null) {
      notifyListeners();
    }
  }

  /// Initialize listener for browser fullscreen changes
  void initialize({required VoidCallback onFullscreenChanged}) {
    _onFullscreenChanged = onFullscreenChanged;
    listenToFullscreenChange((isFullscreen) {
      if (!isFullscreen && _isInFullscreen) {
        closeFullscreen();
      }
    });
  }

  /// Open fullscreen overlay and lock orientation
  void openFullscreen({
    required BuildContext context,
    required Widget Function(BuildContext context) builder,
  }) async {
    if (_isInFullscreen) return;

    _fullscreenOverlay = OverlayEntry(
      builder: (context) {
        return ListenableBuilder(
          listenable: this,
          builder: (context, _) => builder(context),
        );
      },
    );
    _isInFullscreen = true;
    _onFullscreenChanged?.call();

    Overlay.of(context).insert(_fullscreenOverlay!);
    enterBrowserFullscreen();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Close fullscreen overlay and restore normal orientations
  void closeFullscreen() async {
    if (!_isInFullscreen || _fullscreenOverlay == null) return;

    _fullscreenOverlay?.remove();
    _fullscreenOverlay?.dispose();
    _fullscreenOverlay = null;

    _isInFullscreen = false;
    _onFullscreenChanged?.call();

    exitBrowserFullscreen();

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  /// Disposes active overlay on widget dispose
  @override
  void dispose() {
    if (_isInFullscreen && _fullscreenOverlay != null) {
      _fullscreenOverlay?.remove();
      _fullscreenOverlay?.dispose();
      _fullscreenOverlay = null;
      _isInFullscreen = false;
    }
    super.dispose();
  }
}
