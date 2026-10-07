/// Distinct presentation modes for the normal video player surface.
enum NormalPlayerDisplayMode {
  /// The player is rendered fullscreen inside an overlay route.
  fullscreen,

  /// The player is floating in an in-app mini-player overlay.
  miniPlayer,

  /// The player is rendering inside native OS Picture-in-Picture with OS chrome.
  nativePip,

  /// The standard inline video player view.
  normal,
}
