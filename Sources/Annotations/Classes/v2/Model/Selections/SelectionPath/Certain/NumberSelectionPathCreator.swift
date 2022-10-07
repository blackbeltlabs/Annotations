import CoreGraphics

final class NumberSelectionPathCreator: SelectionPathCreator {
  func createSelectionPath(for annotation: Number) -> CGPath {
    NumberPathCreator().createPath(for: annotation)
  }
}
