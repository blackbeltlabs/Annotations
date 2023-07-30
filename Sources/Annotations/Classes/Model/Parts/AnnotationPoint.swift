import CoreGraphics

public struct AnnotationPoint: Codable {
  let x: Double
  let y: Double
  
  public init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }
  
  static var zero: AnnotationPoint {
    .init(x: 0, y: 0)
  }
  
  func applyingDelta(vector: CGVector) -> AnnotationPoint {
    return .init(x: x + vector.dx, y: y + vector.dy)
  }
}

// MARK: - CGPoint adapters
extension AnnotationPoint {
  var cgPoint: CGPoint {
    .init(x: x, y: y)
  }
}

extension CGPoint {
  var modelPoint: AnnotationPoint {
    .init(x: x, y: y)
  }
}
