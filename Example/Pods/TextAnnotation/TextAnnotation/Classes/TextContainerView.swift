import Cocoa

public enum TextAnnotationState {
  case inactive
  case active
  case editing
  case resizeRight
  case resizeLeft
  case dragging
  case scaling
}

public protocol ActivateResponder: class {
  func textViewDidActivate(_ activeItem: Any?)
}

open class TextContainerView: NSView {
  public var delegate: TextAnnotationDelegate?
  public var textUpdateDelegate: TextAnnotationUpdateDelegate?
  
  public var state: TextAnnotationState = .inactive {
    didSet {
      guard state != oldValue, let theTextView = textView else { return }
      
      var isActive: Bool = false
      
      if state == .editing {
        textSnapshot = text
        delegate?.textAnnotationDidStartEditing(textAnnotation: self)
      }
      
      if oldValue == .editing {
				if textSnapshot != text, text != "" {
          notifyAboutTextAnnotationUpdates()
				}
				
        delegate?.textAnnotationDidEndEditing(textAnnotation: self)
      }
      
      if state == .inactive {
        let selected = theTextView.selectedRange().upperBound
        let range = NSRange(location: selected == 0 ? theTextView.string.count : selected, length: 0)
        
        theTextView.setSelectedRange(range)
        theTextView.isEditable = false
        doubleClickGestureRecognizer.isEnabled = !theTextView.isEditable
        
        delegate?.textAnnotationDidDeselect(textAnnotation: self)
        theTextView.window?.resignFirstResponder()
      } else {
        if state == .scaling {
          theTextView.calculateScaleRatio()
        }
        
        isActive = true
        
        if let responder = activateResponder {
          responder.textViewDidActivate(self)
        }
      }
      
      singleClickGestureRecognizer.isEnabled = state == .inactive
      
      theTextView.isSelectable = isActive
      
      backgroundView.isHidden = !isActive
      backgroundView.display()
      
      if let tally = leftTally {
        tally.isHidden = !isActive
      }

      if let tally = rightTally {
        tally.isHidden = !isActive
      }

      if let tally = scaleTally {
        tally.isHidden = !isActive
        tally.display()
      }
    }
  }
  
  weak var activateResponder: ActivateResponder?
  weak var activeAreaResponder: MouseTrackingResponder?
  
  public var text: String {
    get {
      return textView.string
    }
    set {
      guard let theTextView = textView else { return }
      theTextView.string = newValue
      updateFrameWithText(theTextView.string)
      textSnapshot = newValue
    }
  }
  var leftTally: MouseTrackingView?
  var rightTally: MouseTrackingView?
  var scaleTally: KnobView?
 
  // MARK: Private
  
  private var backgroundView: SelectionView!
  private var textView: TextView!
  
  private let kMinimalWidth: CGFloat = 25 + 2*Configuration.frameMargin + 2*Configuration.dotRadius
  private let kMinimalHeight: CGFloat = 25
  
  private var singleClickGestureRecognizer: NSClickGestureRecognizer!
  private var doubleClickGestureRecognizer: NSClickGestureRecognizer!
  
  private var lastMouseLocation: NSPoint?
  private var lastMouseDownLocation: NSPoint?
  private var textSnapshot: String = ""
  
  private var didMove = false
  
  private var cursorSet = CursorSet.shared
  
  public var textColor: TextColor {
    set {
      textView.textColor = NSColor.color(from: newValue)
      notifyAboutTextAnnotationUpdates()
    }
    
    get {
      guard let textViewNsColor = textView.textColor else {
        return TextColor.defaultColor()
      }
      return textViewNsColor.textColor
    }
  }
  
  override open var frame: NSRect {
    didSet {
      updateSubviewsFrames(oldValue, frame: frame)
    }
  }
  
