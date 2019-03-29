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
}

public struct RectModel: Model {
    let origin: PointModel
    let to: PointModel
    
    func valueFor(rectPoint: RectPoint) -> PointModel {
        switch rectPoint {
        case .origin: return origin
        case .to: return to
        }
    }
    
    func copyMoving(rectPoint: RectPoint, delta: PointModel) -> RectModel {
        switch rectPoint {
        case .origin:
            return RectModel(origin: origin.copyMoving(delta: delta), to: to)
        case .to:
            return RectModel(origin: origin, to: to.copyMoving(delta: delta))
        }
    }
    
    func copyMoving(delta: PointModel) -> RectModel {
        return RectModel(
            origin: origin.copyMoving(delta: delta),
            to: to.copyMoving(delta: delta)
        )
    }
}
