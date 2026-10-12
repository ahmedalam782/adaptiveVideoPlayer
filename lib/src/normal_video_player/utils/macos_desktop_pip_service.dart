import 'dart:developer';
import 'dart:io';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../core/services/native_pip_service.dart';
import 'macos_fullscreen_service.dart';

/// Dedicated manager for macOS desktop OS-level Picture-in-Picture window transitions.
class MacOSDesktopPipService {
  MacOSDesktopPipService._();

  static const MethodChannel _channel =
      MethodChannel('adaptive_video_player/window');
  static bool _isMacOSPip = false;

  /// Whether the macOS desktop window is currently in PiP mode.
  static bool get isPipMode => Platform.isMacOS && _isMacOSPip;

  static void _updatePipState(bool inPip) {
    _isMacOSPip = inPip;
    try {
      if (WidgetsBinding.instance.schedulerPhase == SchedulerPhase.idle) {
        NativePipService.isInPip.value = inPip;
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          NativePipService.isInPip.value = inPip;
        });
      }
    } catch (_) {
      NativePipService.isInPip.value = inPip;
    }
  }

  /// Called when macOS informs Dart of a PiP mode transition.
  static void handlePipChanged(bool inPip) {
    _updatePipState(inPip);
  }

  /// Enter OS-level always-on-top Picture-in-Picture window on macOS desktop.
  static bool enterPipMode({int width = 380, int height = 214}) {
    if (!Platform.isMacOS) return false;
    MacOSFullscreenService.initialize();
    if (_isMacOSPip) return true;
    _updatePipState(true);
    try {
      _channel.invokeMethod('enterPip', {
        'width': width.toDouble(),
        'height': height.toDouble(),
      });
      return true;
    } catch (e) {
      log('Error entering macOS PiP: $e');
      _updatePipState(false);
      return false;
    }
  }

  /// Exits macOS desktop OS-level Picture-in-Picture mode.
  static void exitPipMode() {
    if (!Platform.isMacOS) return;
    MacOSFullscreenService.initialize();
    if (!_isMacOSPip) return;
    _updatePipState(false);
    try {
      _channel.invokeMethod('exitPip');
    } catch (e) {
      log('Error exiting macOS PiP: $e');
    }
  }

  /// Moves the macOS desktop PiP window by (deltaX, deltaY).
  static void movePipWindow(int deltaX, int deltaY) {
    if (!Platform.isMacOS || !_isMacOSPip) return;
    try {
      _channel.invokeMethod('movePipWindow', {
        'deltaX': deltaX.toDouble(),
        'deltaY': deltaY.toDouble(),
      });
    } catch (e) {
      log('Error moving macOS PiP window: $e');
    }
  }

  /// Restores the desktop window if it was left in a compact PiP state across Hot Restarts.
  static void restoreIfStuckInPip() {
    if (!Platform.isMacOS) return;
    MacOSFullscreenService.initialize();
    try {
      _channel.invokeMethod('restoreIfStuckInPip');
    } catch (_) {}
  }
}
