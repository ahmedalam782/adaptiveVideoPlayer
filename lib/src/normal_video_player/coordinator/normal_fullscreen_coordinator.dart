import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/fullscreen_utils_export.dart';
import '../utils/player_surface_tier.dart';

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
  }) {
    enterSystemFullscreen(context: context);
    if (_fullscreenOverlay != null) return;

    final window = MediaQuery.maybeSizeOf(context) ?? Size.zero;
    final player = context.size ?? window;
    final tier = PlayerSurfaceScope.maybeOf(context) ??
        resolvePlayerSurfaceTier(window: window, player: player);

    _fullscreenOverlay = OverlayEntry(
      builder: (context) {
        return PlayerSurfaceScope(
          tier: tier,
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              closeFullscreen();
            },
            child: ListenableBuilder(
              listenable: this,
              builder: (context, _) => builder(context),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_fullscreenOverlay!);
  }

  /// Native fullscreen and orientation, without a second video overlay.
  void enterSystemFullscreen({required BuildContext context}) async {
    if (_isInFullscreen) return;

    _isInFullscreen = true;
    _onFullscreenChanged?.call();

    enterBrowserFullscreen();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    final isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (isMobile) {
      // One landscape direction. Listing both makes iOS rotate, then rotate again.
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  /// Drop the fullscreen surface without a second native window resize.
  ///
  /// Picture-in-Picture owns the window change. Restoring the old frame here
  /// and then shrinking it in the same turn freezes macOS.
  void abandonFullscreenForPip() {
    if (!_isInFullscreen) return;
    _fullscreenOverlay?.remove();
    _fullscreenOverlay?.dispose();
    _fullscreenOverlay = null;
    _isInFullscreen = false;
    _onFullscreenChanged?.call();
  }

  /// Close fullscreen overlay and restore normal orientations
  void closeFullscreen() async {
    if (!_isInFullscreen) return;

    _fullscreenOverlay?.remove();
    _fullscreenOverlay?.dispose();
    _fullscreenOverlay = null;

    _isInFullscreen = false;
    _onFullscreenChanged?.call();

    exitBrowserFullscreen();

    final isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (isMobile) {
      // One restore. A portrait lock followed by every orientation turns the phone twice.
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
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
