import Flutter
import UIKit

public class AdaptiveVideoPlayerPlugin: NSObject, FlutterPlugin {
  private var secureTextField: UITextField?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let securityChannel = FlutterMethodChannel(name: "adaptive_video_player/security", binaryMessenger: registrar.messenger())
    let pipChannel = FlutterMethodChannel(name: "adaptive_video_player/pip", binaryMessenger: registrar.messenger())
    let instance = AdaptiveVideoPlayerPlugin()
    registrar.addMethodCallDelegate(instance, channel: securityChannel)
    registrar.addMethodCallDelegate(instance, channel: pipChannel)
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
        result(true)
      } else {
        result(false)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func toggleSecureMode(enabled: Bool) {
    guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first else { return }
    if enabled {
      if secureTextField == nil {
        let field = UITextField()
        field.isSecureTextEntry = true
        window.addSubview(field)
        window.layer.superlayer?.addSublayer(field.layer)
        field.layer.sublayers?.first?.addSublayer(window.layer)
        secureTextField = field
      }
    } else {
      secureTextField?.removeFromSuperview()
      secureTextField = nil
    }
  }
}
