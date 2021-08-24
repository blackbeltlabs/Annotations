//
//  PointModel.swift
//  Zappy Arrow Annotation
//
//  Created by Mirko on 1/3/19.
//  Copyright © 2019 Blackbelt Labs. All rights reserved.
//

import Foundation

public struct PointModel: ShapeModel {
  
  public var id: String = UUID().uuidString
  public var index: Int
  public let x: Double
  public let y: Double
  
  var cgPoint: CGPoint {
    CGPoint(x: x, y: y)
  }
  
  func distanceTo(_ point: PointModel) -> Double {
    let delta = deltaTo(point)
    return sqrt(pow(delta.x, 2) + pow(delta.y, 2))
  }
  
  func deltaTo(_ point: PointModel) -> PointModel {
    .init(index: index, x: point.x - x, y: point.y - y)
  }
  
  func copyMoving(delta: PointModel) -> PointModel {
    copyMoving(dx: delta.x, dy: delta.y)
  }
  
  func copyMoving(dx: Double, dy: Double) -> PointModel {
    .init(index: index, x: x + dx, y: y + dy)
  }
  
  func returnPointModel(dx: Double, dy: Double) -> PointModel {
    .init(index: index, x: dx, y: dy)
  }
  
  func copyMovingEnd(delta: PointModel) -> PointModel {
    copyMovingEnd(dx: delta.x, dy: delta.y)
  }
  func copyMovingEnd(dx: Double, dy: Double) -> PointModel {
    .init(index: index, x:  dx - x, y: dy - y)
  }
  
  func deltaToEnd(_ point: PointModel) -> PointModel {
    .init(index: index, x: point.x - x, y: point.y - y)
  }
  
}

extension CGPoint {
  var pointModel: PointModel {
    .init(index: 0, x: Double(x), y: Double(y))
  }
  
  func deltaTo(_ point: CGPoint) -> PointModel {
    pointModel.deltaTo(point.pointModel)
  }
}

