import AppKit

enum LegibilityButtonImageType {
  case enabled
  case disabled
  
  var imageName: String {
    switch self {
    case .enabled:
      return "Toggle_outline_on" // disable if enabled
    case .disabled:
      return "Toggle_outline_off" // enable if disabled
    }
  }
}

class LegibilityButton: NSButton {
  // MARK: - Init
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  private func setupUI() {
    bezelStyle = .regularSquare
    isBordered = false
    wantsLayer = true
    layer?.masksToBounds = false
  }
  
  // MARK: - Update image
  func updateImage(with type: LegibilityButtonImageType) {
    self.cell?.image = ImageHelper.imageFromBundle(named: type.imageName)
  }
}
