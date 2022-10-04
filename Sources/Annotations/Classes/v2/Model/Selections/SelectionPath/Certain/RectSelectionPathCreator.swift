import Foundation

final class RectSelectionPathCreator: SelectionPathCreator {
  func createSelectionPath(for figure: Rect) -> CGPath {
    RectPathCreator().createPath(for: figure)
  }
}
