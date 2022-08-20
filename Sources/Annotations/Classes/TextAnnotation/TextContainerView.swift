import Cocoa

enum ResizeType {
  case rightToLeft
  case leftToRight
}

enum TextAnnotationTransformState {
  case move
  case resize(type: ResizeType)
  case scale
}

public enum TextAnnotationEditingState {
  case inactive
  case active
  case editing
}

public typealias TextAnnotationState = TextAnnotationEditingState

public struct DecoratorStyleParams {
  public let selectionLineWidth: CGFloat
  public let knobSide: CGFloat
  public let scaleKnobSide: CGFloat
  
  static var defaultParams = DecoratorStyleParams(selectionLineWidth: 4.0,
                                                  knobSide: 11.0,
                                                  scaleKnobSide: 12.0)
}

public protocol ActivateResponder: AnyObject {
  func textViewDidActivate(_ activeItem: Any?)
}

public class TextContainerView: NSView, TextAnnotation {
  
  // MARK: - Experimental settings
  static var experimentalSettings: Bool = false
  
  // MARK: - Dependencies
  public weak var delegate: TextAnnotationDelegate?
  public weak var textUpdateDelegate: TextAnnotationUpdateDelegate?
  weak var activateResponder: ActivateResponder?
 
  // MARK: - Helpers and handlers
  private let mouseEventsHandler = MouseEventsHandler()
  private let textFrameTransformer = TextFrameTransformer()
  private let historyTrackingHelper = HistoryTrackingHelper()

  // MARK: - Properties
  
  // textView inset inside text container view
  let inset = CGVector(dx: 15.0, dy: 50.0)
  
  // selection view inset to textView
  let selectionViewInset = CGVector(dx: -5.0, dy: -10.0)
  
  // Decorating params (for the active state when SelectionView and knobs are visible)
  let decParams = DecoratorStyleParams.defaultParams
  
  // set flipped layout for subviews to simplify work with text view resizing
  public override var isFlipped: Bool { true }
  
  let renderInLayout: Bool
    
//  // layout all subviews on frame update
  public override var frame: NSRect {
    didSet {
      if !renderInLayout {
        setupFrames(with: frame)
      }
    }
  }
  
  public override func layout() {
    super.layout()
    if renderInLayout {
      setupFrames(with: frame)
    }
  }
  
  private func setupFrames(with frame: NSRect) {
      guard frame.height > 0 else { return }
       
      // layout text view
      textView.frame = bounds.insetBy(dx: inset.dx, dy: inset.dy)
      legibilityTextView.frame = textView.frame
      legibilityTextView.frame.size.height += legibilityTextView.additionalHeight
      
      // layout selectionView frame
      selectionView.frame = textView.frame.insetBy(dx: selectionViewInset.dx,
                                                   dy: selectionViewInset.dy)
      
      let knobSide: CGFloat = decParams.knobSide
      let lineWidth: CGFloat = decParams.selectionLineWidth
      let scaleKnobSide: CGFloat = decParams.scaleKnobSide
      
      // layout left knob view
      let y = selectionView.frame.origin.y + selectionView.frame.size.height / 2.0 - knobSide / 2.0
      let x = selectionView.frame.origin.x - knobSide / 2.0 + lineWidth / 4.0
      leftKnobView.frame = CGRect(x: x, y: y, width: knobSide, height: knobSide)
      
      // layout right knob view
      let y1 = y
      let x1 = frame.width - selectionView.frame.origin.x - knobSide / 2.0 - lineWidth / 4.0
      rightKnobView.frame = CGRect(x: x1, y: y1, width: knobSide, height: knobSide)
      
      // layout scale knob view
      let x2 = selectionView.frame.origin.x + selectionView.frame.size.width / 2.0 - scaleKnobSide / 2.0
      let y2 = frame.height - selectionView.frame.origin.y - scaleKnobSide / 2.0  - lineWidth / 4.0
      scaleKnobView.frame = CGRect(x: x2, y: y2, width: scaleKnobSide, height: scaleKnobSide)
      
      // layout legibility button view
      legibilityButton.frame = CGRect(x: selectionView.frame.origin.x,
                                      y: selectionView.frame.origin.y + selectionView.frame.size.height + 4.0,
                                      width: 23.0,
                                      height: 23.0)
      
      
      let emojiButtonOriginX = legibilityButton.frame.origin.x + legibilityButton.frame.size.width + 5.0
      emojiButton.frame = CGRect(x: emojiButtonOriginX,
                                 y: legibilityButton.frame.origin.y,
                                 width: 23.0,
                                 height: 23.0)
  }
  
