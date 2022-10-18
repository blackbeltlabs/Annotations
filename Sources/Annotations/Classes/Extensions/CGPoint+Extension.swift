import Cocoa

extension CGPoint {
  static func distanceBetween(point1: CGPoint, point2: CGPoint) -> Double {
    let delta = point1.deltaTo(point2)
    return sqrt(pow(delta.x, 2) + pow(delta.y, 2))
  }
  
  private func deltaTo(_ point: CGPoint) -> CGPoint {
    .init(x: point.x - x, y: point.y - y)
  }
}
