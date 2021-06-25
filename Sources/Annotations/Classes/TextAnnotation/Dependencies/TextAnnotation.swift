import Cocoa

public protocol TextAnnotationUpdateDelegate: AnyObject {
  func textAnnotationUpdated(textAnnotation: TextAnnotation,
                             modelable: TextAnnotationModelable)
}

public protocol TextAnnotation where Self: NSView {
  var delegate: TextAnnotationDelegate? { get set }
  var textUpdateDelegate: TextAnnotationUpdateDelegate? { get set }
  
  var text: String { get set }
  var textColor: ModelColor { get set }
  var frame: CGRect { get set }
  var state: TextAnnotationState { get set }
  
  func startEditing()

  func updateFrame(with modelable: TextAnnotationModelable)
  func updateColor(with color: NSColor)
}

extension TextAnnotation {
  public func delete() {
    removeFromSuperview()
  }
  
  public func select() {
    state = .active
  }
  
  public func deselect() {
    state = .inactive
  }
  
  public func addTo(canvas: TextAnnotationCanvas, zPosition: CGFloat?) {
    canvas.add(textAnnotation: self)
    if let zPosition = zPosition {
      layer?.zPosition = zPosition
    }
  }
}

