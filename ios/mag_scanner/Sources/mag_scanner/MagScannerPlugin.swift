import AudioToolbox
import Flutter
import UIKit

public class MagScannerPlugin: NSObject, FlutterPlugin {
  private var beepSoundId: SystemSoundID = 0

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "mag_scanner", binaryMessenger: registrar.messenger())
    let instance = MagScannerPlugin()
    instance.loadBeep()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "playSound":
      if beepSoundId != 0 {
        AudioServicesPlaySystemSound(beepSoundId)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    if beepSoundId != 0 {
      AudioServicesDisposeSystemSoundID(beepSoundId)
      beepSoundId = 0
    }
  }

  /// Preloaded once so the beep plays without decoding delay after a detection.
  private func loadBeep() {
    #if SWIFT_PACKAGE
      let bundle = Bundle.module
    #else
      let bundle = Bundle(for: MagScannerPlugin.self).url(
        forResource: "mag_scanner_resources", withExtension: "bundle"
      ).flatMap(Bundle.init(url:)) ?? Bundle(for: MagScannerPlugin.self)
    #endif
    guard let url = bundle.url(forResource: "beep", withExtension: "wav") else { return }
    AudioServicesCreateSystemSoundID(url as CFURL, &beepSoundId)
  }
}
