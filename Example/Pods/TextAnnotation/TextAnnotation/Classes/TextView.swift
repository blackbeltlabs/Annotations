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
                               attributes: [NSAttributedString.Key.font : getFont()])
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
