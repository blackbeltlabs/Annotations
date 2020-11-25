import Foundation

public struct NumberModel: Model {
  
  static let defaultRadius: CGFloat = 15.0
  
  public var index: Int
    
  static func modelWithRadius(index: Int, centerPoint: PointModel, radius: CGFloat, number: UInt, color: ModelColor) -> NumberModel {
    
    let origin: CGPoint = CGPoint(x: CGFloat(centerPoint.x) - radius,
                                  y: CGFloat(centerPoint.y) - radius)
    
    let toPoint: CGPoint = CGPoint(x: origin.x + radius * 2.0,
                                   y: origin.y + radius * 2.0)
        
    let model = NumberModel(index: index,
                            origin: origin.pointModel,
                            toPoint: toPoint.pointModel,
                            number: number,
                            color: color)
    
    return model
  }
  
  let origin: PointModel
  let toPoint: PointModel
  
  var rect: CGRect {
    CGRect(fromPoint: origin.cgPoint, toPoint: toPoint.cgPoint)
  }
  
  var size: CGSize {
    rect.size
  }
  
  var originToX: CGPoint {
    CGPoint(x: origin.cgPoint.x + size.width, y: origin.cgPoint.y)
  }
  
  var originToY: CGPoint {
    CGPoint(x: origin.cgPoint.x, y: origin.cgPoint.y + size.height)
  }
  
  var originToXY: CGPoint {
    CGPoint(x: origin.cgPoint.x + size.width, y: origin.cgPoint.y + size.height)
  }
  
  func valueFor(numberPoint: NumberPoint) -> PointModel {
    switch numberPoint {
    case .origin:
      return origin
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
  
  
  func copyMoving(delta: PointModel) -> Self {
    return .init(index: index,
                 origin: origin.copyMoving(delta: delta),
                 toPoint: toPoint.copyMoving(delta: delta),
                 number: number,
                 color: color)
  }
  
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
