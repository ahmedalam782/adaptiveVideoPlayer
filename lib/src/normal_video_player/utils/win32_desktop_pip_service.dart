import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import '../../core/services/native_pip_service.dart';
import 'win32_fullscreen_service.dart';
import 'win32_window_ffi.dart';

class Win32DesktopPipService {
  static bool _isWindowsPip = false;
  static int _pipSavedStyle = 0;
  static Pointer<WINDOWPLACEMENT>? _pipSavedPlacement;
  static int _pipSavedLeft = 100;
  static int _pipSavedTop = 100;
  static int _pipSavedWidth = 1280;
  static int _pipSavedHeight = 720;
  static int _pipHwnd = 0;
  static int _pipWindowX = 0;
  static int _pipWindowY = 0;
  static int _pipWindowWidth = 380;
  static int _pipWindowHeight = 214;

  static bool get isPipMode => Platform.isWindows && _isWindowsPip;

  /// Restores the desktop window if it was left in a compact PiP state across a Hot Restart.
  static void restoreIfStuckInPip() {
    if (!Platform.isWindows || _isWindowsPip || Win32FullscreenService.isFullscreen) {
      return;
    }
    try {
      final user32 = getUser32();
      if (user32 == null) return;
      final hwnd = findFlutterWindow(user32);
      if (hwnd == 0) return;

      final getWindowRect = user32.lookupFunction<
          Int32 Function(IntPtr, Pointer<RECT>),
          int Function(int, Pointer<RECT>)>('GetWindowRect');
      final rectPtr = calloc<RECT>();
      getWindowRect(hwnd, rectPtr);
      final w = rectPtr.ref.right - rectPtr.ref.left;
      final h = rectPtr.ref.bottom - rectPtr.ref.top;
      calloc.free(rectPtr);

      if (w > 0 && w <= 440 && h > 0 && h <= 280) {
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
        final workLeft = miPtr.ref.rcWork.left;
        final workTop = miPtr.ref.rcWork.top;
        final workW = miPtr.ref.rcWork.right - workLeft;
        final workH = miPtr.ref.rcWork.bottom - workTop;
        calloc.free(miPtr);

        final restoredW = 1280 < workW ? 1280 : (workW * 0.85).round();
        final restoredH = 720 < workH ? 720 : (workH * 0.85).round();
        final restoredX = workLeft + ((workW - restoredW) ~/ 2);
        final restoredY = workTop + ((workH - restoredH) ~/ 2);

        final style = getWindowLong(user32, hwnd, gwlStyle);
        final normalStyle =
            ((style & ~wsPopup) | wsOverlappedWindow | wsVisible).toSigned(32);
        NativePipService.isInPip.value = false;

        runWhenSchedulerIdle(() {
          try {
            setWindowLong(user32, hwnd, gwlStyle, normalStyle);

            final setWindowPos = user32.lookupFunction<
                Int32 Function(
                    IntPtr, IntPtr, Int32, Int32, Int32, Int32, Uint32),
                int Function(int, int, int, int, int, int, int)>('SetWindowPos');
            setWindowPos(
              hwnd,
              hwndNoTopMost,
              restoredX,
              restoredY,
              restoredW,
              restoredH,
              swpNoOwnerZOrder | swpFrameChanged,
            );
          } catch (_) {}
        });
      }
    } catch (_) {}
  }

