import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../normal_video_player/utils/fullscreen_utils_export.dart';

/// Service managing native OS Picture-in-Picture mode on Android, iOS, and Windows.
class NativePipService {
  NativePipService._();

  static const MethodChannel _channel =
      MethodChannel('adaptive_video_player/pip');

  /// Emits `true` when the app is currently in native OS Picture-in-Picture mode.
  static final ValueNotifier<bool> isInPip = ValueNotifier<bool>(false);

  /// Emits remote OS PiP action events (e.g. 'toggle_play', 'play', 'pause').
  static final ValueNotifier<String?> pipAction = ValueNotifier<String?>(null);

  static bool _initialized = false;

  /// Initializes the method channel callback listener.
  static void initialize() {
    if (_initialized) return;
    _initialized = true;

    if (kIsWeb) return;
    if (Platform.isAndroid || Platform.isIOS) {
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onPipModeChanged') {
          final inPip = call.arguments as bool? ?? false;
          isInPip.value = inPip;
        } else if (call.method == 'onPipAction') {
          final action = call.arguments as String?;
          pipAction.value = null;
          pipAction.value = action;
        }
      });
    }
  }

  /// Informs the native OS PiP service of current playback state (e.g. playing vs paused)
  /// so it can update native PiP control buttons (like Play / Pause).
  static Future<void> updatePlaybackState({required bool isPlaying}) async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await _channel.invokeMethod('updatePlaybackState', {'isPlaying': isPlaying});
    } catch (_) {}
  }

  /// Enables or disables automatic PiP when leaving the app (e.g. on Android home gesture).
  static Future<void> setPipEnabled(bool enabled) async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await _channel.invokeMethod('setPipEnabled', enabled);
    } catch (_) {}
  }

  /// Leaves the system PiP window and brings the app back to the screen.
  static Future<void> exitPip() async {
    if (kIsWeb) return;
    if (Platform.isWindows) {
      exitDesktopPipMode();
      isInPip.value = false;
      return;
    }
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await _channel.invokeMethod('exitPip');
    } catch (_) {}
  }

  /// Dismisses the system PiP window.
  static Future<void> closePip() async {
    if (kIsWeb) return;
    if (Platform.isWindows) {
      exitDesktopPipMode();
      isInPip.value = false;
      return;
    }
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await _channel.invokeMethod('closePip');
    } catch (_) {}
  }

  /// Requests the operating system to immediately enter Picture-in-Picture mode.
  static Future<bool> enterPip() async {
    if (kIsWeb) return false;
    if (Platform.isWindows) {
      final success = enterDesktopPipMode();
      if (success) {
        isInPip.value = true;
      }
      return success;
    }
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      final res = await _channel.invokeMethod<bool>('enterPip');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Checks if native OS Picture-in-Picture is supported on this device.
  static Future<bool> isSupported() async {
    if (kIsWeb) return false;
    if (Platform.isWindows) return true;
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      final res = await _channel.invokeMethod<bool>('isPipSupported');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }
}
