import Foundation
import CoreGraphics

public struct Number: RectBased, Figure {
  
  public var id: String = UUID().uuidString
  public var color: ModelColor = .zero
  public var zPosition: CGFloat = 0
  
  public var origin: AnnotationPoint
  public var to: AnnotationPoint
  
  public var value: Int  // number value
  
  public var points: [AnnotationPoint] = []
  
  
  var rect: CGRect {
    CGRect(fromPoint: origin.cgPoint, toPoint: to.cgPoint)
  }
  
  var size: CGSize {
    rect.size
  }
  
  public struct Mocks {
    public static var mock: Number {
      .init(color: .init(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
            zPosition: 10,
            origin: .init(x: 120, y: 120),
            to: .init(x: 200, y: 200),
            value: 9)
    }
  }
}