  // MARK: - Tracking area
  
  var trackingArea: NSTrackingArea?

  // MARK: - Text view params
  public var text: String {
    set {
      textView.string = newValue
      legibilityTextView.string = newValue
      // calculate new frame on text updates and update text view and other views frames
      textFrameTransformer.updateSize(for: newValue)
    }
    get {
      textView.string
    }
  }
  
  public var textColor: ModelColor {
    set {
      let nsColor = NSColor.color(from: newValue)
      var currentTypingAttributes = textView.typingAttributes
      currentTypingAttributes[.foregroundColor] = nsColor
      textView.updateTypingAttributes(currentTypingAttributes)
      textView.insertionPointColor = nsColor
      textView.needsDisplay = true
      notifyAboutTextAnnotationUpdates()
    }
    get {
      guard let textViewNsColor = textView.textColor else {
        return ModelColor.defaultColor()
      }
      return textViewNsColor.annotationModelColor
    }
  }
  
  var font: NSFont? {
    set {
      textView.font = newValue
      legibilityTextView.font = newValue
    }
    get {
      textView.font
    }
  }
  
  
  // MARK: - Views
  
  lazy var textView: TextView = {
    let textView = TextView(frame: .zero)
    textView.translatesAutoresizingMaskIntoConstraints = false
    return textView
  }()
  
  private lazy var legibilityTextView: LegibilityTextView = {
    let textView = LegibilityTextView(frame: .zero)
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.isEditable = false
    textView.isSelectable = false
    return textView
  }()
  
  private lazy var legibilityButton: LegibilityButton = {
    let button = LegibilityButton(frame: .zero)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.target = self
    button.action = #selector(legibilityButtonPressed)
    return button
  }()
  
  private lazy var emojiButton: EmojiButton = {
    let button = EmojiButton(frame: .zero)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.target = self
    button.action = #selector(emojiButtonPressed)
    button.isHidden = true
    return button
  }()
  
  lazy var selectionView: SelectionView = {
    let selectionView = SelectionView(strokeColor: #colorLiteral(red: 0.6941176471, green: 0.6941176471, blue: 0.6941176471, alpha: 1),
                                      lineWidth: decParams.selectionLineWidth)
    selectionView.translatesAutoresizingMaskIntoConstraints = false
    return selectionView
  }()
  
