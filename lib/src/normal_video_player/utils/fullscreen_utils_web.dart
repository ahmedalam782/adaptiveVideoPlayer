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

void _showWebShield() {
  if (_shieldElement != null) {
    _shieldElement!.style.display = 'flex';
    _shieldElement!.style.opacity = '1';
    _shieldElement!.style.pointerEvents = 'auto';
  }
}

void _hideWebShield() {
  if (_shieldElement != null) {
    _shieldElement!.style.opacity = '0';
    _shieldElement!.style.display = 'none';
    _shieldElement!.style.pointerEvents = 'none';
  }
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

void _flashWebShield() {
  _showWebShield();
  _clearClipboard();
  Future.delayed(const Duration(milliseconds: 2500), () {
    _hideWebShield();
  });
}

void _handleCaptureKey(web.KeyboardEvent e) {
  final key = e.key;
  final isCaptureKey = key == 'PrintScreen' ||
      (e.ctrlKey && e.shiftKey && key.toLowerCase() == 's') ||
      (e.metaKey && e.shiftKey && key.toLowerCase() == 's') ||
      (e.metaKey &&
          e.shiftKey &&
          (key == '3' || key == '4' || key == '5')) ||
      (e.ctrlKey && key.toLowerCase() == 'p') ||
      (e.metaKey && key.toLowerCase() == 'p') ||
      key == 'F12' ||
      (e.ctrlKey && e.shiftKey && (key.toLowerCase() == 'i' || key.toLowerCase() == 'j' || key.toLowerCase() == 'c'));

  if (isCaptureKey) {
    try {
      e.preventDefault();
      e.stopPropagation();
    } catch (_) {}
    _flashWebShield();
  }
}

void applyDesktopScreenProtection(bool enabled) {
  try {
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
        shield.style.display = 'none';
        shield.style.opacity = '0';
        shield.style.transition = 'none';
        shield.style.alignItems = 'center';
        shield.style.justifyContent = 'center';
        shield.style.userSelect = 'none';
        shield.innerHTML = '''
<div style="display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;padding:28px 36px;background:rgba(20,20,20,0.96);border-radius:18px;box-shadow:0 12px 40px rgba(0,0,0,0.9);max-width:440px;border:1px solid #2e2e2e;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;">
  <div style="width:68px;height:68px;border-radius:50%;background:rgba(239,68,68,0.18);display:flex;align-items:center;justify-content:center;margin-bottom:18px;">
    <svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="#ef4444" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
      <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
      <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
    </svg>
  </div>
  <div style="font-size:22px;font-weight:700;color:#ffffff;margin-bottom:10px;">Protected Content</div>
  <div style="font-size:14px;color:#a1a1aa;line-height:1.6;">Screen capture, recording, and printing are disabled to protect media rights.</div>
</div>
'''.toJS;

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

        _blurCallback = ((web.Event _) => _showWebShield()).toJS;
        _focusCallback = ((web.Event _) => _hideWebShield()).toJS;
        _visibilityCallback = ((web.Event _) {
          if (web.document.visibilityState == 'hidden') {
            _showWebShield();
          } else {
            _hideWebShield();
          }
        }).toJS;

        _keydownCallback = ((web.KeyboardEvent e) => _handleCaptureKey(e)).toJS;
        _keyupCallback = ((web.KeyboardEvent e) => _handleCaptureKey(e)).toJS;
        _contextmenuCallback = ((web.MouseEvent e) {
          try {
            e.preventDefault();
            e.stopPropagation();
          } catch (_) {}
        }).toJS;

        web.window.addEventListener('blur', _blurCallback!);
        web.window.addEventListener('focus', _focusCallback!);
        web.document.addEventListener('visibilitychange', _visibilityCallback!);
        web.window.addEventListener('keydown', _keydownCallback!);
        web.window.addEventListener('keyup', _keyupCallback!);
        web.window.addEventListener('contextmenu', _contextmenuCallback!);
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
        web.window.removeEventListener('keydown', _keydownCallback!);
        _keydownCallback = null;
      }
      if (_keyupCallback != null) {
        web.window.removeEventListener('keyup', _keyupCallback!);
        _keyupCallback = null;
      }
      if (_contextmenuCallback != null) {
        web.window.removeEventListener('contextmenu', _contextmenuCallback!);
        _contextmenuCallback = null;
      }
      _shieldElement?.remove();
      _shieldElement = null;
      _shieldStyle?.remove();
      _shieldStyle = null;
    }
  } catch (_) {}
}

