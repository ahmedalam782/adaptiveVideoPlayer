import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var windowChannel: FlutterMethodChannel?
  private var securityChannel: FlutterMethodChannel?

  private var isPipMode = false
  private var savedPrePipFrame: NSRect?
  private var savedPrePipLevel: NSWindow.Level = .normal
  private var savedPrePipCollectionBehavior: NSWindow.CollectionBehavior = []
  private var savedPrePipStyle: NSWindow.StyleMask?
  private var savedPrePipTitleVisibility: NSWindow.TitleVisibility = .visible
  private var savedPrePipTitlebarTransparent = false
  private var savedPrePipHasShadow = true
  private var savedPrePipIsMovable = true
  private var savedPrePipBackgroundColor: NSColor?

  private var isAppFullscreen = false
  private var keptNativeFullscreen = false
  private var savedFullscreenFrame: NSRect?
  private var savedFullscreenStyle: NSWindow.StyleMask?
  private var savedFullscreenLevel: NSWindow.Level = .normal
  private var savedFullscreenBehavior: NSWindow.CollectionBehavior = []
  private var savedPresentationOptions: NSApplication.PresentationOptions?
  private var savedHasShadow = true
  private var savedIsMovable = true
  private var savedBackgroundColor: NSColor?
  private var savedTitleVisibility: NSWindow.TitleVisibility = .visible
  private var savedTitlebarTransparent = false

  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { true }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    setupMethodChannels(controller: flutterViewController)

    super.awakeFromNib()
  }

  private func setupMethodChannels(controller: FlutterViewController) {
    let messenger = controller.engine.binaryMessenger

    // 1. Fullscreen / Window Management Channel
    let winChannel = FlutterMethodChannel(name: "adaptive_video_player/window", binaryMessenger: messenger)
    self.windowChannel = winChannel
    winChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else {
        result(false)
        return
      }
      switch call.method {
      case "enterFullscreen":
        DispatchQueue.main.async {
          self.enterAppFullscreen()
        }
        result(true)
      case "exitFullscreen":
        DispatchQueue.main.async {
          self.exitAppFullscreen()
        }
        result(true)
      case "toggleFullscreen":
        DispatchQueue.main.async {
          self.toggleFullScreen(nil)
        }
        result(true)
      case "isFullscreen":
        result(self.styleMask.contains(.fullScreen))
      case "enterPip":
        let args = call.arguments as? [String: Any]
        let width = args?["width"] as? CGFloat ?? 380
        let height = args?["height"] as? CGFloat ?? 214
        DispatchQueue.main.async {
          self.enterPipMode(width: width, height: height)
        }
        result(true)
      case "exitPip":
        DispatchQueue.main.async {
          self.exitPipMode()
        }
        result(true)
      case "movePipWindow":
        let args = call.arguments as? [String: Any]
        let deltaX = args?["deltaX"] as? CGFloat ?? 0
        let deltaY = args?["deltaY"] as? CGFloat ?? 0
        DispatchQueue.main.async {
          self.movePipWindow(deltaX: deltaX, deltaY: deltaY)
        }
        result(true)
      case "isPipMode":
        result(self.isPipMode)
      case "restoreIfStuckInPip":
        DispatchQueue.main.async {
          self.restoreIfStuckInPip()
        }
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // Observe native macOS fullscreen events (Esc key, green button, Mission Control, etc.)
    NotificationCenter.default.addObserver(
      forName: NSWindow.didEnterFullScreenNotification,
      object: self,
      queue: .main
    ) { [weak self] _ in
      self?.windowChannel?.invokeMethod("onFullscreenChanged", arguments: true)
    }

    NotificationCenter.default.addObserver(
      forName: NSWindow.didExitFullScreenNotification,
      object: self,
      queue: .main
    ) { [weak self] _ in
      guard let self = self else { return }
      self.windowChannel?.invokeMethod("onFullscreenChanged", arguments: false)
    }

    // 2. Anti-Capture Security Channel (Screenshot & Screen Recording Prevention)
    let secChannel = FlutterMethodChannel(name: "adaptive_video_player/security", binaryMessenger: messenger)
    self.securityChannel = secChannel
    secChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else {
        result(false)
        return
      }
      switch call.method {
      case "setSecureMode":
        let args = call.arguments as? [String: Any]
        let enabled = args?["enabled"] as? Bool ?? false
        DispatchQueue.main.async {
          self.sharingType = enabled ? .none : .readOnly
        }
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func enterAppFullscreen() {
    if isAppFullscreen { return }
    guard let screen = self.screen ?? NSScreen.main else { return }

    savedFullscreenFrame = frame
    savedFullscreenStyle = styleMask
    savedFullscreenLevel = level
    savedFullscreenBehavior = collectionBehavior
    savedPresentationOptions = NSApp.presentationOptions
    savedHasShadow = hasShadow
    savedIsMovable = isMovable
    savedBackgroundColor = backgroundColor
    savedTitleVisibility = titleVisibility
    savedTitlebarTransparent = titlebarAppearsTransparent
    isAppFullscreen = true

    // Already in a native fullscreen Space: keep that space and hide the bars.
    if styleMask.contains(.fullScreen) {
      keptNativeFullscreen = true
      NSMenu.setMenuBarVisible(false)
      NSApp.presentationOptions = [.fullScreen, .hideMenuBar, .hideDock]
      return
    }

    // A titled window is clamped to the area under the menu bar.
    // fullSizeContentView keeps that title bar, so the mask must be borderless only.
    styleMask = [.borderless]
    titleVisibility = .hidden
    titlebarAppearsTransparent = true
    hasShadow = false
    isMovable = false
    backgroundColor = .black
    collectionBehavior.formUnion([.canJoinAllSpaces, .fullScreenAuxiliary])
    level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.mainMenuWindow)) + 2)
    setFrame(screen.frame, display: true, animate: false)
    NSMenu.setMenuBarVisible(false)
    NSApp.presentationOptions = [.hideMenuBar, .hideDock]
    makeKeyAndOrderFront(nil)
  }

  private func exitAppFullscreen() {
    guard isAppFullscreen else { return }
    isAppFullscreen = false
    NSMenu.setMenuBarVisible(true)
    if let options = savedPresentationOptions {
      NSApp.presentationOptions = options
      savedPresentationOptions = nil
    } else {
      NSApp.presentationOptions = []
    }
    if keptNativeFullscreen {
      keptNativeFullscreen = false
      return
    }

    if let style = savedFullscreenStyle {
      styleMask = style
    }
    titleVisibility = savedTitleVisibility
    titlebarAppearsTransparent = savedTitlebarTransparent
    hasShadow = savedHasShadow
    isMovable = savedIsMovable
    if let color = savedBackgroundColor {
      backgroundColor = color
    }
    level = savedFullscreenLevel
    collectionBehavior = savedFullscreenBehavior
    if let saved = savedFullscreenFrame {
      setFrame(saved, display: true, animate: false)
      savedFullscreenFrame = nil
    }
    makeKeyAndOrderFront(nil)
  }

  private func enterPipMode(width: CGFloat, height: CGFloat) {
    guard !isPipMode else { return }

    // Remember the windowed frame. Restoring it and then shrinking in the
    // same turn freezes AppKit when PiP starts from fullscreen.
    let restoreFrame = savedFullscreenFrame ?? frame
    savedPrePipFrame = restoreFrame
    savedPrePipLevel = isAppFullscreen ? savedFullscreenLevel : level
    savedPrePipCollectionBehavior = isAppFullscreen ? savedFullscreenBehavior : collectionBehavior
    savedPrePipStyle = savedFullscreenStyle ?? styleMask
    savedPrePipTitleVisibility = isAppFullscreen ? savedTitleVisibility : titleVisibility
    savedPrePipTitlebarTransparent = isAppFullscreen ? savedTitlebarTransparent : titlebarAppearsTransparent
    savedPrePipHasShadow = isAppFullscreen ? savedHasShadow : hasShadow
    savedPrePipIsMovable = isAppFullscreen ? savedIsMovable : isMovable
    savedPrePipBackgroundColor = isAppFullscreen ? savedBackgroundColor : backgroundColor

    if isAppFullscreen {
      isAppFullscreen = false
      keptNativeFullscreen = false
      savedFullscreenFrame = nil
    }

    isPipMode = true
    // Stay borderless. Putting the title bar back while the frame changes
    // deadlocks the window with the menu bar.
    level = .floating
    collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
    isMovable = true

    let screen = self.screen ?? NSScreen.main
    let visible = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
    let margin: CGFloat = 24
    let safeWidth = min(width, max(visible.width - margin * 2, 120))
    let safeHeight = min(height, max(visible.height - margin * 2, 80))
    let pipFrame = NSRect(
      x: visible.maxX - safeWidth - margin,
      y: visible.minY + margin,
      width: safeWidth,
      height: safeHeight
    )
    setFrame(pipFrame, display: true, animate: false)

    NSMenu.setMenuBarVisible(true)
    if let options = savedPresentationOptions {
      NSApp.presentationOptions = options
      savedPresentationOptions = nil
    }
    makeKeyAndOrderFront(nil)
    windowChannel?.invokeMethod("onPipModeChanged", arguments: true)
  }

  private func exitPipMode() {
    guard isPipMode else { return }
    isPipMode = false
    if let style = savedPrePipStyle {
      styleMask = style
      savedPrePipStyle = nil
    }
    titleVisibility = savedPrePipTitleVisibility
    titlebarAppearsTransparent = savedPrePipTitlebarTransparent
    hasShadow = savedPrePipHasShadow
    isMovable = savedPrePipIsMovable
    if let color = savedPrePipBackgroundColor {
      backgroundColor = color
      savedPrePipBackgroundColor = nil
    }
    level = savedPrePipLevel
    collectionBehavior = savedPrePipCollectionBehavior
    if let savedFrame = savedPrePipFrame {
      setFrame(savedFrame, display: true, animate: false)
      savedPrePipFrame = nil
    }
    makeKeyAndOrderFront(nil)
    windowChannel?.invokeMethod("onPipModeChanged", arguments: false)
  }

  private func movePipWindow(deltaX: CGFloat, deltaY: CGFloat) {
    guard isPipMode else { return }
    var origin = self.frame.origin
    origin.x += deltaX
    origin.y -= deltaY // Cocoa coordinates (0,0) is bottom-left
    self.setFrameOrigin(origin)
  }

  private func restoreIfStuckInPip() {
    if isPipMode || (self.frame.width <= 440 && self.frame.height <= 280) {
      isPipMode = false
      self.level = .normal
      if let screen = self.screen ?? NSScreen.main {
        let visible = screen.visibleFrame
        let w: CGFloat = min(1280, visible.width * 0.85)
        let h: CGFloat = min(720, visible.height * 0.85)
        let x = visible.minX + (visible.width - w) / 2
        let y = visible.minY + (visible.height - h) / 2
        self.setFrame(NSRect(x: x, y: y, width: w, height: h), display: true, animate: true)
      }
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
