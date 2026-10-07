import 'win32_desktop_pip_service.dart';
import 'win32_fullscreen_service.dart';

export 'win32_desktop_pip_service.dart';
export 'win32_fullscreen_service.dart';

typedef FullscreenChangeCallback = void Function(bool isFullscreen);

/// Listens to fullscreen change events on native Windows desktop.
void listenToFullscreenChange(FullscreenChangeCallback callback) =>
    Win32FullscreenService.addListener(callback);

/// Enters borderless fullscreen on native Windows desktop.
void enterBrowserFullscreen() => Win32FullscreenService.enterFullscreen();

/// Exits borderless fullscreen on native Windows desktop.
void exitBrowserFullscreen() => Win32FullscreenService.exitFullscreen();

/// Checks if the window is currently in native fullscreen.
bool isBrowserFullscreen() => Win32FullscreenService.isFullscreen;

/// Enters OS-level Picture-in-Picture window on Windows desktop.
bool enterDesktopPipMode({int width = 380, int height = 214}) =>
    Win32DesktopPipService.enterPipMode(width: width, height: height);

/// Moves the desktop PiP window by (deltaX, deltaY).
void moveDesktopPipWindow(int deltaX, int deltaY) =>
    Win32DesktopPipService.movePipWindow(deltaX, deltaY);

/// Exits OS-level Picture-in-Picture window on Windows desktop.
void exitDesktopPipMode() => Win32DesktopPipService.exitPipMode();

/// Checks if the desktop window is currently in PiP mode.
bool isDesktopPipMode() => Win32DesktopPipService.isPipMode;

/// Restores the desktop window if it was left in a compact PiP state across Hot Restarts.
void restoreDesktopWindowIfStuckInPip() =>
    Win32DesktopPipService.restoreIfStuckInPip();