  // MARK: - Init
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    performSubfieldsInit(frameRect: frameRect, textColor: TextColor.defaultColor())
    self.text = ""
  }
  
  required public init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public init(frame frameRect: NSRect, text: String, color: TextColor) {
    super.init(frame: frameRect)
    performSubfieldsInit(frameRect: frameRect, textColor: color)
    self.text = text
  }

  init(modelable: TextAnnotationModelable) {
    super.init(frame: modelable.frame)
    performSubfieldsInit(frameRect: modelable.frame, textColor: modelable.color)
    updateFrame(with: modelable)
  }
  
  func performSubfieldsInit(frameRect: CGRect, textColor: TextColor) {
    let size = frameRect.size
    
    backgroundView = SelectionView(frame: NSRect(origin: CGPoint.zero, size: size))
    backgroundView.isHidden = true
    self.addSubview(backgroundView)
    
    textView = TextView(frame: NSRect.zero, responder: self)
    textView.alignment = .natural
    textView.backgroundColor = NSColor.clear
    textView.textColor = NSColor(red: textColor.red,
                                 green: textColor.green,
                                 blue: textColor.blue,
                                 alpha: textColor.alpha)
    textView.font = NSFont(name: "HelveticaNeue-Bold", size: 30)
    textView.isSelectable = false
    textView.isRichText = false
    textView.usesRuler = false
    textView.usesFontPanel = false
    textView.isEditable = false
    textView.isVerticallyResizable = false
    textView.delegate = self
    
    singleClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(self.singleClickGestureHandle(_:)))
    self.addGestureRecognizer(singleClickGestureRecognizer)
    
    doubleClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(self.doubleClickGestureHandle(_:)))
    doubleClickGestureRecognizer.numberOfClicksRequired = 2
    doubleClickGestureRecognizer.numberOfTouchesRequired = 2
    self.addGestureRecognizer(doubleClickGestureRecognizer)
    
    addSubview(textView)
    
    // all frames here is zero, later we set it in updateSubviewsFrames()
    let tallyFrame = NSRect.zero
    var flipper = MouseTrackingView(type: .resizeLeftArea, responder: self, frameRect: tallyFrame)
    flipper.isHidden = true
    addSubview(flipper)
    leftTally = flipper
    
    flipper = MouseTrackingView(type: .resizeRightArea, responder: self, frameRect: tallyFrame)
    flipper.isHidden = true
    addSubview(flipper)
    rightTally = flipper
    
    let tally = KnobView(type: .scaleArea, responder: self, frameRect: tallyFrame)
    tally.isHidden = true
    addSubview(tally)
    scaleTally = tally
  }
  
  // MARK: - Mouse actions
  
  open override func mouseDown(with event: NSEvent) {
    let mouseLocation = self.convert(event.locationInWindow, from: nil)
    state = mouseDownState(location: mouseLocation)
    
    lastMouseLocation = event.locationInWindow
    lastMouseDownLocation = event.locationInWindow
    textView.makeFontSnapshot()
  }
  
  open override func mouseDragged(with event: NSEvent) {
    guard let difference = getDifference(with: event,
                                         lastMouseLocation: lastMouseLocation) else {
                                          return
    }
    
    if difference.width > 0 || difference.height > 0 {
      didMove = true
    }
    
    self.lastMouseLocation = event.locationInWindow
    
    switch state {
    case .active:
      move(difference: difference)
    case .resizeLeft, .resizeRight:
      resize(distance: difference.width, state: state)
    case .scaling:
      scale(difference: difference, state: state)
      cursorSet.scaleCursor.set()
    default: return
    }
  }
  
  open override func mouseUp(with event: NSEvent) {
    addMouseUpEventToHistory(event: event,
                             state: state)
    state = .active
    
    if didMove {
      delegate?.textAnnotationDidMove(textAnnotation: self)
      didMove = false
    }
    
    lastMouseLocation = nil
    lastMouseDownLocation = nil
    textView.deleteFontSnapshot()
  }
  
  // MARK: - Gestures handlers
  
  @objc private func singleClickGestureHandle(_ gesture: NSClickGestureRecognizer) {
    guard let theTextView = textView, !theTextView.isEditable else { return }
    state = .active
    
    delegate?.textAnnotationDidSelect(textAnnotation: self)
  }
  
  @objc private func doubleClickGestureHandle(_ gesture: NSClickGestureRecognizer) {
    startEditing()
  }
  
  // MARK: - Frame updating
  
  private func updateFrameWithText(_ string: String) {
    guard let theTextView = textView else { return }
    let center = CGPoint(x: NSMidX(frame), y: NSMidY(frame))
    
    var textFrame = theTextView.frameForWidth(CGFloat.greatestFiniteMagnitude, height: theTextView.bounds.height)
    let width = max(textFrame.width + theTextView.twoSymbolsWidth, theTextView.bounds.width)
    
    // We should use minimal value to get height. Because of multiline.
    let minWidth = min(textFrame.width + theTextView.twoSymbolsWidth, textView.bounds.width)
    textFrame = theTextView.frameForWidth(minWidth, height: CGFloat.greatestFiniteMagnitude)
    let height = textFrame.height
    
    // Now we know text label frame. We should calculate new self.frame and redraw all the subviews
    textFrame = CGRect(x: frame.minX,
                       y: center.y - height/2.0 - (Configuration.frameMargin + Configuration.horizontalTextPadding),
                       width: width + 2*(Configuration.frameMargin + Configuration.dotRadius + Configuration.horizontalTextPadding),
                       height: height + 2*(Configuration.frameMargin + Configuration.horizontalTextPadding))
    
    frame = textFrame
  }
  
  private func updateSubviewsFrames(_ oldFrame: NSRect, frame: NSRect) {
    if oldFrame.width == frame.width && oldFrame.height == frame.height {
      return
    }
    
    let size = frame.size
    
    backgroundView.frame = CGRect(origin: CGPoint.zero, size: size)
    textView.frame = CGRect(x: Configuration.frameMargin + Configuration.dotRadius + Configuration.horizontalTextPadding, y: Configuration.frameMargin + Configuration.horizontalTextPadding, width: size.width - 2*(Configuration.frameMargin + Configuration.dotRadius + Configuration.horizontalTextPadding), height: size.height - 2 * (Configuration.frameMargin + Configuration.horizontalTextPadding))
    
    var tallyFrame = NSRect(origin: CGPoint.zero, size: CGSize(width: Configuration.frameMargin + 2*Configuration.dotRadius, height: size.height))
    if let tally = leftTally {
      tally.frame = tallyFrame
    }
    
    if let tally = rightTally {
      tallyFrame.origin = CGPoint(x: size.width - tallyFrame.width, y: tallyFrame.width)
      tallyFrame.size = CGSize(width: tallyFrame.width, height: tallyFrame.height - (2*Configuration.dotRadius + Configuration.frameMargin))
      tally.frame = tallyFrame
    }
    
    if let tally = scaleTally {
      tallyFrame.origin = CGPoint(x: size.width - (Configuration.frameMargin + 2*Configuration.dotRadius), y: Configuration.frameMargin)
      tallyFrame.size = CGSize(width: 2*Configuration.dotRadius, height: 2*Configuration.dotRadius)
      tally.frame = tallyFrame
    }
  }
  
  public func updateFrame(with action: TextAnnotationModelable) {
    self.textView.resetFontSize()

    self.text = action.text
    if action.frame.size.width != 0 && action.frame.size.height != 0 {
      self.frame = action.frame
    }
    
    
    if let fontName = action.fontName, let size = action.fontSize {
      self.textView.font = NSFont(name: fontName, size: size)
    }
  }
  
  // MARK: - Helpers
  
  private func addMouseUpEventToHistory(event: NSEvent, state: TextAnnotationState) {
    switch state {
    case .active, .resizeLeft, .resizeRight, .dragging, .scaling:
      notifyAboutTextAnnotationUpdates()
    default:
      break
    }
  }
	
	// MARK: - Undo / Redo helpers

  private func getDifference(with event: NSEvent,
                             lastMouseLocation: NSPoint?) -> CGSize? {
    guard let lastMouseLocation = lastMouseLocation else {
      return nil
    }

    let locationInWindow = event.locationInWindow
    return CGSize(width: locationInWindow.x - lastMouseLocation.x,
                  height: locationInWindow.y - lastMouseLocation.y)
  }
  
  // MARK: - State changes
  
  func move(difference: CGSize) {
    var newFrame = frame
    newFrame.origin = CGPoint(
      x: frame.origin.x + difference.width,
      y: frame.origin.y + difference.height
    )
    
    frame = newFrame
  }
  
  public func resize(distance: CGFloat, state: TextAnnotationState) {
    guard state == .resizeRight || state == .resizeLeft else { return }
    
    var theFrame = frame
    let delta = (state == .resizeRight ? 1 : -1) * distance
    var width = theFrame.width + delta
    width = width < kMinimalWidth ? kMinimalWidth : width
    theFrame.size = CGSize(width: width, height: theFrame.height)
    
    if state == .resizeLeft {
      // should move origin as well
      theFrame.origin = CGPoint(x: theFrame.origin.x + distance, y: theFrame.origin.y)
    }
    
    // Here we have to check if text view frame has good size for such container size
    let textFrame = textView.frameForWidth(theFrame.width - 2 * (Configuration.frameMargin + Configuration.dotRadius + Configuration.horizontalTextPadding),
                                           height: CGFloat.greatestFiniteMagnitude)
    let diff_width = theFrame.width - (textFrame.width + 2 * (Configuration.frameMargin + Configuration.dotRadius + Configuration.horizontalTextPadding) + textView.twoSymbolsWidth)
    if diff_width < 0 {
      let height = textFrame.height + 2 * (Configuration.frameMargin + Configuration.horizontalTextPadding)
      let centerY = theFrame.origin.y + theFrame.height/2
      
      theFrame.size = CGSize(width: theFrame.width, height: height)
      theFrame.origin = CGPoint(x: theFrame.origin.x, y: centerY - height/2)
    }
    
    frame = theFrame
  }
  
  public func scale(difference: CGSize, state: TextAnnotationState) {
    guard state == .scaling else { return }
    
    // we should scale it proportionally, driver of the mpvement is height difference
    var height = frame.height - difference.height
    var width = frame.width/frame.height * height
    
    width = width < kMinimalWidth ? kMinimalWidth : width
    height = height < kMinimalHeight ? kMinimalHeight : height
    
    frame = CGRect(origin: CGPoint(x: frame.origin.x, y: frame.origin.y + difference.height),
                   size: CGSize(width: width, height: height))
    textView.resetFontSize()    
  }
  
  public func mouseDownState(location: NSPoint) -> TextAnnotationState {
    var state = TextAnnotationState.active // default state
    if let tally = leftTally, tally.frame.contains(location) {
      state = .resizeLeft
    } else if let tally = rightTally, tally.frame.contains(location) {
      state = .resizeRight
    } else if let tally = scaleTally, tally.frame.contains(location) {
      state = .scaling
    }
    
    return state
  }
  
  private func notifyAboutTextAnnotationUpdates() {
    let font = textView.getFont()
    let action = TextAnnotationAction(text: text,
                                      frame: frame,
                                      fontName: font.fontName,
                                      fontSize: font.pointSize,
                                      color: textColor)
    textUpdateDelegate?.textAnnotationUpdated(textAnnotation: self,
                                              modelable: action)
  }
  
  public func updateColor(with color: NSColor) {
    textColor = color.textColor
  }
}

extension TextContainerView: NSTextViewDelegate {
  open func textDidChange(_ notification: Notification) {
    updateFrameWithText(textView.string)
    delegate?.textAnnotationDidEdit(textAnnotation: self)
  }
}

extension TextContainerView: ActivateResponder {
  public func textViewDidActivate(_ activeItem: Any?) {
    // After we reach the .editing state - we should not switch it back to .active, only on .inactive on complete edit
    state = textView.isEditable ? .editing : .active
  }
}

extension TextContainerView: MouseTrackingResponder {
  public func areaDidActivated(_ area: TextAnnotationArea) {
    guard let areaResponder = activeAreaResponder, state == .active else { return }
    areaResponder.areaDidActivated(area)
  }
}

// Extension should be here bacause `var textView: TextView` is private property
extension TextContainerView: TextAnnotation {
  public func startEditing() {
    state = .editing
    
    doubleClickGestureRecognizer.isEnabled = !textView.isEditable
    
    guard let responder = activateResponder else { return }
    responder.textViewDidActivate(self)
    
    textView.isEditable = true
    textView.isSelectable = true
    textView.window?.makeFirstResponder(textView)
  }
}
