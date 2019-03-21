//
//  ArrowCanvasView.swift
//  Zappy Arrow Annotation
//
//  Created by Mirko on 1/6/19.
//  Copyright © 2019 Blackbelt Labs. All rights reserved.
//

import Foundation

protocol TextCanvas: class, TextViewDelegate {
  var model: CanvasModel { get set }
  func add(_ item: CanvasDrawable)
  func markState(model: CanvasModel)
}

extension TextCanvas {
  func redrawText(model: CanvasModel) {
    for (index, model) in model.text.enumerated() {
      let state = TextViewState(model: model, isSelected: false)
      let view = TextViewClass(state: state, modelIndex: index)
      view.delegate = self
      add(view)
    }
  }
  
  func createTextView(origin: PointModel) -> CanvasDrawable {
    let newText = TextModel(text: "", origin: origin)
    
    model.text.append(newText)
    
    let state = TextViewState(model: newText, isSelected: false)
    let newView = TextViewClass(state: state, modelIndex: model.text.count - 1)
    newView.delegate = self
    
    return newView
  }
  
  func delete(text: TextView) -> CanvasModel {
    return model.copyWithout(type: .text, index: text.modelIndex)
  }
  
  func textView(_ textView: TextView, didUpdate model: TextModel, atIndex index: Int) {
    self.model.text[index] = model
  }
  
  func textView(_ textView: TextView, didEndEditing model: TextModel) {
    markState(model: self.model)
  }
}