  let leftKnobView = TextKnobView(strokeColor: #colorLiteral(red: 0.6941176471, green: 0.6941176471, blue: 0.6941176471, alpha: 1), fillColor: #colorLiteral(red: 1, green: 0.3803921569, blue: 0, alpha: 1))
  let rightKnobView = TextKnobView(strokeColor: #colorLiteral(red: 0.6941176471, green: 0.6941176471, blue: 0.6941176471, alpha: 1), fillColor: #colorLiteral(red: 1, green: 0.3803921569, blue: 0, alpha: 1))
  let scaleKnobView = TextKnobView(strokeColor: .white, fillColor: #colorLiteral(red: 1, green: 0.3803921569, blue: 0, alpha: 1))
  
  private var decoratorViews: [NSView] = []
  
  // MARK: - Gesture recognizers
  private var singleClickGestureRecognizer: NSClickGestureRecognizer!
  private var doubleClickGestureRecognizer: NSClickGestureRecognizer!
  
  // MARK: - States
  public var state: TextAnnotationState = .inactive {
    didSet {
      updateParts(with: self.state, oldValue: oldValue)
    }
  }
  
  var transformState: TextAnnotationTransformState?
  
  var legibilityEffectEnabled: Bool = false {
    didSet {
      self.updateLegibilityButton(with: self.legibilityEffectEnabled)
    }
  }
  
  var emojiesPickerPresented = false {
    didSet {
      self.delegate?.emojiPickerPresentationStateChanged(self.emojiesPickerPresented)
    }
  }
  
  static let textViewsLineFragmentPadding: CGFloat = 10.0
  
  // MARK: - Properties
  var enableEmojies: Bool = true
  var debugMode: Bool = false
  
  var windowDidBecomeKeyListener: AnyObject?
  
  // MARK: - Init
  override init(frame frameRect: NSRect) {
    if #available(macOS 13.0, *) {
      renderInLayout = true
    } else {
      renderInLayout = false
    }
    super.init(frame: frameRect)
    performSubfieldsInit(frameRect: frameRect,
                         textParams: TextParams.defaultFont(),
                         enableEmojies: true)
  }
  
  public init(frame frameRect: NSRect,
              text: String,
              textParams: TextParams,
              legibilityEffectEnabled: Bool,
              enableEmojies: Bool) {
    if #available(macOS 13.0, *) {
      renderInLayout = true
    } else {
      renderInLayout = false
    }
    super.init(frame: frameRect)

    
    performSubfieldsInit(frameRect: frameRect,
                         textParams: textParams,
                         enableEmojies: enableEmojies)
    self.text = text
    
    self.legibilityEffectEnabled = legibilityEffectEnabled
    // didSet is called in initializer so need to call this method directly
    self.updateLegibilityButton(with: legibilityEffectEnabled)
  }
  
  convenience init(modelable: TextAnnotationModelable, enableEmojies: Bool) {
    self.init(frame: modelable.frame,
              text: modelable.text,
              textParams: modelable.style,
              legibilityEffectEnabled: modelable.legibilityEffectEnabled,
              enableEmojies: enableEmojies)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Initial setup
  func performSubfieldsInit(frameRect: CGRect, textParams: TextParams, enableEmojies: Bool) {
    wantsLayer = true
    if debugMode {
      layer?.borderColor = NSColor.black.cgColor
      layer?.borderWidth = 1.0
    }
    
    addSubview(legibilityTextView)
    addSubview(textView)
    
    setupTextView(textView)
    setupTextView(legibilityTextView)
    
    // add shadow to legibility text view for better contrast
    legibilityTextView.wantsLayer = true
    legibilityTextView.layer?.applySketchShadow(color: NSColor.black.withAlphaComponent(0.5),
                                                alpha: 1.0,
                                                xOffset: 0,
                                                yOffset: 2.0,
                                                blur: 4.0,
                                                spread: 0)
    // attributes
    let textAttributes = textParams.attributes
    
    if let color = textAttributes[.foregroundColor] as? NSColor {
      textView.insertionPointColor = color
    }
        
    textView.updateTypingAttributes(textAttributes)
    
    // only font needs to be set for legibility view
    if let font = textAttributes[.font] as? NSFont {
      legibilityTextView.font = font
    }
    
    addSubview(selectionView)
    leftKnobView.translatesAutoresizingMaskIntoConstraints = false
    rightKnobView.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(leftKnobView)
    addSubview(rightKnobView)
    addSubview(scaleKnobView)
    
    addSubview(legibilityButton)
    addSubview(emojiButton)

    self.updateLegibilityButton(with: self.legibilityEffectEnabled)

    setupGestureRecognizers()

    mouseEventsHandler.textContainerView = self
    textFrameTransformer.textContainerView = self
    
    decoratorViews = [selectionView, leftKnobView, rightKnobView, scaleKnobView, legibilityButton]
    
    if debugMode {
      [leftKnobView, rightKnobView, scaleKnobView].forEach { (knobView) in
        knobView.wantsLayer = true
        knobView.layer?.borderWidth = 1.0
        knobView.layer?.borderColor = NSColor.blue.cgColor
      }
    }
    
    updateParts(with: .inactive, oldValue: nil)
    
    textView.delegate = self
    
    textView.textContainer?.lineFragmentPadding = Self.textViewsLineFragmentPadding
    legibilityTextView.textContainer?.lineFragmentPadding = Self.textViewsLineFragmentPadding
    
    self.enableEmojies = enableEmojies
  }
  
  func setupTextView(_ textView: NSTextView) {
    textView.translatesAutoresizingMaskIntoConstraints = false
                                         
    textView.alignment = .natural
    textView.backgroundColor = NSColor.clear
    textView.isRichText = false
    textView.usesRuler = false
    textView.usesFontPanel = false
    textView.drawsBackground = false
    textView.isVerticallyResizable = true
    
    if debugMode {
      textView.wantsLayer = true
      if textView == self.textView {
        textView.layer?.borderColor = NSColor.green.cgColor
      } else {
        textView.layer?.borderColor = NSColor.orange.cgColor
      }
      textView.layer?.borderWidth = 1.0
    }
  }

  func setupGestureRecognizers() {
    singleClickGestureRecognizer = NSClickGestureRecognizer(target: self,
                                                            action: #selector(self.singleClickGestureHandle(_:)))
    self.addGestureRecognizer(singleClickGestureRecognizer)
    
    doubleClickGestureRecognizer = NSClickGestureRecognizer(target: self,
                                                            action: #selector(self.doubleClickGestureHandle(_:)))
    doubleClickGestureRecognizer.numberOfClicksRequired = 2
    doubleClickGestureRecognizer.numberOfTouchesRequired = 2
    self.addGestureRecognizer(doubleClickGestureRecognizer)
    
    singleClickGestureRecognizer.delegate = self
    doubleClickGestureRecognizer.delegate = self
  }
  
  // MARK: - Hit test
  public override func hitTest(_ point: NSPoint) -> NSView? {
    let convertedPoint = convert(point, from: superview)

    if state == .inactive {
      return textView.frame.contains(convertedPoint) ? super.hitTest(point) : nil
    } else {
      return super.hitTest(point)
    }
  }
  
  // MARK: - State changes

  func updateParts(with editingState: TextAnnotationEditingState,
                   oldValue: TextAnnotationEditingState?) {
    
    emojiesPickerPresented = false

    guard editingState != oldValue else { return }
    
    if oldValue == .editing {
      
      if historyTrackingHelper.textSnapshot != text, text != "" {
        notifyAboutTextAnnotationUpdates()
      }
      
      delegate?.textAnnotationDidEndEditing(textAnnotation: self)
    }
    
    if editingState != .inactive {
      activateResponder?.textViewDidActivate(self)
    }
    
    doubleClickGestureRecognizer.isEnabled = editingState != .editing
    
    switch editingState {
    case .inactive:
      (textView.isEditable, textView.isSelectable) = (false, false)
      decoratorViews.forEach { $0.isHidden = true  }
      
      delegate?.textAnnotationDidDeselect(textAnnotation: self)
      emojiButton.isHidden = true
    case .active:
      (textView.isEditable, textView.isSelectable) = (false, false)
      decoratorViews.forEach { $0.isHidden = false }
      delegate?.textAnnotationDidSelect(textAnnotation: self)
      emojiButton.isHidden = true
    case .editing:
      (textView.isEditable, textView.isSelectable) = (true, true)
      textView.window?.makeFirstResponder(textView)
      
      historyTrackingHelper.makeTextSnapshot(text: text)
      delegate?.textAnnotationDidStartEditing(textAnnotation: self)
      if enableEmojies {
        emojiButton.isHidden = false
      }
    }
    
    singleClickGestureRecognizer.isEnabled = editingState == .inactive
  }
    
  // MARK: - Transform
  
  // just redirect events to text frame transformer here
  func resize(distance: CGFloat, type: ResizeType) {
    textFrameTransformer.resize(distance: distance, type: type)
  }
  
  func scale(distance: CGFloat) {
    textFrameTransformer.scale(distance: distance)
  }
  
  
  func move(difference: CGSize) {
    textFrameTransformer.move(difference: difference)
  }
  
  // MARK: - Frame updates
  func reduceWidthIfNeeded() {
    textFrameTransformer.reduceWidthIfNeeded()
  }
  
  func reduceHeightIfNeeded() {
    textFrameTransformer.reduceHeightIfNeeded()
  }
  
  // MARK: - Mouse events
  
  // add tracking area to be able to update cursors depending on view
  public override func updateTrackingAreas() {
    super.updateTrackingAreas()
    if let trackingArea = trackingArea {
      removeTrackingArea(trackingArea)
      self.trackingArea = nil
    }
    let options: NSTrackingArea.Options = [.activeAlways,
                                           .mouseEnteredAndExited,
                                           .mouseMoved]
    
    let trackingArea = NSTrackingArea(rect: bounds,
                                      options: options,
                                      owner: self,
                                      userInfo: nil)
    addTrackingArea(trackingArea)
    
    self.trackingArea = trackingArea
  }
  
  // need override this method for correct cursor work
  public override func resetCursorRects() {
    super.resetCursorRects()
    mouseEventsHandler.cursorRectsReseted()
  }
  
  open override func mouseDown(with event: NSEvent) {
    mouseEventsHandler.mouseDown(with: event)
  }
  
  open override func mouseDragged(with event: NSEvent) {
    mouseEventsHandler.mouseDragged(with: event)
    self.window?.invalidateCursorRects(for: self)
  }
  
  public override func mouseUp(with event: NSEvent) {
    mouseEventsHandler.mouseUp(with: event)
  }
  
  public override func mouseMoved(with event: NSEvent) {
    mouseEventsHandler.mouseMoved(with: event)
  }
  
  public override func mouseExited(with event: NSEvent) {
    mouseEventsHandler.mouseExited(with: event)
  }
  
  // MARK: - Gestures handlers
  @objc private func singleClickGestureHandle(_ gesture: NSClickGestureRecognizer) {
    state = .active
  }
  
  @objc private func doubleClickGestureHandle(_ gesture: NSClickGestureRecognizer) {
    state = .editing
  }
  
  // MARK: - History
  
  // by calling this method the current state of text annotation
  // will be added to history in the delegate
  func notifyAboutTextAnnotationUpdates() {
    let action = TextAnnotationAction(text: text,
                                      frame: frame,
                                      style: TextParams.textParams(from: textView.typingAttributes),
                                      legibilityEffectEnabled: legibilityEffectEnabled)
    
    textUpdateDelegate?.textAnnotationUpdated(textAnnotation: self,
                                              modelable: action)
  }
  
  // MARK: - Actions
  @objc
  func legibilityButtonPressed() {
    legibilityEffectEnabled.toggle()
  }
  
  func updateLegibilityButton(with legibilityEffectEnabled: Bool) {
    legibilityButton.updateImage(with: legibilityEffectEnabled ? .enabled : .disabled)
    legibilityTextView.isHidden = !legibilityEffectEnabled
    notifyAboutTextAnnotationUpdates()
  }
  
  
  @objc func emojiButtonPressed() {
    emojiesPickerPresented = true
    
    NSApp.orderFrontCharacterPalette(textView)
    
    if let notif = self.windowDidBecomeKeyListener {
      NotificationCenter.default.removeObserver(notif)
    }
    
    guard let window = textView.window else { return }
    
    windowDidBecomeKeyListener = NotificationCenter.default.addObserver(forName: NSWindow.didBecomeKeyNotification,
                                                                        object: window,
                                                                        queue: .main) { [weak self] (_) in
      guard let self = self else { return }
      self.emojiesPickerPresented = false
    }
  }
  
  @objc func textViewWindowBecomesActive(_ notification: Notification) {
    print("Window becomes active")
  }
  
  // MARK: - Other
  public func updateColor(with color: NSColor) {
    textColor = color.annotationModelColor
  }
  
  public func startEditing() {
    state = .editing
  }
  
  public func updateFrame(with modelable: TextAnnotationModelable) {
    textView.updateTypingAttributes(modelable.style.attributes)
    
    text = modelable.text
    
    if modelable.frame.size.width != 0 && modelable.frame.size.height != 0 {
      self.frame = modelable.frame
    }
  }
  
}

// MARK: - NSTextViewDelegate
extension TextContainerView: NSTextViewDelegate {
  public func textDidChange(_ notification: Notification) {
    guard let textView = notification.object as? NSTextView else { return }
   
    textFrameTransformer.updateSize(for: textView.string)
    
    delegate?.textAnnotationDidEdit(textAnnotation: self)
    
    legibilityTextView.string = textView.string
  }
}

// MARK: - NSGestureRecognizerDelegate {
extension TextContainerView: NSGestureRecognizerDelegate {
  public func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
    
    // need to allow to recognize only if mouse location is inside text view
    // otherwise gesture recognizer has a conflict with legibilityButton and other controls
    let location = convert(event.locationInWindow, from: nil)
    
    if textView.frame.contains(location) {
      return true
    } else {
      return false
    }
  }
}
