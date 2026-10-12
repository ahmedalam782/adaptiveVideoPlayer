import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../normal_video_player/utils/fullscreen_utils_export.dart';

/// Service managing native OS Picture-in-Picture mode on Android, iOS, Windows, and macOS.
class NativePipService {
  NativePipService._();

  static const MethodChannel _channel =
      MethodChannel('adaptive_video_player/pip');

  /// Emits `true` when the app is currently in native OS Picture-in-Picture mode.
  static final ValueNotifier<bool> isInPip = ValueNotifier<bool>(false);

  /// Emits remote OS PiP action events (e.g. 'toggle_play', 'play', 'pause').
  static final ValueNotifier<String?> pipAction = ValueNotifier<String?>(null);

  /// Emits the playback position in milliseconds when returning/restoring from native PiP.
  static final ValueNotifier<int?> restoredPositionMs =
      ValueNotifier<int?>(null);

  /// Emits how a native PiP session ended.
  ///
  /// [PipSessionEnd.dismissed] is true when the viewer closed the PiP window.
  /// Playback should stay paused in that case, and also when it was already
  /// paused inside PiP.
  static final ValueNotifier<PipSessionEnd?> pipSessionEnd =
      ValueNotifier<PipSessionEnd?>(null);

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
        } else if (call.method == 'onPipPositionRestored') {
          final pos = call.arguments as int?;
          if (pos != null) {
            restoredPositionMs.value = pos;
          }
        } else if (call.method == 'onPipSessionEnded') {
          final args = call.arguments;
          if (args is Map) {
            pipSessionEnd.value = PipSessionEnd(
              positionMs: (args['positionMs'] as num?)?.toInt() ?? -1,
              isPlaying: args['isPlaying'] as bool? ?? false,
              dismissed: args['dismissed'] as bool? ?? true,
            );
          }
        }
      });
    }
  }

  /// Informs the native OS PiP service of current playback state (e.g. playing vs paused)
  /// so it can update native PiP control buttons (like Play / Pause).
  static Future<void> updatePlaybackState({
    required bool isPlaying,
    String? url,
    int? positionMs,
  }) async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await _channel.invokeMethod('updatePlaybackState', {
        'isPlaying': isPlaying,
        if (url != null) 'url': url,
        if (positionMs != null) 'positionMs': positionMs,
      });
    } catch (_) {}
  }

  /// Prepares or tears down the native PiP player.
  ///
  /// Leaving the app does not open PiP. Call [enterPip] for an explicit start.
  static Future<void> setPipEnabled(bool enabled, {String? url}) async {
    if (kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    try {
      await _channel.invokeMethod('setPipEnabled', {
        'enabled': enabled,
        if (url != null) 'url': url,
      });
    } catch (_) {}
  }

  /// Leaves the system PiP window and brings the app back to the screen.
  static Future<void> exitPip() async {
    if (kIsWeb) return;
    if (Platform.isWindows || Platform.isMacOS) {
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
    if (Platform.isWindows || Platform.isMacOS) {
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
  static Future<bool> enterPip({
    String? url,
    int? positionMs,
    bool? isPlaying,
  }) async {
    if (kIsWeb) return false;
    if (Platform.isWindows || Platform.isMacOS) {
      final success = enterDesktopPipMode();
      if (success) {
        isInPip.value = true;
      }
      return success;
    }
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      final res = await _channel.invokeMethod<bool>('enterPip', {
        if (url != null) 'url': url,
        if (positionMs != null) 'positionMs': positionMs,
        if (isPlaying != null) 'isPlaying': isPlaying,
      });
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Checks if native OS Picture-in-Picture is supported on this device.
  static Future<bool> isSupported() async {
    if (kIsWeb) return false;
    if (Platform.isWindows || Platform.isMacOS) return true;
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    try {
      final res = await _channel.invokeMethod<bool>('isPipSupported');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }
}

/// How a native Picture-in-Picture session finished.
class PipSessionEnd {
  const PipSessionEnd({
    required this.positionMs,
    required this.isPlaying,
    required this.dismissed,
  });

  /// Playback position inside the PiP player, in milliseconds.
  /// Negative when the platform has no separate position to restore.
  final int positionMs;

  /// Whether the PiP player was playing when the session ended.
  final bool isPlaying;

  /// True when the viewer closed the PiP window.
  /// False when they returned the video to the app.
  final bool dismissed;
}
