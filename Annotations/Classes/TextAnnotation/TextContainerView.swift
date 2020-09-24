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
  
  static var defaultParams = DecoratorStyleParams(selectionLineWidth: 3.0,
                                                  knobSide: 11.0)
}

public protocol ActivateResponder: class {
  func textViewDidActivate(_ activeItem: Any?)
}

public class TextContainerView: NSView {
  
  public override var isFlipped: Bool { true }
  
  // MARK: - Dependencies
  
  public var delegate: TextAnnotationDelegate?
  public var textUpdateDelegate: TextAnnotationUpdateDelegate?
  
  weak var activateResponder: ActivateResponder?
    
  
  var textAttributes: [NSAttributedString.Key: Any] = [.font: NSFont(name: "HelveticaNeue-Bold", size: 30)!]
  
  
  let inset = CGVector(dx: 15.0, dy: 25.0)
  
  let stringSizeHelper = StringSizeHelper()
  let fontSizeHelper = FontSizeHelper()
  
  let decParams = DecoratorStyleParams.defaultParams
  
  var mouseEventsHandler: MouseEventsHandler!
  
  let historyTrackingHelper = HistoryTrackingHelper()
  
  public override var frame: NSRect {
    didSet {
      print(self.frame)
      guard frame.height > 0 else { return }
      textView.frame = bounds.insetBy(dx: inset.dx, dy: inset.dy)
      selectionView.frame = bounds.insetBy(dx: inset.dx / 2.0,
                                           dy: inset.dy / 2.0)

      let knobSide: CGFloat = decParams.knobSide
      let lineWidth: CGFloat = decParams.selectionLineWidth
      
      let y = selectionView.frame.size.height / 2.0 + knobSide / 2.0
      let x = ceil(selectionView.frame.origin.x - knobSide / 2.0)
      leftKnobView.frame = CGRect(x: x, y: y, width: knobSide, height: knobSide)
      
      
      let y1 = ceil(selectionView.frame.size.height / 2.0 + knobSide / 2.0)
      let x1 = ceil(selectionView.frame.size.width)
      
      rightKnobView.frame = CGRect(x: x1, y: y1, width: knobSide, height: knobSide)
      
      
      let x2 = selectionView.frame.size.width / 2
      let y2 = selectionView.frame.size.height + (knobSide + lineWidth) / 2.0
      
      scaleKnobView.frame = CGRect(x: x2, y: y2, width: knobSide, height: knobSide)
    }
  }

