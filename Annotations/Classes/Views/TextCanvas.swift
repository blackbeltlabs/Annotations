//
//  TextCanvas.swift
//  Annotations
//
//  Created by vuong dao on 4/8/19.
//

import Foundation

protocol TextCanvas: class, TextViewDelegate {
    var model: CanvasModel { get set }
    func add(_ item: CanvasDrawable)
}

extension TextCanvas {
    func redrawTexts(model: CanvasModel) {
        for (index, model) in model.texts.enumerated() {
            let state = TextViewState(model: model, isSelected: false)
            let view = TextViewClass(state: state, modelIndex: index)
            view.delegate = self
            add(view)
        }
    }
    
    func createTextView(origin: PointModel, to: PointModel) -> (CanvasDrawable?, KnobView?) {
        
        let newText = TextModel(origin: origin)
        model.texts.append(newText)
        
        let state = TextViewState(model: newText, isSelected: false)
        let newView = TextViewClass(state: state, modelIndex: model.texts.count - 1)
        newView.delegate = self
        
        let selectedKnob = newView.knobAt(textPoint: .origin)
        
        return (newView, selectedKnob)
    }
    
    func delete(text: TextView) -> CanvasModel {
        return model.copyWithout(type: .text, index: text.modelIndex)
    }
    
    func textView(_ textView: TextView, didUpdate model: TextModel, atIndex index: Int) {
        self.model.texts[index] = model
    }
}
