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
