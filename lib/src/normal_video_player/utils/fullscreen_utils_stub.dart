typedef FullscreenChangeCallback = void Function(bool isFullscreen);

void enterBrowserFullscreen() {}
void exitBrowserFullscreen() {}
bool isBrowserFullscreen() => false;
void listenToFullscreenChange(FullscreenChangeCallback callback) {}
bool enterDesktopPipMode({int width = 380, int height = 214}) => false;
void moveDesktopPipWindow(int deltaX, int deltaY) {}
void exitDesktopPipMode() {}
bool isDesktopPipMode() => false;
void restoreDesktopWindowIfStuckInPip() {}

