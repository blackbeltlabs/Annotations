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

public struct RectModel: Model {
    let origin: PointModel
    let to: PointModel
    
    func valueFor(rectPoint: RectPoint) -> PointModel {
        switch rectPoint {
        case .origin: return origin
        case .to: return to
        case .originY: return origin.returnPointModel(dx:origin.x, dy:to.y)
        case .toX: return to.returnPointModel(dx:to.x, dy:origin.y)
        }
    }
    
    func copyMoving(rectPoint: RectPoint, delta: PointModel) -> RectModel {
        switch rectPoint {
        case .origin:
            return RectModel(origin: origin.copyMoving(delta: delta), to: to)
        case .to:
            return RectModel(origin: origin, to: to.copyMoving(delta: delta))
        case .originY:
            return RectModel(origin: origin.returnPointModel(dx:origin.x, dy:to.y).copyMoving(delta: delta), to: to.returnPointModel(dx:to.x, dy:origin.y))
        case .toX:
            return RectModel(origin: origin.returnPointModel(dx:origin.x, dy:to.y), to: to.returnPointModel(dx:to.x, dy:origin.y).copyMoving(delta: delta))
        }
    }
    
    
    func copyMoving(delta: PointModel) -> RectModel {
        return RectModel(
            origin: origin.copyMoving(delta: delta),
            to: to.copyMoving(delta: delta)
        )
    }
}
