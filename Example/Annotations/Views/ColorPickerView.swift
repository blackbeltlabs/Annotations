
import Cocoa

class ColorPickerView: NSControl {
  
  var viewId: Int = 0
  
  var isSelected: Bool = false {
    didSet {
      setSelected(isSelected)
    }
  }
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    setupUI()
  }
  
  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
    setupUI()
  }
  
  func setupUI() {
    wantsLayer = true
  }
  
  private func setSelected(_ selected: Bool) {
    if selected {
      layer?.borderColor = NSColor.black.cgColor
      layer?.borderWidth = 3.0
    } else {
      layer?.borderColor = NSColor.clear.cgColor
      layer?.borderWidth = 0.0
    }
  }
  
  func setBackgroundColor(color: NSColor) {
    layer?.backgroundColor = color.cgColor
  }

}
