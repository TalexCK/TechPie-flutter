import Flutter
import UIKit

final class NativeGlassActionButtonFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    NativeGlassActionButtonPlatformView(
      frame: frame,
      viewId: viewId,
      arguments: args,
      messenger: messenger
    )
  }
}

final class NativeGlassActionButtonPlatformView: NSObject, FlutterPlatformView {
  static let viewType = "techpie/native_glass_action_button"

  private let rootView: UIView
  private let channel: FlutterMethodChannel
  private let button = UIButton(type: .system)

  private var label: String?
  private var sfSymbol = "circle"
  private var destructive = false
  private var enabled = true
  private var glassVariant = "automatic"

  init(
    frame: CGRect,
    viewId: Int64,
    arguments args: Any?,
    messenger: FlutterBinaryMessenger
  ) {
    rootView = UIView(frame: frame)
    channel = FlutterMethodChannel(
      name: "\(Self.viewType)/\(viewId)",
      binaryMessenger: messenger
    )

    super.init()

    parseArguments(args)
    buildViewHierarchy()
    applyButtonAppearance()
    button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call: call, result: result)
    }
  }

  deinit {
    channel.setMethodCallHandler(nil)
  }

  func view() -> UIView {
    rootView
  }

  private func parseArguments(_ args: Any?) {
    guard let params = args as? [String: Any] else { return }

    label = params["label"] as? String
    if let rawSymbol = params["sfSymbol"] as? String, !rawSymbol.isEmpty {
      sfSymbol = rawSymbol
    }
    destructive = params["destructive"] as? Bool ?? false
    enabled = params["enabled"] as? Bool ?? true
    glassVariant = params["glassVariant"] as? String ?? glassVariant
  }

  private func handle(call: FlutterMethodCall, result: FlutterResult) {
    switch call.method {
    case "updateConfiguration":
      parseArguments(call.arguments)
      applyButtonAppearance()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func buildViewHierarchy() {
    rootView.backgroundColor = .clear
    rootView.clipsToBounds = false

    button.translatesAutoresizingMaskIntoConstraints = false
    button.accessibilityTraits.insert(.button)
    button.clipsToBounds = false
    if #available(iOS 26.0, *) {
      rootView.addSubview(button)

      NSLayoutConstraint.activate([
        button.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
        button.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
        button.topAnchor.constraint(equalTo: rootView.topAnchor),
        button.bottomAnchor.constraint(equalTo: rootView.bottomAnchor)
      ])
      return
    }

    rootView.addSubview(button)

    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
      button.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
      button.topAnchor.constraint(equalTo: rootView.topAnchor),
      button.bottomAnchor.constraint(equalTo: rootView.bottomAnchor)
    ])
  }

  private func applyButtonAppearance() {
    if #available(iOS 26.0, *) {
      applyLiquidGlassAppearance()
      return
    }

    let image = symbolImage(named: sfSymbol)
    button.isEnabled = enabled

    if #available(iOS 15.0, *) {
      var configuration = UIButton.Configuration.plain()
      configuration.image = image
      configuration.title = label
      if destructive {
        configuration.baseForegroundColor = .systemRed
      }
      button.configuration = configuration
    } else {
      button.setImage(image, for: .normal)
      button.setTitle(label, for: .normal)
      if destructive {
        button.tintColor = .systemRed
        button.setTitleColor(.systemRed, for: .normal)
      }
    }
  }

  @available(iOS 26.0, *)
  private func applyLiquidGlassAppearance() {
    let image = symbolImage(named: sfSymbol)
    button.isEnabled = enabled

    let useClearGlass: Bool
    switch glassVariant {
    case "glass":
      useClearGlass = false
    case "clearGlass":
      useClearGlass = true
    default:
      useClearGlass = label == nil || label?.isEmpty == true
    }

    var configuration: UIButton.Configuration =
      useClearGlass ? .clearGlass() : .glass()
    configuration.image = image
    configuration.title = label
    if destructive {
      configuration.baseForegroundColor = .systemRed
    }

    button.configuration = configuration
  }

  private func symbolImage(named systemName: String) -> UIImage? {
    guard systemName != "none" else { return nil }

    return UIImage(systemName: systemName)?
      .withRenderingMode(.alwaysTemplate)
  }

  @objc
  private func handleTap() {
    guard enabled else { return }
    let feedback = UIImpactFeedbackGenerator(style: .light)
    feedback.impactOccurred(intensity: 0.55)
    channel.invokeMethod("onPressed", arguments: nil)
  }
}
