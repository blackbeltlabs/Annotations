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
                            to: toPoint.pointModel,
                            number: number,
                            color: color)
    
    return model
  }
  
  static func modelWithRect(index: Int, cgRect: CGRect, number: UInt, color: ModelColor) -> NumberModel {
    let origin: CGPoint = cgRect.origin
    let toPoint: CGPoint = CGPoint(x: origin.x + cgRect.width,
                                   y: origin.y + cgRect.height)
    
    return NumberModel(index: index,
                       origin: origin.pointModel,
                       to: toPoint.pointModel,
                       number: number,
                       color: color)
  }
  
  let origin: PointModel
  let to: PointModel
  
  var rect: CGRect {
    CGRect(fromPoint: origin.cgPoint, toPoint: to.cgPoint)
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
    
  func valueFor(rectPoint: RectPoint) -> PointModel {
    switch rectPoint {
    case .origin:
      return origin.returnPointModel(
        dx: origin.x + (origin.x < to.x ? widthDot : (-widthDot)),
        dy: origin.y + (origin.y > to.y ? widthDot : (-widthDot))
      )
    case .to:
      return to.returnPointModel(
        dx: to.x + (origin.x > to.x ? widthDot : (-widthDot)),
        dy: to.y + (origin.y > to.y ? widthDot : (-widthDot))
      )
    case .originY:
      return origin.returnPointModel(
        dx: origin.x + (origin.x < to.x ? widthDot : (-widthDot)),
        dy: to.y + (origin.y > to.y ? widthDot : (-widthDot))
      )
    case .toX:
      return to.returnPointModel(
        dx: to.x + (origin.x > to.x ? widthDot : (-widthDot)),
        dy: origin.y + (origin.y > to.y ? widthDot : (-widthDot))
      )
    }
  }
  
  public var number: UInt
  public var color: ModelColor
  
  
  func copyMoving(rectPoint: RectPoint, delta: PointModel) -> Self {
    
    let model: NumberModel = {
    
    switch rectPoint {
    case .origin:
      return .init(index: index,
                   origin: origin.copyMoving(delta: delta),
                   to: to,
                   number: number,
                   color: color)
    case .to:
      return .init(index: index,
                   origin: origin,
                   to: to.copyMoving(delta: delta),
                   number: number,
                   color: color)
    case .originY:
      return .init(index: index,
                   origin: origin.returnPointModel(dx: origin.x + delta.x, dy: origin.y),
                   to: to.returnPointModel(dx: to.x, dy: to.y + delta.y),
                   number: number,
                   color: color)
    case .toX:
      return .init(index: index,
                   origin: origin.returnPointModel(dx: origin.x, dy: origin.y + delta.y),
                   to: to.returnPointModel(dx: to.x + delta.x, dy: to.y),
                   number: number,
                   color: color)
    }
    }()
    
    guard model.size.width > 15.0 && model.size.height > 15.0 else {
      return self
    }
        
    if model.size.width == model.size.height {
      return model
    } else {
        
      var updatedRect = model.rect

      if model.size.width > model.size.height {
        updatedRect.size.width = updatedRect.size.height
      } else {
        updatedRect.size.height = updatedRect.size.width
      }
      
      switch rectPoint {
      case .origin:
        
        let newOrigin = CGPoint(x: to.cgPoint.x - updatedRect.width,
                                y: to.cgPoint.y - updatedRect.height)
        
        return NumberModel(index: index,
                           origin: newOrigin.pointModel,
                           to: to,
                           number: number,
                           color: color)
      case .toX:
        let currentRectHeightPoint = model.rect.origin.y + model.rect.size.height
        
        let newOrigin = CGPoint(x: model.rect.origin.x, y: currentRectHeightPoint - updatedRect.height)
        let newSize = CGSize(width: updatedRect.width, height: updatedRect.height)
        
        return Self.modelWithRect(index: index, cgRect: CGRect(origin: newOrigin, size: newSize), number: number, color: color)
      case .originY:
        let currentRectWidthPoint = model.rect.origin.x + model.rect.size.width
        
        let newOrigin = CGPoint(x: currentRectWidthPoint - updatedRect.width, y: model.rect.origin.y)
        let newSize = CGSize(width: updatedRect.width, height: updatedRect.height)
  
        return Self.modelWithRect(index: index, cgRect: CGRect(origin: newOrigin, size: newSize), number: number, color: color)
      case .to:
        return Self.modelWithRect(index: index, cgRect: updatedRect, number: number, color: color)
      }
      
    }
  }
  
  func copyMoving(delta: PointModel) -> Self {
    return .init(index: index,
                 origin: origin.copyMoving(delta: delta),
                 to: to.copyMoving(delta: delta),
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
