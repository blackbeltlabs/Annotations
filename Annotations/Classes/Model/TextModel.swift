//
//  TextModel.swift
//  Annotations
//
//  Created by Vuong Dao on 4/8/19.
//
import Foundation

public enum TextPoint: CaseIterable {
    case origin
    case to
}

public struct TextModel: Model {
    let origin: PointModel
    let to: PointModel
    
    func valueFor(textPoint: TextPoint) -> PointModel {
        switch textPoint {
        case .origin: return origin
        case .to: return to
        }
    }
    
    func copyMoving(textPoint: TextPoint, delta: PointModel) -> TextModel {
        switch textPoint {
        case .origin:
            return TextModel(origin: origin.copyMoving(delta: delta), to: to)
        case .to:
            return TextModel(origin: origin, to: to.copyMoving(delta: delta))
        }
    }
    
    func copyMoving(delta: PointModel) -> TextModel {
        return TextModel(
            origin: origin.copyMoving(delta: delta),
            to: to.copyMoving(delta: delta)
        )
    }
}
