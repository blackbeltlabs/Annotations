//
//  TextCanvas.swift
//  Annotations
//
//  Created by Mirko on 5/22/19.
//

import Foundation
import TextAnnotation

protocol TextCanvas: TextAnnotationCanvas, TextAnnotationDelegate {
  var selectedItem: CanvasDrawable? { get set }
  var model: CanvasModel { get set }
}

extension TextCanvas {
  func createTextView(origin: PointModel) -> TextView {
    let newTextView = createTextAnnotation(text: "", location: origin.cgPoint)
    newTextView.delegate = self
    
    let textModel = TextModel(origin: origin, text: "")
    
    let state = TextViewState(model: textModel, isSelected: false)
    
    let newView = TextViewClass(state: state, modelIndex: model.texts.count - 1)
    newView.view = newTextView
    
    return newView
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
}
