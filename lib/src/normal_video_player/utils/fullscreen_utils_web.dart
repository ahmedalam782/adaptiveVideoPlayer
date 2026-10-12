import 'dart:js_interop';
import 'package:web/web.dart' as web;

typedef FullscreenChangeCallback = void Function(bool isFullscreen);

void enterBrowserFullscreen() {
  try {
    web.document.documentElement?.requestFullscreen();
  } catch (_) {}
}

void exitBrowserFullscreen() {
  try {
    if (isBrowserFullscreen()) {
      web.document.exitFullscreen();
    }
  } catch (_) {}
}

void markDesktopFullscreenExited() {}

bool isBrowserFullscreen() {
  try {
    return web.document.fullscreenElement != null;
  } catch (_) {
    return false;
  }
}

void listenToFullscreenChange(FullscreenChangeCallback callback) {
  try {
    web.document.addEventListener(
      'fullscreenchange',
      (web.Event _) {
        callback(isBrowserFullscreen());
      }.toJS,
    );
  } catch (_) {}
}

bool enterDesktopPipMode({int width = 380, int height = 214}) {
  try {
    final video = web.document.querySelector('video') as web.HTMLVideoElement?;
    if (video != null && web.document.pictureInPictureElement == null) {
      video.requestPictureInPicture();
      return true;
    }
  } catch (_) {}
  return false;
}

void moveDesktopPipWindow(int deltaX, int deltaY) {}

void exitDesktopPipMode() {
  try {
    if (web.document.pictureInPictureElement != null) {
      web.document.exitPictureInPicture();
    }
  } catch (_) {}
}

bool isDesktopPipMode() {
  try {
    return web.document.pictureInPictureElement != null;
  } catch (_) {
    return false;
  }
}
void restoreDesktopWindowIfStuckInPip() {}

web.HTMLDivElement? _shieldElement;
web.HTMLStyleElement? _shieldStyle;
JSFunction? _blurCallback;
JSFunction? _focusCallback;
JSFunction? _visibilityCallback;
JSFunction? _keydownCallback;
JSFunction? _keyupCallback;
JSFunction? _contextmenuCallback;
JSFunction? _pointerOutCallback;
JSFunction? _pointerOverCallback;

void _showWebShield() {
  final shield = _shieldElement;
  if (shield == null) return;
  shield.style.display = 'flex';
  shield.style.opacity = '1';
  shield.style.pointerEvents = 'none';
}

void _hideWebShield() {
  final shield = _shieldElement;
  if (shield == null) return;
  shield.style.opacity = '0';
  shield.style.pointerEvents = 'none';
}

void _clearClipboard() {
  for (final delayMs in [0, 40, 100, 200, 400, 800]) {
    Future.delayed(Duration(milliseconds: delayMs), () {
      try {
        web.window.navigator.clipboard.writeText('');
      } catch (_) {}
    });
  }
}

bool _captureChordHeld = false;
void Function()? _onScreenshot;
int _lastScreenshotNoticeMs = 0;

void _paintShieldNow() {
  _showWebShield();
  final shield = _shieldElement;
  if (shield != null) {
    final _ = shield.offsetHeight;
  }
}

void _notifyScreenshot() {
  final action = _onScreenshot;
  if (action == null) return;
  final now = DateTime.now().millisecondsSinceEpoch;
  if (now - _lastScreenshotNoticeMs < 1200) return;
  _lastScreenshotNoticeMs = now;
  try {
    action();
  } catch (_) {}
}

bool _shortcutStartsCapture(web.KeyboardEvent e) {
  final key = e.key.toLowerCase();
  if (key == 'printscreen' || key == 'f12') return true;
  // Command / Windows / Control starts the screenshot before the number key.
  if (key == 'meta' || key == 'os' || key == 'control') return true;
  if (e.metaKey || e.ctrlKey) return true;
  return false;
}

void _handleCaptureKeyDown(web.KeyboardEvent e) {
  if (!_shortcutStartsCapture(e)) return;
  _captureChordHeld = true;
  _paintShieldNow();
  _notifyScreenshot();
  final key = e.key.toLowerCase();
  final finishesCapture = key == 'printscreen' ||
      key == 'f12' ||
      key == '3' ||
      key == '4' ||
      key == '5' ||
      key == 's' ||
      key == 'p';
  if (!finishesCapture) return;
  try {
    e.preventDefault();
    e.stopPropagation();
  } catch (_) {}
  _clearClipboard();
}

void _handleCaptureKeyUp(web.KeyboardEvent e) {
  if (e.metaKey || e.ctrlKey) return;
  _captureChordHeld = false;
  Future.delayed(const Duration(milliseconds: 900), () {
    if (_captureChordHeld) return;
    if (web.document.hasFocus()) _hideWebShield();
  });
}

void _handleWindowBlur(web.Event _) {
  if (web.document.hasFocus()) return;
  _captureChordHeld = true;
  _paintShieldNow();
  _notifyScreenshot();
}

