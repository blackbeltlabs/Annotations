import CoreGraphics

final class RectPathCreator: PathCreator {
  func createPath(for figure: Rect) -> CGPath {
    let rect = CGRect.rect(fromPoint: figure.origin.cgPoint,
                           toPoint: figure.to.cgPoint)
    return CGPath(rect: rect, transform: nil)
  }
}

