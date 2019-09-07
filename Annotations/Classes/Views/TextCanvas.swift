//
//  TextCanvas.swift
//  Annotations
//
//  Created by Mirko on 5/22/19.
//

import Foundation
import TextAnnotation

protocol TextCanvas: TextAnnotationCanvas, TextViewDelegate, TextAnnotationDelegate where Self: CanvasView {
  var selectedItem: CanvasDrawable? { get set }
  var model: CanvasModel { get set }
}

extension TextCanvas {
  func createTextView(text: String = "", origin: PointModel, color: ModelColor) -> TextView {
    let newTextView = createTextAnnotation(text: text,
                                           location: origin.cgPoint,
                                           color: color.textColor)
    newTextView.delegate = self
    
    let textModel = TextModel(origin: origin,
                              text: text,
                              color: color.textColor)
    model.texts.append(textModel)
    
    let state = TextViewState(model: textModel, isSelected: false)
    
    let modelIndex = model.texts.count - 1
    
    let newView = TextViewClass(state: state,
                                modelIndex: modelIndex,
                                view: newTextView,
                                color: color)
    newView.delegate = self

    return newView
  }
  
  func createTextView(textModel: TextModel, index: Int) -> TextView {
    let newTextView = createTextAnnotation(modelable: textModel)
    
    newTextView.delegate = self
    
    let state = TextViewState(model: textModel, isSelected: false)
    
    let newView = TextViewClass(state: state, modelIndex: index, view: newTextView, color: ModelColor.defaultColor())
    newView.delegate = self
    
    return newView
  }
	
	
  func redrawTexts(model: CanvasModel) {
    for (index, model) in model.texts.enumerated() {
      let view = createTextView(textModel: model, index: index)
      view.delegate = self
      add(view)
      
      view.updateFrame(with: model)
      view.deselect()
      view.isSelected = false
    }
  }
}

// TextViewDelegate
extension TextCanvas {
  func textView(_ arrowView: TextView, didUpdate model: TextModel, atIndex index: Int) {
    guard !model.text.isEmpty else {
      return
    }
    self.model.texts[index] = model
    delegate?.canvasView(self, didUpdateModel: self.model)
  }
}

// TextAnnotationDelegate
extension TextCanvas {
  public func textAnnotationDidSelect(textAnnotation: TextAnnotation) {
    selectedItem = nil
  }
  
  public func textAnnotationDidDeselect(textAnnotation: TextAnnotation) {
    if textAnnotation.text.count == 0 {
      textAnnotation.delete()
    }
  }
  
  public func textAnnotationDidEdit(textAnnotation: TextAnnotation) {
    
  }
  
  public func textAnnotationDidMove(textAnnotation: TextAnnotation) {
    
  }
  
  public func textAnnotationDidStartEditing(textAnnotation: TextAnnotation) {
    delegate?.canvasView(self, didStartEditing: textAnnotation)
  }
  
  public func textAnnotationDidEndEditing(textAnnotation: TextAnnotation) {
    delegate?.canvasView(self, didEndEditing: textAnnotation)
  }
}
