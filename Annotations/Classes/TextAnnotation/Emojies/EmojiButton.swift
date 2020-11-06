import Cocoa

class EmojiButton: NSButton {
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

    
    layer?.backgroundColor = NSColor(red: 96.0 / 255.0,
                                     green: 97.0 / 255.0,
                                     blue: 237.0 / 255.0,
                                     alpha: 1.0).cgColor
    
    cell?.image = ImageHelper.imageFromBundle(named: "emoji")?.tint(color: .white)
  }
}