  /// Enter OS-level always-on-top Picture-in-Picture window on Windows desktop
  static bool enterPipMode({int width = 380, int height = 214}) {
    if (!Platform.isWindows) return false;
    if (_isWindowsPip) return true;

    if (Win32FullscreenService.isFullscreen) {
      Win32FullscreenService.exitFullscreen();
    }

    try {
      final user32 = getUser32();
      if (user32 == null) return false;

      final hwnd = findFlutterWindow(user32);
      if (hwnd == 0) return false;

      restoreIfStuckInPip();

      _pipHwnd = hwnd;
      _pipSavedStyle = getWindowLong(user32, hwnd, gwlStyle);

      final getWindowRect = user32.lookupFunction<
          Int32 Function(IntPtr, Pointer<RECT>),
          int Function(int, Pointer<RECT>)>('GetWindowRect');
      final rectPtr = calloc<RECT>();
      getWindowRect(hwnd, rectPtr);
      final curW = rectPtr.ref.right - rectPtr.ref.left;
      final curH = rectPtr.ref.bottom - rectPtr.ref.top;
      if (curW > 440 && curH > 280) {
        _pipSavedLeft = rectPtr.ref.left;
        _pipSavedTop = rectPtr.ref.top;
        _pipSavedWidth = curW;
        _pipSavedHeight = curH;
      }
      calloc.free(rectPtr);

      if (_pipSavedPlacement != null) {
        calloc.free(_pipSavedPlacement!);
      }
      _pipSavedPlacement = calloc<WINDOWPLACEMENT>();
      _pipSavedPlacement!.ref.length = sizeOf<WINDOWPLACEMENT>();

      final getWindowPlacement = user32.lookupFunction<
          Int32 Function(IntPtr, Pointer<WINDOWPLACEMENT>),
          int Function(int, Pointer<WINDOWPLACEMENT>)>('GetWindowPlacement');
      getWindowPlacement(hwnd, _pipSavedPlacement!);

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

      final workRight = miPtr.ref.rcWork.right;
      final workBottom = miPtr.ref.rcWork.bottom;
      calloc.free(miPtr);

      _pipWindowWidth = width;
      _pipWindowHeight = height;
      _pipWindowX = workRight - width - 24;
      _pipWindowY = workBottom - height - 24;

      _isWindowsPip = true;
      NativePipService.isInPip.value = true;

      runWhenSchedulerIdle(() {
        if (!_isWindowsPip) return;
        try {
          final borderlessPipStyle =
              ((_pipSavedStyle & ~wsOverlappedWindow) | wsPopup | wsVisible)
                  .toSigned(32);
          setWindowLong(user32, hwnd, gwlStyle, borderlessPipStyle);

          final setWindowPos = user32.lookupFunction<
              Int32 Function(
                  IntPtr, IntPtr, Int32, Int32, Int32, Int32, Uint32),
              int Function(int, int, int, int, int, int, int)>('SetWindowPos');

          setWindowPos(
            hwnd,
            hwndTopMost,
            _pipWindowX,
            _pipWindowY,
            _pipWindowWidth,
            _pipWindowHeight,
            swpNoOwnerZOrder | swpFrameChanged,
          );

          log('Entered Windows always-on-top Picture-in-Picture mode');
        } catch (e) {
          _isWindowsPip = false;
          log('Error applying Windows PiP window: $e');
        }
      });

      return true;
    } catch (e) {
      _isWindowsPip = false;
      log('Error entering Windows PiP mode: $e');
      return false;
    }
  }

  /// Move the Windows OS-level PiP window by (deltaX, deltaY)
  static void movePipWindow(int deltaX, int deltaY) {
    if (!Platform.isWindows || !_isWindowsPip || _pipHwnd == 0) return;
    try {
      final user32 = getUser32();
      if (user32 == null) return;

      _pipWindowX += deltaX;
      _pipWindowY += deltaY;

      final setWindowPos = user32.lookupFunction<
          Int32 Function(IntPtr, IntPtr, Int32, Int32, Int32, Int32, Uint32),
          int Function(int, int, int, int, int, int, int)>('SetWindowPos');

      setWindowPos(
        _pipHwnd,
        hwndTopMost,
        _pipWindowX,
        _pipWindowY,
        _pipWindowWidth,
        _pipWindowHeight,
        swpNoSize | swpNoOwnerZOrder,
      );
    } catch (_) {}
  }

  /// Exit OS-level Picture-in-Picture window on Windows desktop
  static void exitPipMode() {
    if (!Platform.isWindows) return;
    if (!_isWindowsPip || _pipHwnd == 0) {
      restoreIfStuckInPip();
      return;
    }

    try {
      final user32 = getUser32();
      if (user32 == null) return;

      final hwnd = _pipHwnd;
      final savedStyle = _pipSavedStyle;
      final savedLeft = _pipSavedLeft;
      final savedTop = _pipSavedTop;
      final savedWidth = _pipSavedWidth;
      final savedHeight = _pipSavedHeight;
      final savedPlacement = _pipSavedPlacement;
      _pipSavedPlacement = null;
      _isWindowsPip = false;
      NativePipService.isInPip.value = false;
      _pipHwnd = 0;

      runWhenSchedulerIdle(() {
        try {
          if (savedPlacement != null) {
            final setWindowPlacement = user32.lookupFunction<
                Int32 Function(IntPtr, Pointer<WINDOWPLACEMENT>),
                int Function(
                    int, Pointer<WINDOWPLACEMENT>)>('SetWindowPlacement');
            setWindowPlacement(hwnd, savedPlacement);
            calloc.free(savedPlacement);
          }

          if (savedStyle != 0) {
            setWindowLong(user32, hwnd, gwlStyle, savedStyle);
          }

          final setWindowPos = user32.lookupFunction<
              Int32 Function(
                  IntPtr, IntPtr, Int32, Int32, Int32, Int32, Uint32),
              int Function(int, int, int, int, int, int, int)>('SetWindowPos');

          setWindowPos(
            hwnd,
            hwndNoTopMost,
            savedLeft,
            savedTop,
            savedWidth,
            savedHeight,
            swpNoOwnerZOrder | swpFrameChanged,
          );

          log('Exited Windows Picture-in-Picture mode');
        } catch (e) {
          log('Error exiting Windows PiP window: $e');
        }
      });
    } catch (e) {
      log('Error exiting Windows PiP window: $e');
    }
  }
}
