import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../normal_video_player/utils/fullscreen_utils_export.dart';
import '../contracts/i_fullscreen_service.dart';

/// Concrete fullscreen service encapsulating platform orientation, system overlays,
/// and web browser fullscreen API (SRP).
class PlatformFullscreenService implements IFullscreenService {
  bool _isFullscreen = false;
  final VoidCallback? _onEnter;
  final VoidCallback? _onExit;

  PlatformFullscreenService({
    VoidCallback? onEnterFullscreen,
    VoidCallback? onExitFullscreen,
  })  : _onEnter = onEnterFullscreen,
        _onExit = onExitFullscreen {
    listenToFullscreenChange(_handleBrowserFullscreenChange);
  }

  void _handleBrowserFullscreenChange(bool isFs) {
    if (isFs != _isFullscreen) {
      _isFullscreen = isFs;
      if (isFs) {
        _onEnter?.call();
      } else {
        _onExit?.call();
      }
    }
  }

  @override
  bool get isFullscreen => _isFullscreen || isBrowserFullscreen();

  @override
  Future<void> enterFullscreen({BuildContext? context}) async {
    _isFullscreen = true;
    enterBrowserFullscreen();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _onEnter?.call();
  }

  @override
  Future<void> exitFullscreen({BuildContext? context}) async {
    _isFullscreen = false;
    exitBrowserFullscreen();
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _onExit?.call();
  }

  @override
  Future<void> toggleFullscreen({BuildContext? context}) async {
    if (isFullscreen) {
      await exitFullscreen(context: context);
    } else {
      await enterFullscreen(context: context);
    }
  }

  @override
  void dispose() {
    // Reset system chrome safely if disposed while in fullscreen
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }
}
