import Foundation
import CoreGraphics

final class RectSelectionPathCreator: SelectionPathCreator {
  func createSelectionPath(for annotation: Rect) -> CGPath {
    let path = RectPathCreator().createPath(for: annotation)
      
    if annotation.rectType == .regular {
      // lineWidth + 15 points around for the rectangle selection path
      return path.copy(strokingWithWidth: annotation.lineWidth + 15.0,
                       lineCap: .butt,
                       lineJoin: .miter,
                       miterLimit: 1)
    } else {
      return path
    }
  }
}
