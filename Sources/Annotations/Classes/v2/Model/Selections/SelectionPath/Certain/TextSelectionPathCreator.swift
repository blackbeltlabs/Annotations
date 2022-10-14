import Foundation

final class TextSelectionPathCreator: SelectionPathCreator {
  func createSelectionPath(for annotation: Text) -> CGPath {
    let rect = Self.selectionRect(for: annotation)
    return CGPath(rect: rect, transform: nil)
  }
  
  class func selectionRect(for annotation: Text) -> CGRect {
    let frame = CGRect.rect(fromPoint: annotation.origin.cgPoint,
                            toPoint: annotation.to.cgPoint)
    return frame.insetBy(dx: -5.0,
                         dy: -10.0)
  }
}
