import Foundation
import CoreGraphics

public struct Number: RectBased, Figure {
  
  public var id: String = UUID().uuidString
  public var color: ModelColor = .zero
  public var zPosition: CGFloat = 0
  
  public var origin: AnnotationPoint
  public var to: AnnotationPoint
  
  public var value: Int  // number value
    
  var rect: CGRect {
    CGRect(fromPoint: origin.cgPoint, toPoint: to.cgPoint)
  }
  
  var size: CGSize {
    rect.size
  }
  
  static var defaultRadius: CGFloat = 15.0
  
  static func modelWithRadius(centerPoint: AnnotationPoint, radius: CGFloat, value: Int, zPosition: CGFloat, color: ModelColor) -> Self {
    let origin = CGPoint(x: CGFloat(centerPoint.x) - radius,
                         y: CGFloat(centerPoint.y) - radius)
    let to = CGPoint(x: origin.x + radius * 2.0,
                     y: origin.y + radius * 2.0)
    
    return Number(color: color,
                  zPosition: zPosition,
                  origin: origin.modelPoint,
                  to: to.modelPoint,
                  value: value)
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
