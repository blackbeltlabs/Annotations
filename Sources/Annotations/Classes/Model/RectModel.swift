//
//  RectModel.swift
//  Annotations
//
//  Created by Vuong Dao on 3/28/19.
//

import Foundation

public enum RectPoint: CaseIterable {
  case origin
  case to
  case originY
  case toX
}

let widthDot: Double = 0

public class RectModel: Model {
  public var zPosition: CGFloat = 0
  public var index: Int
  public let origin: PointModel
  public let to: PointModel
  public let color: ModelColor
  
  var rect: CGRect {
    CGRect(fromPoint: origin.cgPoint, toPoint: to.cgPoint)
  }
  
  required init(index: Int, origin: PointModel, to: PointModel, color: ModelColor) {
    self.index = index
    self.origin = origin
    self.to = to
    self.color = color
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
  
  func copyMoving(rectPoint: RectPoint, delta: PointModel) -> Self {
    switch rectPoint {
    case .origin:
      return .init(index: index,
                   origin: origin.copyMoving(delta: delta),
                   to: to, color: color)
    case .to:
      return .init(index: index, origin: origin,
                   to: to.copyMoving(delta: delta), color: color)
    case .originY:
      return .init(index: index,
                   origin: origin.returnPointModel(dx: origin.x + delta.x, dy: origin.y),
                   to: to.returnPointModel(dx: to.x, dy: to.y + delta.y),
                   color: color)
    case .toX:
      return .init(index: index,
                   origin: origin.returnPointModel(dx: origin.x, dy: origin.y + delta.y),
                   to: to.returnPointModel(dx: to.x + delta.x, dy: to.y),
                   color: color)
    }
  }
  
  
  func copyMoving(delta: PointModel) -> Self {
    .init(
      index: index,
      origin: origin.copyMoving(delta: delta),
      to: to.copyMoving(delta: delta),
      color: color
    )
  }
  
  func copyWithColor(color: ModelColor) -> Self {
    .init(index: index, origin: origin, to: to, color: color)
  }
  
  public static func == (lhs: RectModel, rhs: RectModel) -> Bool {
    lhs.index == rhs.index &&
      lhs.origin == rhs.origin &&
      lhs.to == rhs.to &&
      lhs.color == rhs.color
  }
}

public class ObfuscateModel: RectModel {}
public class HighlightModel: RectModel {}
