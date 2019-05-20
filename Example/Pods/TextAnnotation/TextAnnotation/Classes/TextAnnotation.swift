import Cocoa

public protocol TextAnnotation where Self: NSView {
  var text: String { get set }
  var frame: CGRect { get set }
  var state: TextAnnotationState { get set }
}

extension TextContainerView: TextAnnotation {
  
}
