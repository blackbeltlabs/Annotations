//
//  RectCanvas.swift
//  Annotations
//
//  Created by Vuong Dao on 3/28/19.
//

import Foundation


import Foundation

protocol RectCanvas: class, RectViewDelegate {
    var model: CanvasModel { get set }
    func add(_ item: CanvasDrawable)
}

extension RectCanvas {
    func redrawRects(model: CanvasModel) {
        for (index, model) in model.rects.enumerated() {
            let state = RectViewState(model: model, isSelected: false)
            let view = RectViewClass(state: state, modelIndex: index)
            view.delegate = self
            add(view)
        }
    }
    
    func createRectView(origin: PointModel, to: PointModel) -> (CanvasDrawable?, KnobView?) {
        if origin.distanceTo(to) < 5 {
            return (nil, nil)
        }
        
        let newRect = RectModel(origin: origin, to: to)
        model.rects.append(newRect)
        
        let state = RectViewState(model: newRect, isSelected: false)
        let newView = RectViewClass(state: state, modelIndex: model.rects.count - 1)
        newView.delegate = self
        
        let selectedKnob = newView.knobAt(rectPoint: .to)
        
        return (newView, selectedKnob)
    }
    
    func delete(rect: RectView) -> CanvasModel {
        return model.copyWithout(type: .rect, index: rect.modelIndex)
    }
    
    func rectView(_ rectView: RectView, didUpdate model: RectModel, atIndex index: Int) {
        DispatchQueue.main.async {
            self.model.rects[index] = model
        }
        
    }
}
