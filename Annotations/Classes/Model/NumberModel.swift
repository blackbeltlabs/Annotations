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
