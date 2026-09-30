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

bool enterDesktopPipMode({int width = 380, int height = 214}) {
  // On Web, the in-app draggable MiniPlayer overlay (NormalMiniPlayerOverlay /
  // YouTube miniplayer) renders the live video inside the page's root Overlay.
  // Calling native `videoEl.requestPictureInPicture()` would cause the browser
  // to replace the in-DOM `<video>` element with a black placeholder.
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

bool isDesktopPipMode() => false;
void restoreDesktopWindowIfStuckInPip() {}

