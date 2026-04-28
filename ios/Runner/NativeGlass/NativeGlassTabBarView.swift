import Flutter
import UIKit

final class NativeGlassTabBarFactory: NSObject, FlutterPlatformViewFactory {
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
    NativeGlassTabBarPlatformView(
      frame: frame,
      viewId: viewId,
      arguments: args,
      messenger: messenger
    )
  }
}

private final class NativeTabBarHostView: UIView {
  let tabBar = UITabBar()
  var onValidLayout: ((_ width: CGFloat, _ height: CGFloat) -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = .clear
    clipsToBounds = false

    tabBar.frame = bounds
    tabBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(tabBar)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    setNeedsLayout()
    layoutIfNeeded()
    emitValidLayoutIfReady()
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    tabBar.frame = bounds
    emitValidLayoutIfReady()
  }

  private func emitValidLayoutIfReady() {
    guard window != nil else {
      return
    }

    guard bounds.width > 40, bounds.height > 20 else {
      return
    }

    onValidLayout?(bounds.width, bounds.height)
  }
}

final class NativeGlassTabBarPlatformView: NSObject, FlutterPlatformView, UITabBarDelegate {
  static let viewType = "techpie/native_glass_tab_bar"

  private let tabBarIconPointSize: CGFloat = 20
  private let explicitItemSpacing: CGFloat = 1

  private let rootView: NativeTabBarHostView
  private let channel: FlutterMethodChannel

  private var tabBar: UITabBar {
    rootView.tabBar
  }

  private var items: [NativeGlassTabBarItem] = []
  private var selectedIndex = 0

  private var didInstallItems = false
  private var isInstallingItems = false
  private var lastInstalledSize: CGSize = .zero
  private var lastItemSignature = ""

  private var normalTitleAttributes: [NSAttributedString.Key: Any] {
    [
      .foregroundColor: NativeGlassColors.normalItem,
      .font: UIFont.systemFont(ofSize: 10.5, weight: .medium)
    ]
  }

  private var selectedTitleAttributes: [NSAttributedString.Key: Any] {
    [
      .foregroundColor: NativeGlassColors.selectedBlue,
      .font: UIFont.systemFont(ofSize: 10.5, weight: .semibold)
    ]
  }

  private var itemSignature: String {
    items
      .map { "\($0.label)|\($0.sfSymbol)|\($0.selectedSfSymbol)" }
      .joined(separator: ";")
  }

