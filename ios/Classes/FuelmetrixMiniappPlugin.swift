import Flutter
import MiniNativeLib
import UIKit

private let viewType = "miniapp_view"

// Generic close-event channel — forwards a "close" call from the vendor's
// PlatformView to Dart (see FuelmetrixMiniApp in lib/), which pops the
// screen. This is plumbing only (a name and a pop), not business logic:
// the host app never sees what closeMiniapp() means to the mini app.
private let eventsChannelName = "miniapp/events"

/// Registers the vendor's mini app PlatformView. A host app only needs to
/// add this package as a dependency and use the `FuelmetrixMiniApp`
/// widget — this plugin auto-registers via Flutter's generated plugin
/// registrant, so no AppDelegate.swift edits are required on the host
/// side. It has no idea what's inside the view — no rendering setup, no
/// bridge logic, no business logic. All of that lives in MiniNativeLib
/// (compiled xcframework).
public class FuelmetrixMiniappPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    registrar.register(MiniAppViewFactory(messenger: registrar.messenger()), withId: viewType)
  }
}

private class MiniAppViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?
  ) -> FlutterPlatformView {
    // The host only ever supplies the logged-in user's phone number plus
    // its own vendor clientId/clientSecret — everything else (the load
    // URL, auth) is resolved internally by the vendor's view.
    let params = args as? [String: Any]
    guard let phone = params?["phone"] as? String else {
      fatalError("miniapp_view: missing required \"phone\" creation param")
    }
    guard let clientId = params?["clientId"] as? String else {
      fatalError("miniapp_view: missing required \"clientId\" creation param")
    }
    guard let clientSecret = params?["clientSecret"] as? String else {
      fatalError("miniapp_view: missing required \"clientSecret\" creation param")
    }
    return MiniAppViewPlatformView(
      phone: phone, clientId: clientId, clientSecret: clientSecret, messenger: messenger)
  }
}

private class MiniAppViewPlatformView: NSObject, FlutterPlatformView {
  private let channel: FlutterMethodChannel
  private let miniAppView: MiniAppView

  init(phone: String, clientId: String, clientSecret: String, messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: eventsChannelName, binaryMessenger: messenger)
    self.channel = channel
    self.miniAppView = MiniAppView(
      phone: phone, clientId: clientId, clientSecret: clientSecret,
      onClose: { channel.invokeMethod("close", arguments: nil) })
    super.init()

    // Same channel, the other direction: Dart's PopScope (see
    // FuelmetrixMiniApp) forwards a system back gesture here. The plugin
    // doesn't decide anything — just forwards to the vendor's view, which
    // is the only thing that knows its own navigation state.
    let miniAppView = self.miniAppView
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "backPressed":
        miniAppView.handleBackPressed()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView { miniAppView }

  deinit {
    channel.setMethodCallHandler(nil)
    miniAppView.dispose()
  }
}
