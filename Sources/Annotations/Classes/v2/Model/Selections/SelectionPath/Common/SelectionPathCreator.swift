import CoreGraphics

protocol SelectionPathCreator {
  associatedtype F: Figure
  func createSelectionPath(for figure: F) -> CGPath
}
