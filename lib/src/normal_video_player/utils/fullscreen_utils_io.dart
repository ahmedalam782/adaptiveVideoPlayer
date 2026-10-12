import 'dart:developer';
import 'dart:io';

import 'macos_desktop_pip_service.dart';
import 'macos_fullscreen_service.dart';
import 'win32_desktop_pip_service.dart';
import 'win32_fullscreen_service.dart';
import 'win32_window_ffi.dart';

export 'macos_desktop_pip_service.dart';
export 'macos_fullscreen_service.dart' hide FullscreenChangeCallback;
export 'win32_desktop_pip_service.dart';
export 'win32_fullscreen_service.dart';

typedef FullscreenChangeCallback = void Function(bool isFullscreen);

/// Listens to fullscreen change events on desktop.
void listenToFullscreenChange(FullscreenChangeCallback callback) {
  if (Platform.isWindows) {
    Win32FullscreenService.addListener(callback);
  } else if (Platform.isMacOS) {
    MacOSFullscreenService.addListener(callback);
  }
}

/// Enters fullscreen on desktop platforms.
void enterBrowserFullscreen() {
  if (Platform.isWindows) {
    Win32FullscreenService.enterFullscreen();
  } else if (Platform.isMacOS) {
    MacOSFullscreenService.enterFullscreen();
  }
}

/// Exits fullscreen on desktop platforms.
void exitBrowserFullscreen() {
  if (Platform.isWindows) {
    Win32FullscreenService.exitFullscreen();
  } else if (Platform.isMacOS) {
    MacOSFullscreenService.exitFullscreen();
  }
}

/// Clears the desktop fullscreen flag without resizing the window.
void markDesktopFullscreenExited() {
  if (Platform.isMacOS) {
    MacOSFullscreenService.markExited();
  }
}

/// Checks if the window is currently in native fullscreen.
bool isBrowserFullscreen() {
  if (Platform.isWindows) {
    return Win32FullscreenService.isFullscreen;
  } else if (Platform.isMacOS) {
    return MacOSFullscreenService.isFullscreen;
  }
  return false;
}

/// Enters OS-level Picture-in-Picture window on Windows / macOS desktop.
bool enterDesktopPipMode({int width = 380, int height = 214}) {
  if (Platform.isWindows) {
    return Win32DesktopPipService.enterPipMode(width: width, height: height);
  } else if (Platform.isMacOS) {
    return MacOSDesktopPipService.enterPipMode(width: width, height: height);
  }
  return false;
}

/// Moves the desktop PiP window by (deltaX, deltaY).
void moveDesktopPipWindow(int deltaX, int deltaY) {
  if (Platform.isWindows) {
    Win32DesktopPipService.movePipWindow(deltaX, deltaY);
  } else if (Platform.isMacOS) {
    MacOSDesktopPipService.movePipWindow(deltaX, deltaY);
  }
}

/// Exits OS-level Picture-in-Picture window on Windows / macOS desktop.
void exitDesktopPipMode() {
  if (Platform.isWindows) {
    Win32DesktopPipService.exitPipMode();
  } else if (Platform.isMacOS) {
    MacOSDesktopPipService.exitPipMode();
  }
}

/// Checks if the desktop window is currently in PiP mode.
bool isDesktopPipMode() {
  if (Platform.isWindows) {
    return Win32DesktopPipService.isPipMode;
  } else if (Platform.isMacOS) {
    return MacOSDesktopPipService.isPipMode;
  }
  return false;
}

/// Restores the desktop window if it was left in a compact PiP state across Hot Restarts.
void restoreDesktopWindowIfStuckInPip() {
  if (Platform.isWindows) {
    Win32DesktopPipService.restoreIfStuckInPip();
  } else if (Platform.isMacOS) {
    MacOSDesktopPipService.restoreIfStuckInPip();
  }
}

/// Applies or removes native Win32 screen protection (SetWindowDisplayAffinity).
void applyDesktopScreenProtection(bool enabled) {
  if (!Platform.isWindows) return;
  try {
    final user32 = getUser32();
    if (user32 == null) return;
    final hwnd = findFlutterWindow(user32);
    if (hwnd == 0) return;
    final affinity = enabled ? wdaMonitor : wdaNone;
    setDisplayAffinity(user32, hwnd, affinity);
  } catch (e) {
    log('applyDesktopScreenProtection error: $e');
  }
}

