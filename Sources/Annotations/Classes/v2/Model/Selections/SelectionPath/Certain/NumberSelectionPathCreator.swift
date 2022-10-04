import CoreGraphics

final class NumberSelectionPathCreator: SelectionPathCreator {
  func createSelectionPath(for figure: Number) -> CGPath {
    NumberPathCreator().createPath(for: figure)
  }
}
