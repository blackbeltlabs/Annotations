//
//  Arrow.swift
//  Zappy Arrow Annotation
//
//  Created by Mirko on 1/3/19.
//  Copyright © 2019 Blackbelt Labs. All rights reserved.
//

import Foundation

public enum ArrowPoint: CaseIterable {
  case origin
  case to
}

public struct ArrowModel: Model {
  public var index: Int
  public let origin: PointModel
  public let to: PointModel
  public let color: ModelColor
  
  func valueFor(arrowPoint: ArrowPoint) -> PointModel {
    switch arrowPoint {
    case .origin: return origin
    case .to: return to
    }
  }
  
  func copyMoving(arrowPoint: ArrowPoint, delta: PointModel) -> ArrowModel {
    switch arrowPoint {
    case .origin:
      return ArrowModel(index: index,
                        origin: origin.copyMoving(delta: delta),
                        to: to, color: color)
    case .to:
      return ArrowModel(index: index,
                        origin: origin,
                        to: to.copyMoving(delta: delta),
                        color: color)
    }
  }
  
  func copyMoving(delta: PointModel) -> ArrowModel {
    return ArrowModel(
      index: index,
      origin: origin.copyMoving(delta: delta),
      to: to.copyMoving(delta: delta),
      color: color
    )
  }
  
  func copyWithColor(color: ModelColor) -> ArrowModel {
    return ArrowModel(index: index,
                      origin: origin,
                      to: to,
                      color: color)
  }
}
