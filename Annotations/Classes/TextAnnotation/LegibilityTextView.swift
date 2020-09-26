import Cocoa

class LegibilityTextView: NSTextView {
    
  override func draw(_ dirtyRect: NSRect) {
    
    // this base values are calculated empirically
    // and their values are used for the proportion to calculate for any font
    let baseLineWidthSize: CGFloat = 8.0
    let baseFontSize: CGFloat = 30.0
          
    let c = NSGraphicsContext.current?.cgContext
    
    let lineWidth: CGFloat
    if let font = font {
      lineWidth = font.pointSize * baseLineWidthSize / baseFontSize
    } else {
      lineWidth = baseLineWidthSize
    }

    c!.setLineWidth(lineWidth)
    c!.setLineJoin(.round)
    c!.setTextDrawingMode(.stroke)
    textColor = .white
    
    super.draw(dirtyRect)
  }
}
