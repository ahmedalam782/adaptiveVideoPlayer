import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef FullscreenChangeCallback = void Function(bool isFullscreen);

final List<FullscreenChangeCallback> _listeners = [];

void listenToFullscreenChange(FullscreenChangeCallback callback) {
  _listeners.add(callback);
}

void _notifyListeners(bool isFs) {
  for (final l in List<FullscreenChangeCallback>.from(_listeners)) {
    try {
      l(isFs);
    } catch (_) {}
  }
}

bool _isWindowsFullscreen = false;
int _savedStyle = 0;
Pointer<WINDOWPLACEMENT>? _savedPlacement;
int _fullscreenHwnd = 0;

bool _isWindowsPip = false;
int _pipSavedStyle = 0;
Pointer<WINDOWPLACEMENT>? _pipSavedPlacement;
int _pipSavedLeft = 100;
int _pipSavedTop = 100;
int _pipSavedWidth = 1280;
int _pipSavedHeight = 720;
int _pipHwnd = 0;
int _pipWindowX = 0;
int _pipWindowY = 0;
int _pipWindowWidth = 380;
int _pipWindowHeight = 214;

final class RECT extends Struct {
  @Int32()
  external int left;
  @Int32()
  external int top;
  @Int32()
  external int right;
  @Int32()
  external int bottom;
}

final class POINT extends Struct {
  @Int32()
  external int x;
  @Int32()
  external int y;
}

final class WINDOWPLACEMENT extends Struct {
  @Uint32()
  external int length;
  @Uint32()
  external int flags;
  @Uint32()
  external int showCmd;
  external POINT ptMinPosition;
  external POINT ptMaxPosition;
  external RECT rcNormalPosition;
}

final class MONITORINFO extends Struct {
  @Uint32()
  external int cbSize;
  external RECT rcMonitor;
  external RECT rcWork;
  @Uint32()
  external int dwFlags;
}

const int _gwlStyle = -16;
const int _wsOverlappedWindow = 0x00CF0000;
const int _wsPopup = 0x80000000;
const int _wsVisible = 0x10000000;
const int _swpNoOwnerZOrder = 0x0200;
const int _swpFrameChanged = 0x0020;
const int _swpNoMove = 0x0002;
const int _swpNoSize = 0x0001;
const int _swpNoZOrder = 0x0004;
const int _hwndTop = 0;
const int _hwndTopMost = -1;
const int _hwndNoTopMost = -2;
const int _monitorDefaultToPrimary = 1;
const int _gaRoot = 2;

DynamicLibrary? _user32;

DynamicLibrary? _getUser32() {
  if (!Platform.isWindows) return null;
  _user32 ??= DynamicLibrary.open('user32.dll');
  return _user32;
}

int _cachedFlutterHwnd = 0;

