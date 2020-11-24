import Foundation

public struct NumberModel: Model {
  public var index: Int
  
  public var centerPoint: PointModel
  
  var origin: CGPoint {
    CGPoint(x: centerPoint.x - radius,
            y: centerPoint.y - radius)
  }
  
  var size: CGSize {
    CGSize(width: radius * 2.0, height: radius * 2.0)
  }
  
  var rect: CGRect {
    CGRect(origin: origin, size: size)
  }
  
  var originToX: CGPoint {
    CGPoint(x: origin.x + size.width, y: origin.y)
  }
  
  var originToY: CGPoint {
    CGPoint(x: origin.x, y: origin.y + size.height)
  }
  
  var originToXY: CGPoint {
    CGPoint(x: origin.x + size.width, y: origin.y + size.height) 
  }
  
  func valueFor(numberPoint: NumberPoint) -> PointModel {
    switch numberPoint {
    case .origin:
      return origin.pointModel
    case .originToX:
      return originToX.pointModel
    case .originToY:
      return originToY.pointModel
    case .originToXY:
      return originToXY.pointModel
    }
  }
  
  public var number: UInt
  public var color: ModelColor
  
  var radius = 15.0
  
  func copyWithColor(color: ModelColor) -> NumberModel {
    var newModel = self
    newModel.color = color
    return newModel
  }
  
  func copyWithNumber(number: UInt) -> NumberModel {
    var newModel = self
    newModel.number = number
    return newModel
  }
}
