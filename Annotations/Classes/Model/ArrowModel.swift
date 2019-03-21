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
  let origin: PointModel
  let to: PointModel
  
  func valueFor(arrowPoint: ArrowPoint) -> PointModel {
    switch arrowPoint {
    case .origin: return origin
    case .to: return to
    }
  }
  
  func copyMoving(arrowPoint: ArrowPoint, delta: PointModel) -> ArrowModel {
    switch arrowPoint {
    case .origin:
      return ArrowModel(origin: origin.copyMoving(delta: delta), to: to)
    case .to:
      return ArrowModel(origin: origin, to: to.copyMoving(delta: delta))
    }
  }
  
  func copyMoving(delta: PointModel) -> ArrowModel {
    return ArrowModel(
      origin: origin.copyMoving(delta: delta),
      to: to.copyMoving(delta: delta)
    )
  }
}
