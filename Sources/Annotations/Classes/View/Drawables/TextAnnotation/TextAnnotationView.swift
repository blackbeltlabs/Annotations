import Foundation
import Cocoa
import Combine

class TextAnnotationView: NSView, DrawableElement {
  
  var id: String = ""
  
  let textDidChangedSubject = PassthroughSubject<String, Never>()
  
  override var frame: NSRect {
    didSet {
      guard #available(macOS 13.0, *) else {
        // update subframes in frames works well for macOS prior to 13.0 (Ventura)
        textView.frame = bounds
        legibilityTextView.frame = bounds
        return
      }
    }
  }
  
  let debugMode: Bool = false
  
  private let textView = TextView(frame: .zero)
  
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
  
  override func layout() {
    super.layout()
    
    // starting from macOS Ventura it is mandatory to update subviews here for correct work
    if #available(macOS 13.0, *) {
      textView.frame = bounds
      legibilityTextView.frame = bounds
    }
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
    
    if let nsColor = style.attributes[.foregroundColor] as? NSColor {
      textView.insertionPointColor = nsColor
      textView.needsDisplay = true
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
  
  func setLinePadding(_ padding: CGFloat) {
    textView.textContainer?.lineFragmentPadding = padding
    legibilityTextView.textContainer?.lineFragmentPadding = padding
  }
  
  var font: NSFont? {
    get {
      textView.font
    }
    
    set {
      textView.font = newValue
      legibilityTextView.font = newValue
    }
  }
  
  func presentEmojiPicker() {
    NSApp.orderFrontCharacterPalette(textView)
  }
}

extension TextAnnotationView: NSTextViewDelegate {
  func textDidChange(_ notification: Notification) {
    guard let textView = notification.object as? NSTextView else { return }
    legibilityTextView.string = textView.string
    textDidChangedSubject.send(textView.string)
  }
}
