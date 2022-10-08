import Foundation
import Cocoa
import Combine

class TextAnnotationView: NSView, DrawableElement {
  
  var id: String = ""
  
  let textDidChangedSubject = PassthroughSubject<String, Never>()
  
  override var frame: NSRect {
    didSet {
      textView.frame = bounds
      legibilityTextView.frame = bounds
    }
  }
  
  let debugMode: Bool = true
  
  let textView = TextView(frame: .zero)
  
  private lazy var legibilityTextView: LegibilityTextView = {
    let textView = LegibilityTextView(frame: .zero)
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.isEditable = false
    textView.isSelectable = false
    textView.isHidden = true
    return textView
  }()
  
  var string: String {
    set {
      textView.string = newValue
      legibilityTextView.string = newValue
    }
    get {
      textView.string
    }
  }
  
  var isEditable: Bool {
    set {
      textView.isEditable = newValue
    }
    get {
      textView.isEditable
    }
  }
  
  override init(frame: NSRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupUI() {
    wantsLayer = true
    addSubviews()
  }
  
  func addSubviews() {
    setupTextView(textView)
    setupTextView(legibilityTextView)
    
    addSubview(legibilityTextView)
    addSubview(textView)
    
    legibilityTextView.wantsLayer = true
    legibilityTextView.layer?.applySketchShadow(color: NSColor.black.withAlphaComponent(0.5),
                                                alpha: 1.0,
                                                xOffset: 0,
                                                yOffset: 2.0,
                                                blur: 4.0,
                                                spread: 0)
    
    textView.delegate = self
  }
  
  
  private func setupTextView(_ textView: NSTextView) {
    textView.translatesAutoresizingMaskIntoConstraints = false
                                         
    textView.alignment = .natural
    textView.backgroundColor = NSColor.clear
    textView.isRichText = false
    textView.usesRuler = false
    textView.usesFontPanel = false
    textView.drawsBackground = false
    //textView.isVerticallyResizable = true
    
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
  
  func setLegibilityEffectEnabled(_ enabled: Bool) {
    legibilityTextView.isHidden = !enabled
  }

  func setStyle(_ style: TextParams) {
    textView.updateTypingAttributes(style.attributes)
    
    if let font = style.attributes[.font] as? NSFont {
      legibilityTextView.font = font
    }
  }
  
  func setZPosition(_ zPosition: CGFloat) {
    layer?.zPosition = zPosition
  }
  
  func setEditing(_ enabled: Bool) {
    if enabled {
      textView.isEditable = true
      textView.isSelectable = true
      textView.window?.makeFirstResponder(textView)
    } else {
      textView.isEditable = false
      textView.isSelectable = false
    }
  }
  
}

extension TextAnnotationView: NSTextViewDelegate {
  func textDidChange(_ notification: Notification) {
    guard let textView = notification.object as? NSTextView else { return }
    
    textDidChangedSubject.send(textView.string)
  }
}
