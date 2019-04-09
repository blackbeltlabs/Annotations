//
//  TextModel.swift
//  Annotations
//
//  Created by Vuong Dao on 4/8/19.
//
import Foundation

public enum TextPoint: CaseIterable {
    case origin
}

public struct TextModel: Model {
    let origin: PointModel
    
    func valueFor(textPoint: TextPoint) -> PointModel {
        switch textPoint {
        case .origin: return origin
        }
    }
    
    func copyMoving(textPoint: TextPoint, delta: PointModel) -> TextModel {
        switch textPoint {
        case .origin:
            return TextModel(origin: origin)
        }
    }
    
    func copyMoving(delta: PointModel) -> TextModel {
        return TextModel(
            origin: origin
        )
    }
}
