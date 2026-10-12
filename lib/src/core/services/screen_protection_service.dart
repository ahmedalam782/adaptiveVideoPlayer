import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../normal_video_player/utils/fullscreen_utils_export.dart';

/// Service managing screen capture and screen recording prevention across all platforms.
///
/// When active:
/// - **Android**: Engages `WindowManager.LayoutParams.FLAG_SECURE`, causing screenshots
///   and screen recordings to be completely black.
/// - **iOS**: Activates secure layer container tricks to blank out screen captures.
/// - **Windows**: Calls native Win32 `SetWindowDisplayAffinity(WDA_MONITOR)` via FFI,
///   rendering the window as black in screenshots, Snipping Tool, and OBS captures.
/// - **macOS**: Communicates via method channel to set secure window sharing.
/// - **Web/Linux**: Safely no-ops without throwing exceptions.
class ScreenProtectionService {
  ScreenProtectionService._();

  static const MethodChannel _channel =
      MethodChannel('adaptive_video_player/security');

  static final Set<Object> _activeOwners = <Object>{};

  /// Notifier reflecting whether screen capture prevention is currently active.
  static final ValueNotifier<bool> isProtectedNotifier =
      ValueNotifier<bool>(false);

  static const Object _defaultOwner = Object();

  static VoidCallback? _screenshotAction;

  /// Whether screen capture is currently prevented.
  static bool get isProtected => isProtectedNotifier.value;

  /// Action to run when a screenshot attempt is detected.
  ///
  /// Pass null when the app should not run an extra action.
  static void setScreenshotAction(VoidCallback? action) {
    _screenshotAction = action;
    if (isProtected) {
      applyDesktopScreenProtection(true, onScreenshot: action);
    }
  }

  /// Registers [owner] as requesting screen capture prevention.
  static Future<void> registerOwner(Object owner) async {
    final wasEmpty = _activeOwners.isEmpty;
    _activeOwners.add(owner);
    if (wasEmpty && _activeOwners.isNotEmpty) {
      await _applyProtection(true);
    }
  }

  /// Unregisters [owner] from requesting screen capture prevention.
  static Future<void> unregisterOwner(Object owner) async {
    final wasNotEmpty = _activeOwners.isNotEmpty;
    _activeOwners.remove(owner);
    if (wasNotEmpty && _activeOwners.isEmpty) {
      await _applyProtection(false);
    }
  }

  /// Explicitly toggles protection for a specific [owner].
  static Future<void> setEnabledFor(Object owner, bool enabled) async {
    if (enabled) {
      await registerOwner(owner);
    } else {
      await unregisterOwner(owner);
    }
  }

  /// Enables screen capture prevention using the default owner.
  static Future<void> enable([Object? owner]) async {
    await registerOwner(owner ?? _defaultOwner);
  }

  /// Disables screen capture prevention for the given [owner] or default owner.
  static Future<void> disable([Object? owner]) async {
    await unregisterOwner(owner ?? _defaultOwner);
  }

  /// Sets protection on or off using the default owner.
  static Future<void> setEnabled(bool enabled) async {
    if (enabled) {
      await enable();
    } else {
      await disable();
    }
  }

  /// Clears all owners and restores normal capture (useful in tests or resets).
  static Future<void> resetAll() async {
    _activeOwners.clear();
    _screenshotAction = null;
    await _applyProtection(false);
  }

  static Future<void> _applyProtection(bool enabled) async {
    isProtectedNotifier.value = enabled;

    // Desktop (Windows via FFI) and Web (DOM & blur shield)
    try {
      applyDesktopScreenProtection(
        enabled,
        onScreenshot: enabled ? _screenshotAction : null,
      );
    } catch (e) {
      log('Platform screen protection error: $e');
    }

    if (kIsWeb) return;

    // Mobile & Desktop MethodChannel (Android, iOS, macOS)
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      try {
        await _channel.invokeMethod('setSecureMode', {'enabled': enabled});
      } catch (_) {
        // Silently ignored if host app has not wired native method channel handler
      }
    }
  }
}
