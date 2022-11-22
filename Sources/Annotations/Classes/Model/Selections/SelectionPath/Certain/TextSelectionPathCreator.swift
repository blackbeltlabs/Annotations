import Foundation
import CoreGraphics

final class TextSelectionPathCreator: SelectionPathCreator {
  func createSelectionPath(for annotation: Text) -> CGPath {
    let rect = Self.selectionRect(for: annotation)
    return CGPath(rect: rect, transform: nil)
  }
  
  class func textViewRect(for annotation: Text) -> CGRect {
    CGRect.rect(fromPoint: annotation.origin.cgPoint,
                toPoint: annotation.to.cgPoint)
  }
  
  class func selectionRect(for annotation: Text) -> CGRect {
    let frame = textViewRect(for: annotation)
   
    return frame.insetBy(dx: -5.0,
                         dy: -10.0)
  }
}
