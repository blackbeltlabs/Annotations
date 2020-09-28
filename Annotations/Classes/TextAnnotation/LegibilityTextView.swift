import Cocoa

class LegibilityTextView: NSTextView {
  
    // these base values are calculated empirically
  // and their values are used for the proportion to calculate for any font
  static let baseLineWidthSize: CGFloat = 8.0
  static let baseFontSize: CGFloat = 30.0
    
  override func draw(_ dirtyRect: NSRect) {
    guard let ctx = NSGraphicsContext.current?.cgContext else { return }
    
    ctx.setLineWidth(lineWidth)
    ctx.setLineJoin(.round)
    ctx.setTextDrawingMode(.stroke)
    textColor = .white
    
    super.draw(dirtyRect)
  }
  
  private var lineWidth: CGFloat {
    if let font = font {
      return font.pointSize * Self.baseLineWidthSize / Self.baseFontSize
    } else {
      return Self.baseLineWidthSize
    }
  }
  
  // an additional height that should be added to the height
  // of text view frame to ensure that content isn't clipped
  var additionalHeight: CGFloat {
    lineWidth / 2.0
  }
}
