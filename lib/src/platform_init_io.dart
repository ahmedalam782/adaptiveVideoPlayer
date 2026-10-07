import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';
import 'core/services/native_pip_service.dart';
import 'normal_video_player/utils/fullscreen_utils_export.dart';

/// Initializes platform-specific video player backends on IO platforms (Linux/Windows/macOS/iOS/Android).
class AdaptiveVideoPlayerPlatform {
  AdaptiveVideoPlayerPlatform._();

  static bool _initialized = false;

  /// Ensures that the video player platform backends are initialized.
  ///
  /// On **Linux**, this registers the `media_kit`-based implementation
  /// for the `video_player` plugin.
  ///
  /// On **Windows**, `video_player_win` is used automatically via
  /// Flutter's federated plugin system (no manual initialization needed).
  ///
  /// On **Android**, **iOS**, **macOS**, and **Web**, this is a no-op
  /// since those platforms are natively supported by `video_player`.
  ///
  /// It is safe to call this method multiple times; subsequent calls
  /// will be ignored.
  static void ensureInitialized() {
    if (_initialized) return;
    _initialized = true;

    if (Platform.isWindows) {
      try {
        final kernel32 = DynamicLibrary.open('kernel32.dll');
        final setEnvironmentVariable = kernel32.lookupFunction<
            Int32 Function(Pointer<Utf16>, Pointer<Utf16>),
            int Function(Pointer<Utf16>, Pointer<Utf16>)>(
          'SetEnvironmentVariableW',
        );
        final name = 'WEBVIEW2_ADDITIONAL_BROWSER_ARGUMENTS'.toNativeUtf16();
        final value =
            '--autoplay-policy=no-user-gesture-required'.toNativeUtf16();
        setEnvironmentVariable(name, value);
        calloc.free(name);
        calloc.free(value);
      } catch (_) {}
    }

    restoreDesktopWindowIfStuckInPip();

    WidgetsFlutterBinding.ensureInitialized();
    NativePipService.initialize();

    VideoPlayerMediaKit.ensureInitialized(
      android: false, // Natively supported by video_player
      iOS: false, // Natively supported by video_player
      macOS: false, // Natively supported by video_player
      windows:
          false, // Uses video_player_win (avoids COM conflict with InAppWebView)
      linux: true, // Use media_kit backend
    );
  }
}
