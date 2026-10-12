import Flutter
import UIKit
import AVKit
import AVFoundation

public class AdaptiveVideoPlayerPlugin: NSObject, FlutterPlugin, AVPictureInPictureControllerDelegate {
  private var secureField: UITextField?
  private var protectedWindowSuperlayer: CALayer?
  private var pipChannel: FlutterMethodChannel?
  private var pipController: AVPictureInPictureController?
  private var pipPlayer: AVPlayer?
  private var pipPlayerLayer: AVPlayerLayer?
  private var pipContainerView: UIView?
  private var isPipActive = false
  private var currentVideoUrl: String?
  private var isPlayingState = true
  private var restoreRequested = false
  private var pipWasPlayingOnStop = false
  private var didCaptureStopPlayback = false

  public static func register(with registrar: FlutterPluginRegistrar) {
    let securityChannel = FlutterMethodChannel(name: "adaptive_video_player/security", binaryMessenger: registrar.messenger())
    let pipChannel = FlutterMethodChannel(name: "adaptive_video_player/pip", binaryMessenger: registrar.messenger())
    let instance = AdaptiveVideoPlayerPlugin()
    instance.pipChannel = pipChannel
    registrar.addMethodCallDelegate(instance, channel: securityChannel)
    registrar.addMethodCallDelegate(instance, channel: pipChannel)

    // Ensure audio session category allows background audio and PiP immediately
    instance.setupAudioSession()
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "setSecureMode":
      if let args = call.arguments as? [String: Any],
         let enabled = args["enabled"] as? Bool {
        DispatchQueue.main.async {
          self.toggleSecureMode(enabled: enabled)
        }
        result(true)
      } else {
        result(false)
      }

    case "isPipSupported":
      if #available(iOS 14.0, *) {
        result(AVPictureInPictureController.isPictureInPictureSupported())
      } else {
        result(false)
      }

    case "isInPip":
      result(isPipActive)

