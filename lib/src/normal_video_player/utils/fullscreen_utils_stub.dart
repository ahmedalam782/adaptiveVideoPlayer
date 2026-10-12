typedef FullscreenChangeCallback = void Function(bool isFullscreen);

void enterBrowserFullscreen() {}
void exitBrowserFullscreen() {}
void markDesktopFullscreenExited() {}
bool isBrowserFullscreen() => false;
void listenToFullscreenChange(FullscreenChangeCallback callback) {}
bool enterDesktopPipMode({int width = 380, int height = 214}) => false;
void moveDesktopPipWindow(int deltaX, int deltaY) {}
void exitDesktopPipMode() {}
bool isDesktopPipMode() => false;
void restoreDesktopWindowIfStuckInPip() {}
void applyDesktopScreenProtection(
  bool enabled, {
  void Function()? onScreenshot,
}) {}

