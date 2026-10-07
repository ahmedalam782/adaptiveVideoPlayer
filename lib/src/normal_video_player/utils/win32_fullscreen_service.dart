import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'win32_window_ffi.dart';

typedef FullscreenChangeCallback = void Function(bool isFullscreen);

class Win32FullscreenService {
  static final List<FullscreenChangeCallback> _listeners = [];
  static bool _isWindowsFullscreen = false;
  static int _savedStyle = 0;
  static Pointer<WINDOWPLACEMENT>? _savedPlacement;
  static int _fullscreenHwnd = 0;

  static bool get isFullscreen => Platform.isWindows && _isWindowsFullscreen;

  static void addListener(FullscreenChangeCallback callback) {
    _listeners.add(callback);
  }

  static void notifyListeners(bool isFs) {
    for (final l in List<FullscreenChangeCallback>.from(_listeners)) {
      try {
        l(isFs);
      } catch (_) {}
    }
  }

  /// Enter borderless fullscreen on Windows desktop (hiding title bar & taskbar)
  static void enterFullscreen() {
    if (!Platform.isWindows || _isWindowsFullscreen) return;

    try {
      final user32 = getUser32();
      if (user32 == null) return;

      final hwnd = findFlutterWindow(user32);
      if (hwnd == 0) return;

      _fullscreenHwnd = hwnd;

      // 1. Save style
      _savedStyle = getWindowLong(user32, hwnd, gwlStyle);

      // 2. Save placement
      if (_savedPlacement != null) {
        calloc.free(_savedPlacement!);
      }
      _savedPlacement = calloc<WINDOWPLACEMENT>();
      _savedPlacement!.ref.length = sizeOf<WINDOWPLACEMENT>();

      final getWindowPlacement = user32.lookupFunction<
          Int32 Function(IntPtr, Pointer<WINDOWPLACEMENT>),
          int Function(int, Pointer<WINDOWPLACEMENT>)>('GetWindowPlacement');
      getWindowPlacement(hwnd, _savedPlacement!);

      // 3. Get monitor rect
      final monitorFromWindow = user32.lookupFunction<
          IntPtr Function(IntPtr, Uint32),
          int Function(int, int)>('MonitorFromWindow');
      final hMonitor = monitorFromWindow(hwnd, monitorDefaultToPrimary);

      final getMonitorInfo = user32.lookupFunction<
          Int32 Function(IntPtr, Pointer<MONITORINFO>),
          int Function(int, Pointer<MONITORINFO>)>('GetMonitorInfoW');

      final miPtr = calloc<MONITORINFO>();
      miPtr.ref.cbSize = sizeOf<MONITORINFO>();
      getMonitorInfo(hMonitor, miPtr);

      final left = miPtr.ref.rcMonitor.left;
      final top = miPtr.ref.rcMonitor.top;
      final width = miPtr.ref.rcMonitor.right - miPtr.ref.rcMonitor.left;
      final height = miPtr.ref.rcMonitor.bottom - miPtr.ref.rcMonitor.top;
      calloc.free(miPtr);

      _isWindowsFullscreen = true;
      notifyListeners(true);

      runWhenSchedulerIdle(() {
        if (!_isWindowsFullscreen) return;
        try {
          // 4. Set style to borderless (removes title bar and window frame)
          setWindowLong(
              user32, hwnd, gwlStyle, _savedStyle & ~wsOverlappedWindow);

          // 5. Expand window across monitor (covers taskbar)
          final setWindowPos = user32.lookupFunction<
              Int32 Function(
                  IntPtr, IntPtr, Int32, Int32, Int32, Int32, Uint32),
              int Function(int, int, int, int, int, int, int)>('SetWindowPos');

          setWindowPos(
            hwnd,
            hwndTop,
            left,
            top,
            width,
            height,
            swpNoOwnerZOrder | swpFrameChanged,
          );

          log('Entered native Windows fullscreen (borderless over taskbar)');
        } catch (e) {
          log('Error entering Windows fullscreen: $e');
        }
      });
    } catch (e) {
      log('Error entering Windows fullscreen: $e');
    }
  }

  /// Exit borderless fullscreen on Windows desktop (restoring title bar & taskbar)
  static void exitFullscreen() {
    if (!Platform.isWindows) return;
    if (!_isWindowsFullscreen || _fullscreenHwnd == 0) return;

    try {
      final user32 = getUser32();
      if (user32 == null) return;

      final hwnd = _fullscreenHwnd;
      final savedStyle = _savedStyle;
      final savedPlacement = _savedPlacement;
      _savedPlacement = null;
      _isWindowsFullscreen = false;
      _fullscreenHwnd = 0;
      notifyListeners(false);

      runWhenSchedulerIdle(() {
        try {
          // 1. Restore style
          if (savedStyle != 0) {
            setWindowLong(user32, hwnd, gwlStyle, savedStyle);
          }

          // 2. Restore placement
          if (savedPlacement != null) {
            final setWindowPlacement = user32.lookupFunction<
                Int32 Function(IntPtr, Pointer<WINDOWPLACEMENT>),
                int Function(
                    int, Pointer<WINDOWPLACEMENT>)>('SetWindowPlacement');
            setWindowPlacement(hwnd, savedPlacement);
            calloc.free(savedPlacement);
          }

          // 3. Trigger frame changed so borders, title bar, and taskbar return
          final setWindowPos = user32.lookupFunction<
              Int32 Function(
                  IntPtr, IntPtr, Int32, Int32, Int32, Int32, Uint32),
              int Function(int, int, int, int, int, int, int)>('SetWindowPos');

          setWindowPos(
            hwnd,
            0,
            0,
            0,
            0,
            0,
            swpNoMove |
                swpNoSize |
                swpNoZOrder |
                swpNoOwnerZOrder |
                swpFrameChanged,
          );

          log('Exited native Windows fullscreen (restored window frame & taskbar)');
        } catch (e) {
          log('Error exiting Windows fullscreen: $e');
        }
      });
    } catch (e) {
      log('Error exiting Windows fullscreen: $e');
    }
  }
}
