import Cocoa

class EmojiControlButton: NSButton, DrawableElement {
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
    layer?.masksToBounds = true
    layer?.cornerRadius = 11.5
    
    cell?.image = ImageHelper.imageFromBundle(named: "emoji")
  }
  
  func setup(with frameRect: CGRect) {
    self.frame = frameRect
  }
}
