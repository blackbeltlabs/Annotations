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

public struct RectModel: Model {
    public let origin: PointModel
    public let to: PointModel
    
    mutating func valueFor(rectPoint: RectPoint) -> PointModel {
        switch rectPoint {
        case .origin:
            return origin.returnPointModel(dx:origin.x + (origin.x < to.x ? widthDot : (-widthDot)), dy:origin.y + (origin.y > to.y ? widthDot : (-widthDot)))
        case .to:
            return to.returnPointModel(dx:to.x + (origin.x > to.x ? widthDot : (-widthDot)), dy:to.y + (origin.y > to.y ? widthDot : (-widthDot)))
        case .originY:
            return origin.returnPointModel(dx:origin.x + (origin.x < to.x ? widthDot : (-widthDot)), dy:to.y + (origin.y > to.y ? widthDot : (-widthDot)))
        case .toX:
            return to.returnPointModel(dx:to.x + (origin.x > to.x ? widthDot : (-widthDot)), dy:origin.y + (origin.y > to.y ? widthDot : (-widthDot)))
        }
    }
    
    func copyMoving(rectPoint: RectPoint, delta: PointModel) -> RectModel {
        switch rectPoint {
        case .origin:
            return RectModel(origin: origin.copyMoving(delta: delta), to: to)
        case .to:
            return RectModel(origin: origin, to: to.copyMoving(delta: delta))
        case .originY:
            return RectModel(origin: origin.returnPointModel(dx:origin.x + delta.x, dy:origin.y), to: to.returnPointModel(dx:to.x, dy:to.y + delta.y))
        case .toX:
            return RectModel(origin: origin.returnPointModel(dx:origin.x, dy:origin.y + delta.y), to: to.returnPointModel(dx:to.x + delta.x, dy:to.y))
        }
    }
    
    
    func copyMoving(delta: PointModel) -> RectModel {
        return RectModel(
            origin: origin.copyMoving(delta: delta),
            to: to.copyMoving(delta: delta)
        )
    }
}
