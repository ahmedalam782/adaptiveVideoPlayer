typedef FullscreenChangeCallback = void Function(bool isFullscreen);

void enterBrowserFullscreen() {}
void exitBrowserFullscreen() {}
bool isBrowserFullscreen() => false;
void listenToFullscreenChange(FullscreenChangeCallback callback) {}
