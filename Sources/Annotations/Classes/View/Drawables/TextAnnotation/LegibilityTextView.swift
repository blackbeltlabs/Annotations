import Cocoa

class LegibilityTextView: NSTextView {
  override func draw(_ dirtyRect: NSRect) {
    guard let ctx = NSGraphicsContext.current?.cgContext else { return }
    ctx.setLineWidth(lineWidth)
    ctx.setLineJoin(.round)
    ctx.setTextDrawingMode(.stroke)
    textColor = .white
    
    super.draw(dirtyRect)
  }
  
  private var lineWidth: CGFloat {
    LegibilityTextHeightCalculator.lineWidth(for: font?.pointSize)
  }
  
  override func hitTest(_ point: NSPoint) -> NSView? {
    return nil
  }
}
