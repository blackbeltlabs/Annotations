import CoreGraphics

final class ArrowSelectionPathCreator: SelectionPathCreator {
  func createSelectionPath(for figure: Arrow) -> CGPath {
    ArrowPathCreator().createPath(for: figure)
  }
}