void _handleWindowFocus(web.Event _) {
  if (web.document.hasFocus() == false) return;
  _captureChordHeld = false;
  _hideWebShield();
}

void _handlePointerOut(web.MouseEvent e) {
  if (e.relatedTarget != null) return;
  _paintShieldNow();
}

void _handlePointerOver(web.MouseEvent e) {
  if (_captureChordHeld) return;
  if (web.document.hasFocus()) _hideWebShield();
}

void applyDesktopScreenProtection(
  bool enabled, {
  void Function()? onScreenshot,
}) {
  try {
    _onScreenshot = enabled ? onScreenshot : null;
    final stuck = web.document.getElementById('adaptive-video-screen-shield');
    if (stuck != null && stuck != _shieldElement) {
      stuck.remove();
    }
    if (enabled) {
      if (_shieldElement == null) {
        final shield = web.document.createElement('div') as web.HTMLDivElement;
        shield.id = 'adaptive-video-screen-shield';
        shield.style.position = 'fixed';
        shield.style.left = '0';
        shield.style.top = '0';
        shield.style.width = '100vw';
        shield.style.height = '100vh';
        shield.style.backgroundColor = '#000000';
        shield.style.zIndex = '2147483647';
        shield.style.pointerEvents = 'none';
        shield.style.display = 'flex';
        shield.style.opacity = '0';
        shield.style.transition = 'none';
        shield.style.userSelect = 'none';

        (web.document.body ?? web.document.documentElement)?.appendChild(shield);
        _shieldElement = shield;

        final style =
            web.document.createElement('style') as web.HTMLStyleElement;
        style.id = 'adaptive-video-screen-shield-css';
        style.textContent = '''
@media print {
  html, body, body * { visibility: hidden !important; display: none !important; }
  body { background: #000000 !important; }
}
''';
        web.document.head?.appendChild(style);
        _shieldStyle = style;

        _blurCallback = ((web.Event e) => _handleWindowBlur(e)).toJS;
        _focusCallback = ((web.Event e) => _handleWindowFocus(e)).toJS;
        _keydownCallback = ((web.KeyboardEvent e) => _handleCaptureKeyDown(e)).toJS;
        _keyupCallback = ((web.KeyboardEvent e) => _handleCaptureKeyUp(e)).toJS;
        _contextmenuCallback = ((web.MouseEvent e) {
          try {
            e.preventDefault();
            e.stopPropagation();
          } catch (_) {}
        }).toJS;
        _pointerOutCallback = ((web.MouseEvent e) => _handlePointerOut(e)).toJS;
        _pointerOverCallback =
            ((web.MouseEvent e) => _handlePointerOver(e)).toJS;

        web.window.addEventListener('blur', _blurCallback!);
        web.window.addEventListener('focus', _focusCallback!);
        web.window.addEventListener('keydown', _keydownCallback!, true.toJS);
        web.window.addEventListener('keyup', _keyupCallback!, true.toJS);
        web.window.addEventListener('contextmenu', _contextmenuCallback!);
        web.document.addEventListener('mouseout', _pointerOutCallback!, true.toJS);
        web.document.addEventListener('mouseover', _pointerOverCallback!, true.toJS);
      }
    } else {
      if (_blurCallback != null) {
        web.window.removeEventListener('blur', _blurCallback!);
        _blurCallback = null;
      }
      if (_focusCallback != null) {
        web.window.removeEventListener('focus', _focusCallback!);
        _focusCallback = null;
      }
      if (_visibilityCallback != null) {
        web.document
            .removeEventListener('visibilitychange', _visibilityCallback!);
        _visibilityCallback = null;
      }
      if (_keydownCallback != null) {
        web.window.removeEventListener('keydown', _keydownCallback!, true.toJS);
        _keydownCallback = null;
      }
      if (_keyupCallback != null) {
        web.window.removeEventListener('keyup', _keyupCallback!, true.toJS);
        _keyupCallback = null;
      }
      if (_contextmenuCallback != null) {
        web.window.removeEventListener('contextmenu', _contextmenuCallback!);
        _contextmenuCallback = null;
      }
      if (_pointerOutCallback != null) {
        web.document.removeEventListener('mouseout', _pointerOutCallback!, true.toJS);
        _pointerOutCallback = null;
      }
      if (_pointerOverCallback != null) {
        web.document.removeEventListener('mouseover', _pointerOverCallback!, true.toJS);
        _pointerOverCallback = null;
      }
      _shieldElement?.remove();
      _shieldElement = null;
      _shieldStyle?.remove();
      _shieldStyle = null;
      _captureChordHeld = false;
      _onScreenshot = null;
      _lastScreenshotNoticeMs = 0;
      web.document.getElementById('adaptive-video-screen-shield')?.remove();
      web.document.getElementById('adaptive-video-screen-shield-css')?.remove();
    }
  } catch (_) {}
}

