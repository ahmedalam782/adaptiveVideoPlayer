import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/scheduler.dart';

// Win32 FFI Structs
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

// Win32 Constants
const int gwlStyle = -16;
const int wsOverlappedWindow = 0x00CF0000;
const int wsPopup = 0x80000000;
const int wsVisible = 0x10000000;
const int swpNoOwnerZOrder = 0x0200;
const int swpFrameChanged = 0x0020;
const int swpNoMove = 0x0002;
const int swpNoSize = 0x0001;
const int swpNoZOrder = 0x0004;
const int hwndTop = 0;
const int hwndTopMost = -1;
const int hwndNoTopMost = -2;
const int monitorDefaultToPrimary = 1;
const int gaRoot = 2;

DynamicLibrary? _user32;

DynamicLibrary? getUser32() {
  if (!Platform.isWindows) return null;
  _user32 ??= DynamicLibrary.open('user32.dll');
  return _user32;
}

int _cachedFlutterHwnd = 0;

int findFlutterWindow(DynamicLibrary user32) {
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
    final root = getAncestor(hwnd, gaRoot);
    if (root != 0) return root;
    return hwnd;
  }
  hwnd = getForegroundWindow();
  if (hwnd != 0) {
    final root = getAncestor(hwnd, gaRoot);
    if (root != 0) return root;
    return hwnd;
  }
  return 0;
}

int getWindowLong(DynamicLibrary user32, int hwnd, int index) {
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

int setWindowLong(DynamicLibrary user32, int hwnd, int index, int value) {
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

void runWhenSchedulerIdle(void Function() action) {
  try {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      action();
    } else {
      Timer.run(() => runWhenSchedulerIdle(action));
    }
  } catch (_) {
    action();
  }
}
