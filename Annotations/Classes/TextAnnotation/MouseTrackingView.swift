import Cocoa

public enum TextAnnotationArea {
  case resizeRightArea
  case resizeLeftArea
  case scaleArea
  case textArea
}

public protocol MouseTrackingResponder: class {
  func areaDidActivated(_ area: TextAnnotationArea)
}

class MouseTrackingView: NSView {
  
  // MARK: - Variables
  
  weak private var activeAreaResponder: MouseTrackingResponder?
  private(set) var area: TextAnnotationArea?
  
  var isEnabled: Bool = true
  
  // MARK: - Lifecycle
  
  convenience init(type: TextAnnotationArea, responder: MouseTrackingResponder, frameRect: NSRect) {
    self.init(frame: frameRect)
    
    area = type
    activeAreaResponder = responder
  }
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    
    let options = NSTrackingArea.Options.activeInKeyWindow.rawValue | NSTrackingArea.Options.mouseEnteredAndExited.rawValue | NSTrackingArea.Options.inVisibleRect.rawValue
    let trackingArea = NSTrackingArea(rect: bounds, options: NSTrackingArea.Options(rawValue: options), owner: self, userInfo: nil)
    
    addTrackingArea(trackingArea)
  }
  
  required init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: NSResponder
  
  override func mouseEntered(with event: NSEvent) {
    guard isEnabled else { return }
    // we can not implement it on this level, because on the dragging we directly receive mouseExited(with theEvent:) here
    if let responder = activeAreaResponder, let type = area {
      responder.areaDidActivated(type)
    }
  }
  
  override func hitTest(_ point: NSPoint) -> NSView? {
    isEnabled ? super.hitTest(point) : nil
  }
}

