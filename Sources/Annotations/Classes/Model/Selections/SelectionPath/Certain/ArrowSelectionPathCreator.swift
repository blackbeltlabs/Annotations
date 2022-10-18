import CoreGraphics

final class ArrowSelectionPathCreator: SelectionPathCreator {
  func createSelectionPath(for annotation: Arrow) -> CGPath {
    ArrowPathCreator().createPath(for: annotation)
  }
}
