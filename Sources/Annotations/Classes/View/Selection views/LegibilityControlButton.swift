import AppKit

enum LegibilityControlImageType {
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

class LegibilityControlButton: NSButton, @preconcurrency DrawableElement {
  
  var id: String = ""
  
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
  
  func setupWith(frame: CGRect, imageType: LegibilityControlImageType) {
    self.frame = frame
    updateImage(with: imageType)
  }
  
  // MARK: - Update image
  func updateImage(with type: LegibilityControlImageType) {
    self.cell?.image = ImageHelper.imageFromBundle(named: type.imageName)
  }
}
