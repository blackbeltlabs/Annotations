import Cocoa

class TextView: NSTextView {
  
  // MARK: - Properties
  private var cursorWidth: CGFloat = 2.0
  
  // MARK: - Overriden
  override var isEditable: Bool {
    didSet {
      if !self.isEditable {
        removeSelectionParts()
      }
    }
  }
  // redirect events to the superview (TextContainewView) is !isEditable
  override func mouseDown(with event: NSEvent) {
    if !isEditable {
      superview?.mouseDown(with: event)
      return
    }
    
    super.mouseDown(with: event)
  }
  
  // MARK: - Visual

  // update typing attributes for both current text and new added text
  func updateTypingAttributes(_ attributes: [NSAttributedString.Key: Any]) {
    // need utf16 here to support emojies
    let length = textStorage?.string.utf16.count ?? 0
    
    textStorage?.setAttributes(
      attributes,
      range: NSRange(location: 0, length: length)
    )
    typingAttributes = attributes
  }
  
  // remove the parts in the text that are selected
  func removeSelectionParts() {
    let selected = selectedRange().upperBound
    let range = NSRange(location: selected == 0 ? string.count : selected, length: 0)
    setSelectedRange(range)
  }
  
  // MARK: - Cursor size methods
  // Taken from here -> https://christiantietze.de/posts/2017/08/nstextview-fat-caret/
  override func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn flag: Bool) {
    var updatedRect = rect
    updatedRect.size.width = cursorWidth
    super.drawInsertionPoint(in: updatedRect, color: color, turnedOn: flag)

  }

  override func setNeedsDisplay(_ rect: NSRect, avoidAdditionalLayout flag: Bool) {
    var rect = rect
    rect.size.width += cursorWidth - 1
    super.setNeedsDisplay(rect, avoidAdditionalLayout: flag)
  }
}


// this method helps to scale text views in a correct way
extension NSTextView {
  var textBoundingBox: CGRect {
    var textInsets = NSEdgeInsets(top: textContainerInset.height,
                                  left: textContainerInset.width,
                                  bottom: textContainerInset.height,
                                  right: textContainerInset.width)

    textInsets.left += textContainer?.lineFragmentPadding ?? 0
    textInsets.right += textContainer?.lineFragmentPadding ?? 0

    return bounds.insetBy(dx: textInsets.left + textInsets.right,
                          dy: textInsets.bottom + textInsets.top)
  }
}
