import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var secureTextField: UITextField?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let controller = window?.rootViewController as? FlutterViewController
    if let messenger = controller?.binaryMessenger {
      let securityChannel = FlutterMethodChannel(name: "adaptive_video_player/security", binaryMessenger: messenger)
      securityChannel.setMethodCallHandler { [weak self] (call, result) in
        if call.method == "setSecureMode" {
          let args = call.arguments as? [String: Any]
          let enabled = args?["enabled"] as? Bool ?? false
          self?.setSecureMode(enabled: enabled)
          result(true)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
  }

  private func setSecureMode(enabled: Bool) {
    if enabled {
      if secureTextField == nil {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.isUserInteractionEnabled = false
        window?.addSubview(field)
        field.centerYAnchor.constraint(equalTo: window!.centerYAnchor).isActive = true
        field.centerXAnchor.constraint(equalTo: window!.centerXAnchor).isActive = true
        window?.layer.superlayer?.addSublayer(field.layer)
        field.layer.sublayers?.first?.addSublayer(window!.layer)
        secureTextField = field
      }
    } else {
      secureTextField?.removeFromSuperview()
      secureTextField = nil
    }
  }
}
