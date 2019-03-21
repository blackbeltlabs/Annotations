//
//  ArrowCanvasView.swift
//  Zappy Arrow Annotation
//
//  Created by Mirko on 1/6/19.
//  Copyright © 2019 Blackbelt Labs. All rights reserved.
//

import Foundation

protocol PenCanvas: class, PenViewDelegate {
  var model: CanvasModel { get set }
  func add(_ item: CanvasDrawable)
}

extension PenCanvas {
  func redrawPens(model: CanvasModel) {
    for (index, model) in model.pens.enumerated() {
      let state = PenViewState(model: model, isSelected: false)
      let view = PenViewClass(state: state, modelIndex: index)
      view.delegate = self
      add(view)
    }
  }
  
  func createPenView(origin: PointModel, to: PointModel) -> (CanvasDrawable?, KnobView?) {
    if origin.distanceTo(to) < 5 { return (nil, nil) }
    
    let newPen = PenModel(points: [to])
    
    model.pens.append(newPen)
    
    let state = PenViewState(model: newPen, isSelected: false)
    let newView = PenViewClass(state: state, modelIndex: model.pens.count - 1)
    newView.delegate = self
    
    return (newView, nil)
  }
  
  func delete(pen: PenView) -> CanvasModel {
    return model.copyWithout(type: .pen, index: pen.modelIndex)
  }
  
  func penView(_ penView: PenView, didUpdate model: PenModel, atIndex index: Int) {
    self.model.pens[index] = model
  }
}
