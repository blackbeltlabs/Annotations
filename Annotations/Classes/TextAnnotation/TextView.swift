import Cocoa

struct FontSnapshot {
  let name: String
  let size: CGFloat
}

class TextView: NSTextView {
  
  // MARK: - Variables
  lazy var twoSymbolsWidth: CGFloat = 2 * getFont().xHeight
  fileprivate(set) var lastFontSnapshot: FontSnapshot?
  
  private weak var activeAreaResponder: MouseTrackingResponder?
  
  var cursorWidth: CGFloat = 2.0
  
  // MARK: Private
  
  private var fontSizeToSizeRatio: CGFloat!
  
  // MARK: - Lifecycle
  
  convenience init(frame frameRect: NSRect, responder: MouseTrackingResponder ) {
    self.init(frame: frameRect)
    
    activeAreaResponder = responder
    
    let options = NSTrackingArea.Options.activeInKeyWindow.rawValue | NSTrackingArea.Options.mouseEnteredAndExited.rawValue
    let trackingArea = NSTrackingArea(rect: bounds, options: NSTrackingArea.Options(rawValue: options), owner: self, userInfo: nil)
    
    addTrackingArea(trackingArea)
  }
  
  override func mouseDown(with event: NSEvent) {
    if !isEditable {
      superview?.mouseDown(with: event)
      return
    }
    
    super.mouseDown(with: event)
  }
  
  override func mouseEntered(with event: NSEvent) {
    if let responder = activeAreaResponder {
      responder.areaDidActivated(.textArea)
    }
    
    super.mouseEntered(with: event)
  }
  
  // MARK: - Public
  
  func frameForWidth(_ width: CGFloat, height: CGFloat) -> CGRect {
    return string.boundingRect(with: CGSize(width: width, height: height),
                               options: NSString.DrawingOptions.usesLineFragmentOrigin,
                               attributes: typingAttributes)
  }
  
  func calculateScaleRatio() {
    let fontSize = getFont().pointSize
    let temp = frame.height / CGFloat(numberOfLines())
    fontSizeToSizeRatio = fontSize / temp
  }
  
  func resetFontSize() {
    fitTextToBounds()
  }
  
  public func getFont() -> NSFont {
    return font ?? NSFont.systemFont(ofSize: 15)
  }
	
  public var currentFontSnapshot: FontSnapshot {
    let currentFont = getFont()
    return FontSnapshot(name: currentFont.fontName,
                        size: currentFont.pointSize)
  }
  
  public func makeFontSnapshot() {
    lastFontSnapshot = currentFontSnapshot
  }
  
  public func deleteFontSnapshot() {
    lastFontSnapshot = nil
  }
  
  // MARK: - Layout
  
  func updateTypingAttributes(_ attributes: [NSAttributedString.Key: Any]) {
    textStorage?.setAttributes(
      attributes,
      range: NSRange(location: 0, length: textStorage?.string.count ?? 0)
    )
    typingAttributes = attributes
  }
  
  // MARK: - Private
  
  private func numberOfLines() -> Int {
    var numberOfLines = 1
    if let lManager = layoutManager {
      let numberOfGlyphs = lManager.numberOfGlyphs
      var index = 0
      var lineRange = NSRange(location: NSNotFound, length: 0)
      numberOfLines = 0
      
      while index < numberOfGlyphs {
        lManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
        index = NSMaxRange(lineRange)
        numberOfLines += 1
      }
    }
    
    return numberOfLines
  }
  
  // MARK: - Cursor
  
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

extension NSTextView {
  func fitTextToBounds() {
    guard let text = textStorage?.string else { return }

    let font = self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
    self.font = NSFont.fontFittingText(text,
                                       in: textBoundingBox.size,
                                       fontDescriptor: font.fontDescriptor)
  }

  private var textBoundingBox: CGRect {
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

extension NSFont {
  static func smallestFont(with fontDescriptor: NSFontDescriptor) -> NSFont? {
    NSFont(descriptor: fontDescriptor, size: CGFloat(1))
  }
  
  var lineHeight: CGFloat {
    CGFloat(ceilf(Float(ascender + abs(descender) + leading)))
  }

  static func fontFittingText(_ text: String,
                              in bounds: CGSize,
                              fontDescriptor: NSFontDescriptor) -> NSFont? {

    let properBounds = CGRect(origin: .zero, size: bounds)
    let largestFontSize = Int(bounds.height)
    let constrainingBounds = CGSize(width: properBounds.width, height: CGFloat.infinity)
    
    guard largestFontSize > 0 else { return NSFont.smallestFont(with: fontDescriptor) }

    let bestFittingFontSize: Int? = (1...largestFontSize).reversed().first(where: { fontSize in

      let font = NSFont(descriptor: fontDescriptor, size: CGFloat(fontSize))
      let currentFrame = text.boundingRect(
        with: constrainingBounds,
        options: [.usesLineFragmentOrigin, .usesFontLeading],
        attributes: [.font: font as Any],
        context: nil
      )

      if properBounds.contains(currentFrame) {
        return true
      }

      return false
    })

    guard let fontSize = bestFittingFontSize else {
      return NSFont.smallestFont(with: fontDescriptor)
    }

    return NSFont(descriptor: fontDescriptor, size: CGFloat(fontSize))
  }
}
