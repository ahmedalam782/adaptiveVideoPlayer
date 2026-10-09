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
  /// On **Windows**, passing [windowsUseMediaKit] (defaults to `true`) registers
  /// the `media_kit` backend (libmpv), which prevents Windows Media Foundation
  /// buffering stutter and log loops on network/HLS streams. Set to `false`
  /// if you wish to fall back to `video_player_win`.
  ///
  /// On **Android**, **iOS**, **macOS**, and **Web**, this is a no-op
  /// since those platforms are natively supported by `video_player`.
  ///
  /// It is safe to call this method multiple times; subsequent calls
  /// will be ignored.
  static void ensureInitialized({bool windowsUseMediaKit = true}) {
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

        // Set dedicated user data folder in LocalAppData/Temp to prevent locks on Hot Restart
        // and avoid write permission issues in application directory.
        final localAppData = Platform.environment['LOCALAPPDATA'] ??
            Platform.environment['TEMP'] ??
            Directory.systemTemp.path;
        final userDataDir = '$localAppData\\AdaptiveVideoPlayer_WebView2';
        try {
          Directory(userDataDir).createSync(recursive: true);
        } catch (_) {}
        final uName = 'WEBVIEW2_USER_DATA_FOLDER'.toNativeUtf16();
        final uValue = userDataDir.toNativeUtf16();
        setEnvironmentVariable(uName, uValue);
        calloc.free(uName);
        calloc.free(uValue);
      } catch (_) {}
    }

    restoreDesktopWindowIfStuckInPip();

    WidgetsFlutterBinding.ensureInitialized();
    NativePipService.initialize();

    VideoPlayerMediaKit.ensureInitialized(
      android: false, // Natively supported by video_player
      iOS: false, // Natively supported by video_player
      macOS: false, // Natively supported by video_player
      windows: windowsUseMediaKit, // Uses media_kit (libmpv) to prevent WMF buffering loops
      linux: true, // Use media_kit backend
    );
  }
}
