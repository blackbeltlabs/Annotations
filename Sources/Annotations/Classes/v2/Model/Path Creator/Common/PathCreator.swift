import CoreGraphics

protocol PathCreator {
  associatedtype F: Figure
  func createPath(for figure: F) -> CGPath
}
