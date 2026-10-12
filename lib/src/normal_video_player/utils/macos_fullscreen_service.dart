import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';

import 'macos_desktop_pip_service.dart';

typedef FullscreenChangeCallback = void Function(bool isFullscreen);

/// Dedicated manager for macOS desktop native fullscreen transitions.
class MacOSFullscreenService {
  MacOSFullscreenService._();

  static const MethodChannel _channel =
      MethodChannel('adaptive_video_player/window');
  static final List<FullscreenChangeCallback> _listeners = [];
  static bool _isFullscreen = false;
  static bool _initialized = false;

  /// Whether the macOS window is currently in fullscreen.
  static bool get isFullscreen => Platform.isMacOS && _isFullscreen;

  /// Initializes the MethodChannel handler to receive window state notifications from macOS.
  static void initialize() {
    if (_initialized || !Platform.isMacOS) return;
    _initialized = true;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onFullscreenChanged') {
        final isFs = call.arguments as bool? ?? false;
        _isFullscreen = isFs;
        notifyListeners(isFs);
      } else if (call.method == 'onPipModeChanged') {
        final inPip = call.arguments as bool? ?? false;
        MacOSDesktopPipService.handlePipChanged(inPip);
      }
    });
  }

  /// Adds a listener for fullscreen changes.
  static void addListener(FullscreenChangeCallback callback) {
    initialize();
    _listeners.add(callback);
  }

  /// Removes a listener for fullscreen changes.
  static void removeListener(FullscreenChangeCallback callback) {
    _listeners.remove(callback);
  }

  /// Notifies all registered listeners of a fullscreen change.
  static void notifyListeners(bool isFs) {
    for (final l in List<FullscreenChangeCallback>.from(_listeners)) {
      try {
        l(isFs);
      } catch (e) {
        log('Error in MacOSFullscreenService listener: $e');
      }
    }
  }

  /// Enters native macOS fullscreen.
  static Future<void> enterFullscreen() async {
    if (!Platform.isMacOS) return;
    initialize();
    _isFullscreen = true;
    notifyListeners(true);
    try {
      await _channel.invokeMethod('enterFullscreen');
    } catch (e) {
      log('Error entering macOS fullscreen: $e');
      _isFullscreen = false;
      notifyListeners(false);
    }
  }

  /// Clears the fullscreen flag without asking macOS to resize the window.
  static void markExited() {
    if (!_isFullscreen) return;
    _isFullscreen = false;
    notifyListeners(false);
  }

  /// Exits native macOS fullscreen.
  static Future<void> exitFullscreen() async {
    if (!Platform.isMacOS) return;
    initialize();
    if (!_isFullscreen) return;
    _isFullscreen = false;
    notifyListeners(false);
    try {
      await _channel.invokeMethod('exitFullscreen');
    } catch (e) {
      log('Error exiting macOS fullscreen: $e');
    }
  }
}
