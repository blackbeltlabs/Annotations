import CoreGraphics

public struct AnnotationPoint: Codable {
  let x: Double
  let y: Double
  
  static var zero: AnnotationPoint {
    .init(x: 0, y: 0)
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
