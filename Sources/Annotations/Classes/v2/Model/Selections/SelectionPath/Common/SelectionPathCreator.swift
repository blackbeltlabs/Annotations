import CoreGraphics

protocol SelectionPathCreator {
  associatedtype F: AnnotationModel
  func createSelectionPath(for figure: F) -> CGPath
}