  init(
    frame: CGRect,
    viewId: Int64,
    arguments args: Any?,
    messenger: FlutterBinaryMessenger
  ) {
    rootView = NativeTabBarHostView(frame: frame)
    channel = FlutterMethodChannel(
      name: "\(Self.viewType)/\(viewId)",
      binaryMessenger: messenger
    )

    super.init()

    parseArguments(args)
    configureTabBarShell()

    rootView.onValidLayout = { [weak self] width, height in
      self?.installItemsIfNeeded(width: width, height: height)
    }

    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call: call, result: result)
    }
  }

  func view() -> UIView {
    rootView
  }

  private func parseArguments(_ args: Any?) {
    if let params = args as? [String: Any] {
      selectedIndex = params["selectedIndex"] as? Int ?? 0

      if let rawItems = params["items"] as? [[String: Any]] {
        items = rawItems.compactMap(NativeGlassTabBarItem.init)
      }
    }

    if items.isEmpty {
      items = [
        NativeGlassTabBarItem(
          label: "Home",
          sfSymbol: "house",
          selectedSfSymbol: "house.fill"
        ),
        NativeGlassTabBarItem(
          label: "Schedule",
          sfSymbol: "calendar",
          selectedSfSymbol: "calendar.circle.fill"
        ),
        NativeGlassTabBarItem(
          label: "Assignments",
          sfSymbol: "checkmark.circle",
          selectedSfSymbol: "checkmark.circle.fill"
        ),
        NativeGlassTabBarItem(
          label: "Settings",
          sfSymbol: "gearshape",
          selectedSfSymbol: "gearshape.fill"
        )
      ]
    }

    selectedIndex = clampedIndex(selectedIndex)
  }

  private func configureTabBarShell() {
    tabBar.delegate = self
    tabBar.isTranslucent = true
    tabBar.backgroundColor = .clear
    tabBar.clipsToBounds = false

    tabBar.itemPositioning = .centered
    tabBar.itemSpacing = explicitItemSpacing
  }

  private func configureTabBarAppearance(availableWidth width: CGFloat) {
    let appearance = UITabBarAppearance()

    appearance.configureWithTransparentBackground()
    appearance.backgroundColor = NativeGlassColors.barBackground
    appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
    appearance.shadowColor = .clear
    appearance.shadowImage = nil
    appearance.backgroundImage = nil

    configureItemAppearance(appearance.stackedLayoutAppearance)
    configureItemAppearance(appearance.inlineLayoutAppearance)
    configureItemAppearance(appearance.compactInlineLayoutAppearance)

    let count = max(items.count, 1)
    let totalSpacing = explicitItemSpacing * CGFloat(max(count - 1, 0))
    let itemWidth = floor((width - totalSpacing) / CGFloat(count))

    appearance.stackedItemPositioning = .centered
    appearance.stackedItemWidth = max(44, itemWidth)
    appearance.stackedItemSpacing = explicitItemSpacing

    tabBar.standardAppearance = appearance

    if #available(iOS 15.0, *) {
      tabBar.scrollEdgeAppearance = appearance
    }

    tabBar.itemPositioning = .centered
    tabBar.itemWidth = max(44, itemWidth)
    tabBar.itemSpacing = explicitItemSpacing

    tabBar.tintColor = NativeGlassColors.selectedBlue
    tabBar.unselectedItemTintColor = NativeGlassColors.normalItem
  }

  private func configureItemAppearance(_ itemAppearance: UITabBarItemAppearance) {
    itemAppearance.normal.iconColor = NativeGlassColors.normalItem
    itemAppearance.normal.titleTextAttributes = normalTitleAttributes

    itemAppearance.selected.iconColor = NativeGlassColors.selectedBlue
    itemAppearance.selected.titleTextAttributes = selectedTitleAttributes

    itemAppearance.focused.iconColor = NativeGlassColors.selectedBlue
    itemAppearance.focused.titleTextAttributes = selectedTitleAttributes

    itemAppearance.disabled.iconColor = NativeGlassColors.normalItem.withAlphaComponent(0.28)
    itemAppearance.disabled.titleTextAttributes = [
      .foregroundColor: NativeGlassColors.normalItem.withAlphaComponent(0.28),
      .font: UIFont.systemFont(ofSize: 10.5, weight: .medium)
    ]
  }

  private func installItemsIfNeeded(width: CGFloat, height: CGFloat) {
    guard !isInstallingItems else {
      return
    }

    guard width > 40, height > 20 else {
      return
    }

    let size = CGSize(width: width, height: height)
    let sizeChanged =
      abs(size.width - lastInstalledSize.width) > 0.5 ||
      abs(size.height - lastInstalledSize.height) > 0.5
    let signatureChanged = itemSignature != lastItemSignature

    guard !didInstallItems || sizeChanged || signatureChanged else {
      return
    }

    isInstallingItems = true
    defer {
      isInstallingItems = false
    }

    didInstallItems = true
    lastInstalledSize = size
    lastItemSignature = itemSignature

    tabBar.frame = CGRect(x: 0, y: 0, width: width, height: height)

    configureTabBarAppearance(availableWidth: width)

    tabBar.setItems(makeTabItems(), animated: false)
    applySelectedItem()
    refreshTabBarColors()

    tabBar.setNeedsLayout()
    tabBar.layoutIfNeeded()
  }

  private func makeTabItems() -> [UITabBarItem] {
    items.enumerated().map { index, item in
      let image = configuredSymbolImage(named: item.sfSymbol, weight: .medium)
      let selectedImage = configuredSymbolImage(
        named: item.selectedSfSymbol,
        weight: .semibold
      )

      let tabItem = UITabBarItem(
        title: item.label,
        image: image,
        selectedImage: selectedImage
      )

      tabItem.tag = index
      tabItem.setTitleTextAttributes(normalTitleAttributes, for: .normal)
      tabItem.setTitleTextAttributes(selectedTitleAttributes, for: .selected)

      return tabItem
    }
  }

  private func updateSelection(to index: Int) {
    selectedIndex = clampedIndex(index)
    applySelectedItem()
    refreshTabBarColors()
  }

  private func applySelectedItem() {
    guard let tabItems = tabBar.items, tabItems.indices.contains(selectedIndex) else {
      return
    }

    tabBar.selectedItem = tabItems[selectedIndex]
  }

  private func refreshTabBarColors() {
    tabBar.tintColor = NativeGlassColors.selectedBlue
    tabBar.unselectedItemTintColor = NativeGlassColors.normalItem

    if let tabItems = tabBar.items {
      for item in tabItems {
        item.setTitleTextAttributes(normalTitleAttributes, for: .normal)
        item.setTitleTextAttributes(selectedTitleAttributes, for: .selected)
      }
    }

    tabBar.setNeedsLayout()
  }

  private func configuredSymbolImage(
    named systemName: String,
    weight: UIImage.SymbolWeight
  ) -> UIImage? {
    let configuration = UIImage.SymbolConfiguration(
      pointSize: tabBarIconPointSize,
      weight: weight,
      scale: .medium
    )

    return UIImage(systemName: systemName, withConfiguration: configuration)?
      .withRenderingMode(.alwaysTemplate)
  }

  private func clampedIndex(_ index: Int) -> Int {
    guard !items.isEmpty else {
      return 0
    }

    return min(max(index, 0), items.count - 1)
  }

  private func handle(call: FlutterMethodCall, result: FlutterResult) {
    switch call.method {
    case "updateSelectedIndex":
      guard
        let arguments = call.arguments as? [String: Any],
        let index = arguments["index"] as? Int
      else {
        result(
          FlutterError(
            code: "bad_args",
            message: "Expected an index.",
            details: nil
          )
        )
        return
      }

      updateSelection(to: index)
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    let index = item.tag
    selectedIndex = clampedIndex(index)
    refreshTabBarColors()
    channel.invokeMethod("onSelect", arguments: ["index": selectedIndex])
  }
}

private struct NativeGlassTabBarItem {
  let label: String
  let sfSymbol: String
  let selectedSfSymbol: String

  init(label: String, sfSymbol: String, selectedSfSymbol: String) {
    self.label = label
    self.sfSymbol = sfSymbol
    self.selectedSfSymbol = selectedSfSymbol
  }

  init?(_ dictionary: [String: Any]) {
    guard
      let label = dictionary["label"] as? String,
      let sfSymbol = dictionary["sfSymbol"] as? String,
      let selectedSfSymbol = dictionary["selectedSfSymbol"] as? String
    else {
      return nil
    }

    self.init(
      label: label,
      sfSymbol: sfSymbol,
      selectedSfSymbol: selectedSfSymbol
    )
  }
}