int _findFlutterWindow(DynamicLibrary user32) {
  if (_cachedFlutterHwnd != 0) {
    try {
      final isWindow = user32
          .lookupFunction<Int32 Function(IntPtr), int Function(int)>('IsWindow');
      if (isWindow(_cachedFlutterHwnd) != 0) {
        return _cachedFlutterHwnd;
      }
    } catch (_) {}
    _cachedFlutterHwnd = 0;
  }

  // 1. Look for top-level FLUTTER_RUNNER_WIN32_WINDOW belonging to current process
  try {
    final kernel32 = DynamicLibrary.open('kernel32.dll');
    final getCurrentProcessId = kernel32
        .lookupFunction<Uint32 Function(), int Function()>('GetCurrentProcessId');
    final myPid = getCurrentProcessId();

    final findWindowEx = user32.lookupFunction<
        IntPtr Function(IntPtr, IntPtr, Pointer<Utf16>, Pointer<Utf16>),
        int Function(int, int, Pointer<Utf16>, Pointer<Utf16>)>('FindWindowExW');
    final getWindowThreadProcessId = user32.lookupFunction<
        Uint32 Function(IntPtr, Pointer<Uint32>),
        int Function(int, Pointer<Uint32>)>('GetWindowThreadProcessId');

    final classNamePtr = 'FLUTTER_RUNNER_WIN32_WINDOW'.toNativeUtf16();
    final pidPtr = calloc<Uint32>();

    int current = 0;
    while (true) {
      current = findWindowEx(0, current, classNamePtr, nullptr);
      if (current == 0) break;
      getWindowThreadProcessId(current, pidPtr);
      if (pidPtr.value == myPid) {
        _cachedFlutterHwnd = current;
        break;
      }
    }

    calloc.free(pidPtr);
    calloc.free(classNamePtr);

    if (_cachedFlutterHwnd != 0) {
      return _cachedFlutterHwnd;
    }
  } catch (e) {
    log('Error searching for FLUTTER_RUNNER_WIN32_WINDOW: $e');
  }

  // Fallback to active/foreground window if class search didn't match
  final getActiveWindow = user32
      .lookupFunction<IntPtr Function(), int Function()>('GetActiveWindow');
  final getForegroundWindow = user32.lookupFunction<IntPtr Function(),
      int Function()>('GetForegroundWindow');
  final getAncestor = user32.lookupFunction<
      IntPtr Function(IntPtr, Uint32),
      int Function(int, int)>('GetAncestor');

  int hwnd = getActiveWindow();
  if (hwnd != 0) {
    final root = getAncestor(hwnd, _gaRoot);
    if (root != 0) return root;
    return hwnd;
  }
  hwnd = getForegroundWindow();
  if (hwnd != 0) {
    final root = getAncestor(hwnd, _gaRoot);
    if (root != 0) return root;
    return hwnd;
  }
  return 0;
}

int _getWindowLong(DynamicLibrary user32, int hwnd, int index) {
  try {
    final fn = user32.lookupFunction<
        IntPtr Function(IntPtr, Int32),
        int Function(int, int)>('GetWindowLongPtrW');
    return fn(hwnd, index);
  } catch (_) {
    final fn = user32.lookupFunction<
        Int32 Function(IntPtr, Int32),
        int Function(int, int)>('GetWindowLongW');
    return fn(hwnd, index);
  }
}

int _setWindowLong(DynamicLibrary user32, int hwnd, int index, int value) {
  try {
    final fn = user32.lookupFunction<
        IntPtr Function(IntPtr, Int32, IntPtr),
        int Function(int, int, int)>('SetWindowLongPtrW');
    return fn(hwnd, index, value);
  } catch (_) {
    final fn = user32.lookupFunction<
        Int32 Function(IntPtr, Int32, Int32),
        int Function(int, int, int)>('SetWindowLongW');
    return fn(hwnd, index, value);
  }
}

/// Restores the desktop window if it was left in a compact PiP state across a Hot Restart.
void restoreDesktopWindowIfStuckInPip() {
  if (!Platform.isWindows || _isWindowsPip || _isWindowsFullscreen) return;
  try {
    final user32 = _getUser32();
    if (user32 == null) return;
    final hwnd = _findFlutterWindow(user32);
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
      final hMonitor = monitorFromWindow(hwnd, _monitorDefaultToPrimary);
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

      final style = _getWindowLong(user32, hwnd, _gwlStyle);
      final normalStyle =
          ((style & ~_wsPopup) | _wsOverlappedWindow | _wsVisible).toSigned(32);
      _setWindowLong(user32, hwnd, _gwlStyle, normalStyle);

      final setWindowPos = user32.lookupFunction<
          Int32 Function(IntPtr, IntPtr, Int32, Int32, Int32, Int32, Uint32),
          int Function(int, int, int, int, int, int, int)>('SetWindowPos');
      setWindowPos(
        hwnd,
        _hwndNoTopMost,
        restoredX,
        restoredY,
        restoredW,
        restoredH,
        _swpNoOwnerZOrder | _swpFrameChanged,
      );
    }
  } catch (_) {}
}

