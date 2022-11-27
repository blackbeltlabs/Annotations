import Foundation
import CoreGraphics

final class RectSelectionPathCreator: SelectionPathCreator {
  func createSelectionPath(for annotation: Rect) -> CGPath {
    RectPathCreator().createPath(for: annotation)
  }
}