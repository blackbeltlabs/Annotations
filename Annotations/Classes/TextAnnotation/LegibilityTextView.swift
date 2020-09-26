import Cocoa

class LegibilityTextView: NSTextView {

  override func draw(_ dirtyRect: NSRect) {
    
    let updatedRect = dirtyRect.insetBy(dx: 5, dy: 0)
      
    let c = NSGraphicsContext.current?.cgContext
    
    let lineWidth = font!.pointSize * 8.0 / 30.0

    c!.setLineWidth(lineWidth)
    c!.setLineJoin(.round)
    c!.setTextDrawingMode(.stroke)
    textColor = .white
    
    super.draw(updatedRect)
  }
}
