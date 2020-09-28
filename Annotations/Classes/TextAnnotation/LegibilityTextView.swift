import Cocoa

class LegibilityTextView: NSTextView {
    
  override func draw(_ dirtyRect: NSRect) {
    
    // this base values are calculated empirically
    // and their values are used for the proportion to calculate for any font
    let baseLineWidthSize: CGFloat = 8.0
    let baseFontSize: CGFloat = 30.0
          
    guard let ctx = NSGraphicsContext.current?.cgContext else { return }
    
    let lineWidth: CGFloat
    if let font = font {
      lineWidth = font.pointSize * baseLineWidthSize / baseFontSize
    } else {
      lineWidth = baseLineWidthSize
    }

    ctx.setLineWidth(lineWidth)
    ctx.setLineJoin(.round)
    ctx.setTextDrawingMode(.stroke)
    textColor = .white
    
    super.draw(dirtyRect)
  }
}