/// Enter borderless fullscreen on Windows desktop (hiding title bar & taskbar)
void enterBrowserFullscreen() {
  if (!Platform.isWindows) return;
  if (_isWindowsFullscreen) return;

  try {
    final user32 = _getUser32();
    if (user32 == null) return;

    final hwnd = _findFlutterWindow(user32);
    if (hwnd == 0) return;

    _fullscreenHwnd = hwnd;

    // 1. Save style
    _savedStyle = _getWindowLong(user32, hwnd, _gwlStyle);

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
    final hMonitor = monitorFromWindow(hwnd, _monitorDefaultToPrimary);

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

    // 4. Set style to borderless (removes title bar and window frame)
    _setWindowLong(user32, hwnd, _gwlStyle, _savedStyle & ~_wsOverlappedWindow);

    // 5. Expand window across monitor (covers taskbar)
    final setWindowPos = user32.lookupFunction<
        Int32 Function(IntPtr, IntPtr, Int32, Int32, Int32, Int32, Uint32),
        int Function(int, int, int, int, int, int, int)>('SetWindowPos');

    setWindowPos(
      hwnd,
      _hwndTop,
      left,
      top,
      width,
      height,
      _swpNoOwnerZOrder | _swpFrameChanged,
    );

    _isWindowsFullscreen = true;
    _notifyListeners(true);
    log('Entered native Windows fullscreen (borderless over taskbar)');
  } catch (e) {
    log('Error entering Windows fullscreen: $e');
  }
}

/// Exit borderless fullscreen on Windows desktop (restoring title bar & taskbar)
void exitBrowserFullscreen() {
  if (!Platform.isWindows) return;
  if (!_isWindowsFullscreen || _fullscreenHwnd == 0) return;

  try {
    final user32 = _getUser32();
    if (user32 == null) return;

    final hwnd = _fullscreenHwnd;

    // 1. Restore style
    if (_savedStyle != 0) {
      _setWindowLong(user32, hwnd, _gwlStyle, _savedStyle);
    }

    // 2. Restore placement
    if (_savedPlacement != null) {
      final setWindowPlacement = user32.lookupFunction<
          Int32 Function(IntPtr, Pointer<WINDOWPLACEMENT>),
          int Function(int, Pointer<WINDOWPLACEMENT>)>('SetWindowPlacement');
      setWindowPlacement(hwnd, _savedPlacement!);
      calloc.free(_savedPlacement!);
      _savedPlacement = null;
    }

    // 3. Trigger frame changed so borders, title bar, and taskbar return
    final setWindowPos = user32.lookupFunction<
        Int32 Function(IntPtr, IntPtr, Int32, Int32, Int32, Int32, Uint32),
        int Function(int, int, int, int, int, int, int)>('SetWindowPos');

    setWindowPos(
      hwnd,
      0,
      0,
      0,
      0,
      0,
      _swpNoMove |
          _swpNoSize |
          _swpNoZOrder |
          _swpNoOwnerZOrder |
          _swpFrameChanged,
    );

    _isWindowsFullscreen = false;
    _fullscreenHwnd = 0;
    _notifyListeners(false);
    log('Exited native Windows fullscreen (restored window frame & taskbar)');
  } catch (e) {
    log('Error exiting Windows fullscreen: $e');
  }
}

bool isBrowserFullscreen() {
  if (Platform.isWindows) {
    return _isWindowsFullscreen;
  }
  return false;
}

