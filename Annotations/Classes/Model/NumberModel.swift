import Foundation

public struct NumberModel: Model {
  public var index: Int
  public var point: PointModel
  public var number: UInt
  public var color: ModelColor
  
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
