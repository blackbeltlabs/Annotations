import Foundation

final class NumberPathCreator: PathCreator {
  func createPath(for figure: Number) -> CGPath {
    let rect = CGRect.rect(fromPoint: figure.origin.cgPoint,
                           toPoint: figure.to.cgPoint)
    return CGPath(ellipseIn: rect, transform: nil)
  }
}