/// Enter OS-level always-on-top Picture-in-Picture window on Windows desktop
bool enterDesktopPipMode({int width = 380, int height = 214}) {
  if (!Platform.isWindows) return false;
  if (_isWindowsPip) return true;

  if (_isWindowsFullscreen) {
    exitBrowserFullscreen();
  }

  try {
    final user32 = _getUser32();
    if (user32 == null) return false;

    final hwnd = _findFlutterWindow(user32);
    if (hwnd == 0) return false;

    // Ensure window isn't saving an already-shrunk PiP rect from before a Hot Restart
    restoreDesktopWindowIfStuckInPip();

    _pipHwnd = hwnd;
    _pipSavedStyle = _getWindowLong(user32, hwnd, _gwlStyle);

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
    final hMonitor = monitorFromWindow(hwnd, _monitorDefaultToPrimary);

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

    // Set _isWindowsPip BEFORE SetWindowPos so any synchronous WM_SIZE layout sees isDesktopPipMode() == true
    _isWindowsPip = true;

    // Use WS_POPUP | WS_VISIBLE to completely remove the Windows 11 title bar and frame on small PiP windows
    final borderlessPipStyle =
        ((_pipSavedStyle & ~_wsOverlappedWindow) | _wsPopup | _wsVisible)
            .toSigned(32);
    _setWindowLong(user32, hwnd, _gwlStyle, borderlessPipStyle);

    final setWindowPos = user32.lookupFunction<
        Int32 Function(IntPtr, IntPtr, Int32, Int32, Int32, Int32, Uint32),
        int Function(int, int, int, int, int, int, int)>('SetWindowPos');

    setWindowPos(
      hwnd,
      _hwndTopMost,
      _pipWindowX,
      _pipWindowY,
      _pipWindowWidth,
      _pipWindowHeight,
      _swpNoOwnerZOrder | _swpFrameChanged,
    );

    log('Entered Windows always-on-top Picture-in-Picture mode');
    return true;
  } catch (e) {
    _isWindowsPip = false;
    log('Error entering Windows PiP mode: $e');
    return false;
  }
}

/// Move the Windows OS-level PiP window by (deltaX, deltaY)
void moveDesktopPipWindow(int deltaX, int deltaY) {
  if (!Platform.isWindows || !_isWindowsPip || _pipHwnd == 0) return;
  try {
    final user32 = _getUser32();
    if (user32 == null) return;

    _pipWindowX += deltaX;
    _pipWindowY += deltaY;

    final setWindowPos = user32.lookupFunction<
        Int32 Function(IntPtr, IntPtr, Int32, Int32, Int32, Int32, Uint32),
        int Function(int, int, int, int, int, int, int)>('SetWindowPos');

    setWindowPos(
      _pipHwnd,
      _hwndTopMost,
      _pipWindowX,
      _pipWindowY,
      _pipWindowWidth,
      _pipWindowHeight,
      _swpNoSize | _swpNoOwnerZOrder,
    );
  } catch (_) {}
}

/// Exit OS-level Picture-in-Picture window on Windows desktop
void exitDesktopPipMode() {
  if (!Platform.isWindows) return;
  if (!_isWindowsPip || _pipHwnd == 0) {
    restoreDesktopWindowIfStuckInPip();
    return;
  }

  try {
    final user32 = _getUser32();
    if (user32 == null) return;

    final hwnd = _pipHwnd;
    _isWindowsPip = false;
    _pipHwnd = 0;

    final restoredStyle =
        ((_pipSavedStyle & ~_wsPopup) | _wsOverlappedWindow | _wsVisible)
            .toSigned(32);
    _setWindowLong(user32, hwnd, _gwlStyle, restoredStyle);

    final setWindowPos = user32.lookupFunction<
        Int32 Function(IntPtr, IntPtr, Int32, Int32, Int32, Int32, Uint32),
        int Function(int, int, int, int, int, int, int)>('SetWindowPos');

    setWindowPos(
      hwnd,
      _hwndNoTopMost,
      _pipSavedLeft,
      _pipSavedTop,
      _pipSavedWidth,
      _pipSavedHeight,
      _swpNoOwnerZOrder | _swpFrameChanged,
    );

    if (_pipSavedPlacement != null) {
      if (_pipSavedPlacement!.ref.showCmd == 3) {
        // Restore maximized state if it was maximized before PiP
        final setWindowPlacement = user32.lookupFunction<
            Int32 Function(IntPtr, Pointer<WINDOWPLACEMENT>),
            int Function(int, Pointer<WINDOWPLACEMENT>)>('SetWindowPlacement');
        setWindowPlacement(hwnd, _pipSavedPlacement!);
      }
      calloc.free(_pipSavedPlacement!);
      _pipSavedPlacement = null;
    }

    restoreDesktopWindowIfStuckInPip();
    log('Exited Windows Picture-in-Picture mode');
  } catch (e) {
    log('Error exiting Windows PiP mode: $e');
  }
}

bool isDesktopPipMode() {
  if (Platform.isWindows) {
    return _isWindowsPip;
  }
  return false;
}
