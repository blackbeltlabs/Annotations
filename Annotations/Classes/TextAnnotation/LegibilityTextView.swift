import Cocoa

class LegibilityTextView: NSTextView {

  override func draw(_ dirtyRect: NSRect) {
    
    let updatedRect = dirtyRect.insetBy(dx: 5, dy: 0)
      
    let c = NSGraphicsContext.current?.cgContext
    
    let lineWidth = font!.pointSize * 8.0 / 30.0

    c!.setLineWidth(lineWidth)
    c!.setLineJoin(.round);
    c!.setTextDrawingMode(.stroke);
    textColor = .white
    super.draw(updatedRect)
  }
  
  // update typing attributes for both current text and new added text
  func updateTypingAttributes(_ attributes: [NSAttributedString.Key: Any]) {
    
    // FIXME: - It dosn't work well with typing attributes. Need another solution here
//    textStorage?.setAttributes(
//      attributes,
//      range: NSRange(location: 0, length: textStorage?.string.count ?? 0)
//    )
//    typingAttributes = attributes
//
//    needsLayout = true
  }
    
}
