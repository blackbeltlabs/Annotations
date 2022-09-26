import CoreGraphics

final class RectPathCreator: PathCreator {
  func createPath(for figure: Rect) -> CGPath {
    let rect = CGRect.rect(fromPoint: figure.origin.cgPoint,
                           toPoint: figure.to.cgPoint)
    return CGPath(rect: rect, transform: nil)
  }
}

final class NumberPathCreator: PathCreator {
  func createPath(for figure: Number) -> CGPath {
    let rect = CGRect.rect(fromPoint: figure.origin.cgPoint,
                           toPoint: figure.to.cgPoint)
    return CGPath(ellipseIn: rect, transform: nil)
  }
}

private extension CGRect {
  static func rect(fromPoint: CGPoint, toPoint: CGPoint) -> CGRect {
    let x = min(fromPoint.x, toPoint.x)
    let y = min(fromPoint.y, toPoint.y)
    let width = abs(toPoint.x - fromPoint.x)
    let height = abs(toPoint.y - fromPoint.y)
    
    return self.init(x: x, y: y, width: width, height:  height)
  }
}