    case "setPipEnabled":
      var enabled = false
      var url: String?
      if let b = call.arguments as? Bool {
        enabled = b
      } else if let dict = call.arguments as? [String: Any] {
        enabled = dict["enabled"] as? Bool ?? false
        url = dict["url"] as? String
      }
      DispatchQueue.main.async {
        if #available(iOS 14.2, *) {
          self.pipController?.canStartPictureInPictureAutomaticallyFromInline = false
        }
        if !enabled {
          self.stopPictureInPicture()
          return
        }
        if let u = url {
          self.setupPipPlayer(urlStr: u, positionMs: nil, autoPlay: self.isPlayingState)
        }
      }
      result(true)

    case "updatePlaybackState":
      if let args = call.arguments as? [String: Any] {
        let isPlaying = args["isPlaying"] as? Bool ?? true
        self.isPlayingState = isPlaying
        let url = args["url"] as? String
        let pos = args["positionMs"] as? Int
        DispatchQueue.main.async {
          if let u = url {
            self.setupPipPlayer(urlStr: u, positionMs: pos, autoPlay: isPlaying)
          } else if let pos = pos, let player = self.pipPlayer {
            let cmTime = CMTime(value: CMTimeValue(pos), timescale: 1000)
            player.seek(to: cmTime)
          }
        }
      }
      result(true)

    case "enterPip":
      DispatchQueue.main.async {
        if let args = call.arguments as? [String: Any] {
          if let url = args["url"] as? String {
            let pos = args["positionMs"] as? Int
            let isPlaying = args["isPlaying"] as? Bool ?? true
            self.isPlayingState = isPlaying
            self.setupPipPlayer(urlStr: url, positionMs: pos, autoPlay: isPlaying)
          }
        }
        self.startPictureInPicture(result: result)
      }

    case "exitPip":
      DispatchQueue.main.async {
        self.restoreRequested = true
        self.stopPictureInPicture()
        result(true)
      }

    case "closePip":
      DispatchQueue.main.async {
        self.restoreRequested = false
        self.stopPictureInPicture()
        result(true)
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func setupAudioSession() {
    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(.playback, mode: .moviePlayback, options: [])
      try audioSession.setActive(true)
    } catch {
      print("[AdaptiveVideoPlayerPlugin] AVAudioSession error: \(error)")
    }
  }

  private func getKeyWindow() -> UIWindow? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let activeScenes = scenes.filter {
      $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive
    }
    let orderedScenes = activeScenes.isEmpty ? scenes : activeScenes
    return orderedScenes
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
  }

  private func playbackPositionMs() -> Int {
    guard let seconds = pipPlayer?.currentTime().seconds, seconds.isFinite, seconds >= 0 else {
      return 0
    }
    return Int((seconds * 1000).rounded())
  }

  private func setupPipPlayer(urlStr: String, positionMs: Int? = nil, autoPlay: Bool = true) {
    isPlayingState = autoPlay
    setupAudioSession()
    guard let url = URL(string: urlStr) else { return }

    if currentVideoUrl == urlStr, let player = pipPlayer {
      if let pos = positionMs {
        let cmTime = CMTime(value: CMTimeValue(pos), timescale: 1000)
        player.seek(to: cmTime)
      }
      return
    }

    currentVideoUrl = urlStr
    let playerItem = AVPlayerItem(url: url)
    let player = AVPlayer(playerItem: playerItem)
    self.pipPlayer = player

    guard let window = getKeyWindow() else { return }

    if pipContainerView == nil {
      let container = UIView(frame: CGRect(x: 0, y: 0, width: 2, height: 2))
      container.alpha = 0.01
      container.isUserInteractionEnabled = false
      window.addSubview(container)
      self.pipContainerView = container
    }

    pipPlayerLayer?.removeFromSuperlayer()
    let layer = AVPlayerLayer(player: player)
    layer.frame = CGRect(x: 0, y: 0, width: 2, height: 2)
    pipContainerView?.layer.addSublayer(layer)
    self.pipPlayerLayer = layer

    if #available(iOS 14.0, *), AVPictureInPictureController.isPictureInPictureSupported() {
      pipController = AVPictureInPictureController(playerLayer: layer)
      pipController?.delegate = self
      if #available(iOS 14.2, *) {
        // Backgrounding the app must not open PiP. PiP starts only from enterPip.
        pipController?.canStartPictureInPictureAutomaticallyFromInline = false
      }
    }

    if let pos = positionMs {
      let cmTime = CMTime(value: CMTimeValue(pos), timescale: 1000)
      player.seek(to: cmTime)
    }
  }

  private func startPictureInPicture(result: @escaping FlutterResult) {
    guard #available(iOS 14.0, *),
          AVPictureInPictureController.isPictureInPictureSupported() else {
      result(false)
      return
    }

    if let pip = pipController, pip.isPictureInPicturePossible {
      applyPipPlaybackIntent()
      pip.startPictureInPicture()
      result(true)
    } else {
      // Retry shortly after buffer initializes
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
        guard let self = self, let pip = self.pipController, pip.isPictureInPicturePossible else {
          result(false)
          return
        }
        self.applyPipPlaybackIntent()
        pip.startPictureInPicture()
        result(true)
      }
    }
  }

  private func applyPipPlaybackIntent() {
    if isPlayingState {
      pipPlayer?.play()
    } else {
      pipPlayer?.pause()
    }
  }

  private func stopPictureInPicture() {
    if #available(iOS 14.0, *), pipController?.isPictureInPictureActive == true {
      if !didCaptureStopPlayback {
        pipWasPlayingOnStop = (pipPlayer?.rate ?? 0) > 0.01
        didCaptureStopPlayback = true
      }
      pipController?.stopPictureInPicture()
      return
    }
    pipPlayer?.pause()
    isPipActive = false
  }

  // MARK: - AVPictureInPictureControllerDelegate
  public func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
    isPipActive = true
    applyPipPlaybackIntent()
    pipChannel?.invokeMethod("onPipModeChanged", arguments: true)
  }

  public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
    isPipActive = true
    pipChannel?.invokeMethod("onPipModeChanged", arguments: true)
  }

  public func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
    if !didCaptureStopPlayback {
      pipWasPlayingOnStop = (pipPlayer?.rate ?? 0) > 0.01
      didCaptureStopPlayback = true
    }
    // The close button does not restore the app. Stop playback immediately so
    // the PiP player cannot keep running after the window is dismissed.
    if !restoreRequested {
      pipPlayer?.pause()
    }
  }

  public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
    let positionMs = playbackPositionMs()
    let wasPlaying = pipWasPlayingOnStop
    let dismissed = !restoreRequested
    isPipActive = false
    restoreRequested = false
    pipWasPlayingOnStop = false
    didCaptureStopPlayback = false
    pipPlayer?.pause()
    pipChannel?.invokeMethod("onPipModeChanged", arguments: false)
    pipChannel?.invokeMethod("onPipSessionEnded", arguments: [
      "positionMs": positionMs,
      "isPlaying": dismissed ? false : wasPlaying,
      "dismissed": dismissed,
    ])
  }

  public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
    isPipActive = false
    pipChannel?.invokeMethod("onPipModeChanged", arguments: false)
  }

  public func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
    restoreRequested = true
    completionHandler(true)
  }

  // MARK: - Screen Protection / Anti-Capture Shield
  private func toggleSecureMode(enabled: Bool) {
    guard let window = getKeyWindow() else { return }

    if enabled {
      guard secureField == nil else { return }
      let field = UITextField(frame: window.bounds)
      field.backgroundColor = .clear
      field.isUserInteractionEnabled = false
      field.isSecureTextEntry = true
      field.translatesAutoresizingMaskIntoConstraints = false
      window.addSubview(field)
      NSLayoutConstraint.activate([
        field.leadingAnchor.constraint(equalTo: window.leadingAnchor),
        field.trailingAnchor.constraint(equalTo: window.trailingAnchor),
        field.topAnchor.constraint(equalTo: window.topAnchor),
        field.bottomAnchor.constraint(equalTo: window.bottomAnchor),
      ])
      window.layoutIfNeeded()

      guard let windowSuperlayer = window.layer.superlayer else {
        field.removeFromSuperview()
        return
      }

      let windowFrame = window.layer.frame
      protectedWindowSuperlayer = windowSuperlayer
      windowSuperlayer.addSublayer(field.layer)
      field.layer.frame = windowFrame

      guard let secureLayer = secureCanvasLayer(in: field) else {
        field.layer.removeFromSuperlayer()
        field.removeFromSuperview()
        protectedWindowSuperlayer = nil
        return
      }

      // Flutter draws with Metal on the window layer. iOS only blacks out
      // content that is inside this canvas layer, and the canvas must be
      // full-screen or the window is drawn in the corner.
      secureLayer.frame = field.layer.bounds
      let windowLayer = window.layer
      windowLayer.removeFromSuperlayer()
      secureLayer.addSublayer(windowLayer)
      windowLayer.frame = secureLayer.bounds
      secureField = field
    } else if let field = secureField {
      let windowLayer = window.layer
      windowLayer.removeFromSuperlayer()
      if let superlayer = protectedWindowSuperlayer {
        superlayer.addSublayer(windowLayer)
        windowLayer.frame = superlayer.bounds
      }
      field.layer.removeFromSuperlayer()
      field.removeFromSuperview()
      secureField = nil
      protectedWindowSuperlayer = nil
    }
  }

  /// The text-field sublayer whose backing store is omitted from screenshots.
  private func secureCanvasLayer(in field: UITextField) -> CALayer? {
    guard let layers = field.layer.sublayers, !layers.isEmpty else { return nil }
    if let canvas = layers.first(where: { layer in
      let name = String(describing: type(of: layer.delegate as AnyObject))
      return name.contains("Canvas") || name.contains("TextLayout")
    }) {
      return canvas
    }
    return layers.last
  }
}
