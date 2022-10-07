import Foundation

final class PathCalculations {
  static func delta(from point1: CGPoint, to point2: CGPoint) -> CGPoint {
      CGPoint(x: point2.x - point1.x,
              y: point2.y - point1.y)
  }
  
  static func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
    let delta = self.delta(from: point1, to: point2)
    return sqrt(pow(delta.x, 2) + pow(delta.y, 2))
  }
}
