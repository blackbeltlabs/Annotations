import Foundation

final class TextSelectionPathCreator: SelectionPathCreator {
  func createSelectionPath(for annotation: Text) -> CGPath {
    RectPathCreator.createPath(for: annotation)
  }
}
