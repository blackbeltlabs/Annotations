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
    let temp = frame.height/CGFloat(numberOfLines())
    fontSizeToSizeRatio = fontSize / temp
  }
  
  func resetFontSize() {
    if fontSizeToSizeRatio == nil {
      calculateScaleRatio()
    }
    
    let temp = frame.height/CGFloat(numberOfLines())
    let size = fontSizeToSizeRatio * temp
    
    let ratio = size/getFont().pointSize
    if !(1.0...1.1 ~= ratio) {
      font = NSFont(name: getFont().fontName, size: size)
    }
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

