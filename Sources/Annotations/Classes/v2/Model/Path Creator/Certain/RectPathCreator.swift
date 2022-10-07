import CoreGraphics

final class RectPathCreator: PathCreator {
  static func createPath(for rectBased: RectBased) -> CGPath {
    let rect = CGRect.rect(fromPoint: rectBased.origin.cgPoint,
                           toPoint: rectBased.to.cgPoint)
    return CGPath(rect: rect, transform: nil)
  }
  
  func createPath(for figure: Rect) -> CGPath {
    Self.createPath(for: figure)
  }
}