  public var text: String {
    set {
      textView.string = newValue
      let size = stringSizeHelper.bestSizeWithAttributes(for: newValue,
                                                         attributes: textView.typingAttributes)
      updateTextViewSize(size: size)
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
  
  var font: NSFont {
    textView.font!
  }
  
  // MARK: - Views
  
  lazy var textView: TextView = {
    let textView = TextView(frame: .zero)
    textView.translatesAutoresizingMaskIntoConstraints = false
    return textView
  }()
  
  lazy var selectionView: SelectionView = {
    let selectionView = SelectionView(strokeColor: #colorLiteral(red: 0.6941176471, green: 0.6941176471, blue: 0.6941176471, alpha: 1),
                                      lineWidth: decParams.selectionLineWidth)
    selectionView.translatesAutoresizingMaskIntoConstraints = false
    return selectionView
  }()
  
  let leftKnobView = TextKnobView(strokeColor: .white, fillColor: #colorLiteral(red: 1, green: 0.3803921569, blue: 0, alpha: 1))
  let rightKnobView = TextKnobView(strokeColor: .white, fillColor: #colorLiteral(red: 1, green: 0.3803921569, blue: 0, alpha: 1))
  let scaleKnobView = TextKnobView(strokeColor: .white, fillColor: #colorLiteral(red: 1, green: 0.3803921569, blue: 0, alpha: 1))
  
  
  private var decoratorViews: [NSView] = []
  
  // MARK: - Gesture recognizers
  
  private var singleClickGestureRecognizer: NSClickGestureRecognizer!
  private var doubleClickGestureRecognizer: NSClickGestureRecognizer!
  
  // MARK: - States
  
  var editingState: TextAnnotationEditingState = .inactive {
    didSet {
      updateParts(with: self.editingState, oldValue: oldValue)
    }
  }
  
  public var state: TextAnnotationState {
    get {
      editingState
    }
    set {
      self.editingState = newValue
    }
  }
  
  var transformState: TextAnnotationTransformState?
  
  // MARK: - Init
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    performSubfieldsInit(frameRect: frameRect, textParams: TextParams.defaultFont())
  }
  
  public init(frame frameRect: NSRect, text: String, textParams: TextParams) {
    super.init(frame: frameRect)
    performSubfieldsInit(frameRect: frameRect, textParams: textParams)
    
    // FIXME: - Without it get infinity error here. Need to fix later
//    DispatchQueue.main.async {
      self.text = text
   // }
  }
  
  convenience init(modelable: TextAnnotationModelable) {
    self.init(frame: modelable.frame,
              text: modelable.text,
              textParams: modelable.style)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Initial setup
  func performSubfieldsInit(frameRect: CGRect, textParams: TextParams) {
    
    wantsLayer = true
    layer?.borderColor = NSColor.black.cgColor
    layer?.borderWidth = 1.0
    
    addSubview(textView)
    
    textView.translatesAutoresizingMaskIntoConstraints = false
    
    textView.typingAttributes = textAttributes
                                     
    textView.alignment = .natural
    textView.backgroundColor = NSColor.clear
    textView.isRichText = false
    textView.usesRuler = false
    textView.usesFontPanel = false
    textView.drawsBackground = false
    textView.isVerticallyResizable = true
 
    
    textView.wantsLayer = true
    textView.layer?.borderColor = NSColor.green.cgColor
    textView.layer?.borderWidth = 1.0
    
    // attributesx
    let textAttributes = textParams.attributes
    
    if let color = textAttributes[.foregroundColor] as? NSColor {
      textView.insertionPointColor = color
    }
        
    textView.updateTypingAttributes(textAttributes)
    
    
    addSubview(selectionView)
    leftKnobView.translatesAutoresizingMaskIntoConstraints = false
    rightKnobView.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(leftKnobView)
    addSubview(rightKnobView)
    addSubview(scaleKnobView)
    
    setupGestureRecognizers()

    mouseEventsHandler = MouseEventsHandler()
    mouseEventsHandler.textContainerView = self
    
    decoratorViews = [selectionView, leftKnobView, rightKnobView, scaleKnobView]
    
    updateParts(with: .inactive, oldValue: nil)
    
    textView.delegate = self
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
  }
  
  
  // all updates of text view size should be done through this method
  
  // MARK: UI updates
  func updateTextViewSize(size: CGSize) {
    self.frame.size.width = size.width + inset.dx * 2
    self.frame.size.height = size.height + inset.dy * 2
  }
  
  func updateParts(with editingState: TextAnnotationEditingState,
                   oldValue: TextAnnotationEditingState?) {
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
    case .active:
      (textView.isEditable, textView.isSelectable) = (false, false)
      decoratorViews.forEach { $0.isHidden = false }
    case .editing:
      (textView.isEditable, textView.isSelectable) = (true, true)
      textView.window?.makeFirstResponder(textView)
      
      historyTrackingHelper.makeTextSnapshot(text: text)
      delegate?.textAnnotationDidStartEditing(textAnnotation: self)
    }
    
    singleClickGestureRecognizer.isEnabled = editingState == .inactive
  }
    
  // MARK: - Transform
  
  func resize(distance: CGFloat, type: ResizeType) {
    let offset: CGFloat = type == .rightToLeft ? distance * -1.0 : distance
    
    let width = textView.frame.size.width - offset

    if width < 50.0 {
      return
    }

    if type == .leftToRight {
      self.frame.origin.x += offset
    }
    
    let height = stringSizeHelper.getHeightAttr(for: textView.attributedString(),
                                                width: width - textView.textContainer!.lineFragmentPadding * 2.0)
    updateTextViewSize(size: CGSize(width: width,
                                    height: height))
  }
  
  func scale(distance: CGFloat) {
    let height = textView.frame.size.height - distance
    
    if height < 10.0 {
      return
    }
    
    let width = textView.frame.size.width
    
    updateTextViewSize(size: CGSize(width: width,
                                    height: height))
    
    let font = fontSizeHelper.fontFittingText(textView.string,
                                              in: textView.textBoundingBox.size,
                                              fontDescriptor: textView.font!.fontDescriptor)
    textView.font = font
  }
  
  
  func move(difference: CGSize) {
    frame.origin.x += difference.width
    
    // need minus here because the current view is flipped whereas the position from window is Mac OS native
    frame.origin.y -= difference.height
  }
  
  
  // MARK: - Frame updates

  func reduceWidthIfNeeded() {
    var newWidth = stringSizeHelper.getWidthAttr(for: textView.attributedString(),
                                                 height: textView.frame.size.height)
    
    newWidth += textView.textContainer!.lineFragmentPadding * 2.0
    
    // text view width need to be reduced only if a new width is less than the current one
    if newWidth < textView.frame.size.width {
      updateTextViewSize(size: CGSize(width: newWidth,
                                      height: textView.frame.size.height))
    }
  }
  
  func reduceHeightIfNeeded() {
    let newHeight = stringSizeHelper.getHeightAttr(for: textView.attributedString(),
                                                   width: textView.frame.size.width)
    
    if newHeight < textView.frame.size.height {
      updateTextViewSize(size: CGSize(width:  textView.frame.size.width + textView.textContainer!.lineFragmentPadding * 2.0,
                                      height: newHeight))
    }
  }
  
  // MARK: - Mouse events
  open override func mouseDown(with event: NSEvent) {
    mouseEventsHandler.mouseDown(with: event)
  }
  
  open override func mouseDragged(with event: NSEvent) {
    mouseEventsHandler.mouseDragged(with: event)
  }
  
  public override func mouseUp(with event: NSEvent) {
    mouseEventsHandler.mouseUp(with: event)
  }
  
  // MARK: - Gestures handlers
  
  @objc private func singleClickGestureHandle(_ gesture: NSClickGestureRecognizer) {
    editingState = .active
    
    delegate?.textAnnotationDidSelect(textAnnotation: self)
  }
  
  @objc private func doubleClickGestureHandle(_ gesture: NSClickGestureRecognizer) {
    editingState = .editing
  }
  
  // MARK: - History
  
  // by calling this method the current state of text annotation
  // will be added to history in the delegate
  func notifyAboutTextAnnotationUpdates() {
    let action = TextAnnotationAction(text: text,
                                      frame: frame,
                                      style: TextParams.textParams(from: textView.typingAttributes))
    
    textUpdateDelegate?.textAnnotationUpdated(textAnnotation: self,
                                              modelable: action)
  }
  
  // MARK: - Other
  public func updateColor(with color: NSColor) {
    textColor = color.annotationModelColor
  }
  
  public func startEditing() {
    editingState = .editing
  }
  
  public func updateFrame(with modelable: TextAnnotationModelable) {
    textView.updateTypingAttributes(textAttributes)
    
    text = modelable.text
  }
}

extension TextContainerView: NSTextViewDelegate {
  public func textDidChange(_ notification: Notification) {
    guard let textView = notification.object as? NSTextView else { return }
    let size = stringSizeHelper.bestSizeWithAttributes(for: textView.string,
                                                       attributes: textView.typingAttributes)
    updateTextViewSize(size: size)
    
    delegate?.textAnnotationDidEdit(textAnnotation: self)
  }
}


// MARK: - Previews
#if canImport(SwiftUI)
import SwiftUI

@available(OSX 10.15.0, *)
struct TextContainerViewPreview: NSViewRepresentable {
  func makeNSView(context: Context) -> NSView {
    
    let view = NSView()
    let textContainerView = TextContainerView(frame: NSRect(x: 0, y: 0, width: 300, height: 300))
    textContainerView.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(textContainerView)
    textContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    textContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    textContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    textContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    
    return view
  }

  func updateNSView(_ view: NSViewType, context: Context) {
  }
}

@available(OSX 10.15.0, *)
struct TextContainerView_Previews: PreviewProvider {
    static var previews: some View {
      TextContainerViewPreview()
        .previewLayout(.fixed(width: 300, height: 300))
    }
}
#endif


extension TextContainerView: TextAnnotation {
  
}
