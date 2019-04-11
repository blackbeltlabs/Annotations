//
//  PointModel.swift
//  Zappy Arrow Annotation
//
//  Created by Mirko on 1/3/19.
//  Copyright © 2019 Blackbelt Labs. All rights reserved.
//

import Foundation

public struct PointModel: Model {
    let x: Double
    let y: Double
    
    
    var cgPoint: CGPoint {
        return CGPoint(x: x, y: y)
    }
    
    func distanceTo(_ point: PointModel) -> Double {
        let delta = deltaTo(point)
        return sqrt(pow(delta.x, 2) + pow(delta.y, 2))
    }
    
    func deltaTo(_ point: PointModel) -> PointModel {
        return PointModel(x: point.x - x, y: point.y - y)
    }
    
    func copyMoving(delta: PointModel) -> PointModel {
        return copyMoving(dx: delta.x, dy: delta.y)
    }
    
    func copyMoving(dx: Double, dy: Double) -> PointModel {
        return PointModel(x: x + dx, y: y + dy)
    }
    
    func returnPointModel(dx: Double, dy: Double) -> PointModel {
        return PointModel(x: dx, y: dy)
    }
    
    ///////////TEST//////////
    func copyMovingEnd(delta: PointModel) -> PointModel {
        return copyMovingEnd(dx: delta.x, dy: delta.y)
    }
    func copyMovingEnd(dx: Double, dy: Double) -> PointModel {
        return PointModel(x:  dx - x, y: dy - y)
    }
    
    func deltaToEnd(_ point: PointModel) -> PointModel {
        return PointModel(x: point.x - x, y: point.y - y)
    }
    
}

extension CGPoint {
  var pointModel: PointModel {
    return PointModel(x: Double(x), y: Double(y))
  }
  
  func deltaTo(_ point: CGPoint) -> PointModel {
    return pointModel.deltaTo(point.pointModel)
  }
}
