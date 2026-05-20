import Flutter
import UIKit

final class NativeGlassButtonGroupFactory: NSObject, FlutterPlatformViewFactory {
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
    NativeGlassButtonGroupPlatformView(
      frame: frame,
      viewId: viewId,
      arguments: args,
      messenger: messenger
    )
  }
}

final class NativeGlassButtonGroupPlatformView: NSObject, FlutterPlatformView {
  static let viewType = "techpie/native_glass_button_group"

  private let rootView: UIView
  private let channel: FlutterMethodChannel
  private let stackView = UIStackView()

  private var items: [NativeGlassButtonGroupItem] = []
  private var buttons: [UIButton] = []

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
    applyItems()
  }

  func view() -> UIView {
    rootView
  }

  private func parseArguments(_ args: Any?) {
    guard let params = args as? [String: Any] else {
      applyDefaultItemsIfNeeded()
      return
    }

    if let rawItems = params["buttons"] as? [[String: Any]] {
      items = rawItems.compactMap(NativeGlassButtonGroupItem.init)
    }

    applyDefaultItemsIfNeeded()
  }

  private func applyDefaultItemsIfNeeded() {
    guard items.isEmpty else {
      return
    }

    items = [
      NativeGlassButtonGroupItem(
        id: "previous",
        sfSymbol: "chevron.left",
        accessibilityLabel: "Previous"
      ),
      NativeGlassButtonGroupItem(
        id: "next",
        sfSymbol: "chevron.right",
        accessibilityLabel: "Next"
      )
    ]
  }

  private func buildViewHierarchy() {
    rootView.backgroundColor = .clear
    rootView.clipsToBounds = false

    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.spacing = 0
    stackView.distribution = .fillEqually
    stackView.alignment = .fill

    rootView.addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
      stackView.topAnchor.constraint(equalTo: rootView.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor)
    ])
  }

  private func applyItems() {
    stackView.arrangedSubviews.forEach { view in
      stackView.removeArrangedSubview(view)
      view.removeFromSuperview()
    }
    buttons.removeAll()

    for (index, item) in items.enumerated() {
      let button = makeButton(for: item, index: index)
      buttons.append(button)
      stackView.addArrangedSubview(button)
    }

  }

  private func makeButton(for item: NativeGlassButtonGroupItem, index: Int) -> UIButton {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.tag = index
    button.accessibilityLabel = item.accessibilityLabel ?? item.id
    button.accessibilityTraits.insert(.button)
    button.addTarget(self, action: #selector(handleButtonTap(_:)), for: .touchUpInside)

    let image = symbolImage(named: item.sfSymbol)

    if #available(iOS 26.0, *) {
      var configuration = UIButton.Configuration.glass()
      configuration.image = image
      button.configuration = configuration
    } else if #available(iOS 15.0, *) {
      var configuration = UIButton.Configuration.plain()
      configuration.image = image
      button.configuration = configuration
    } else {
      button.setImage(image, for: .normal)
    }

    return button
  }

  private func symbolImage(named systemName: String) -> UIImage? {
    return UIImage(systemName: systemName)?
      .withRenderingMode(.alwaysTemplate)
  }

  @objc
  private func handleButtonTap(_ sender: UIButton) {
    guard items.indices.contains(sender.tag) else {
      return
    }

    let feedback = UIImpactFeedbackGenerator(style: .light)
    feedback.impactOccurred(intensity: 0.6)

    channel.invokeMethod("onTap", arguments: ["id": items[sender.tag].id])
  }
}

private struct NativeGlassButtonGroupItem {
  let id: String
  let sfSymbol: String
  let accessibilityLabel: String?

  init(id: String, sfSymbol: String, accessibilityLabel: String?) {
    self.id = id
    self.sfSymbol = sfSymbol
    self.accessibilityLabel = accessibilityLabel
  }

  init?(_ dictionary: [String: Any]) {
    guard
      let id = dictionary["id"] as? String,
      let sfSymbol = dictionary["sfSymbol"] as? String,
      !id.isEmpty,
      !sfSymbol.isEmpty
    else {
      return nil
    }

    self.init(
      id: id,
      sfSymbol: sfSymbol,
      accessibilityLabel: dictionary["accessibilityLabel"] as? String
    )
  }
}
