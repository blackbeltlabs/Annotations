//
//  TextCanvas.swift
//  Annotations
//
//  Created by Mirko on 5/22/19.
//

import Foundation

protocol TextCanvas: TextAnnotationCanvas, TextViewDelegate where Self: CanvasView {
  var selectedItem: CanvasDrawable? { get set }
  var model: CanvasModel { get set }
}

extension TextCanvas {
  func createTextView(text: String = "", origin: PointModel, params: TextParams) -> TextViewDrawable {
    let newTextView = createTextAnnotation(text: text,
                                           location: origin.cgPoint,
                                           textParams: TextParams())
    newTextView.delegate = self
    
    let textModel = TextModel(origin: origin,
                              text: text,
                              textParams: params,
                              index: model.elements.count + 1)
    model.texts.append(textModel)
    
    let state = TextViewState(model: textModel, isSelected: false)
    let modelIndex = model.texts.count - 1
    
    let nsColor = (params.foregroundColor ?? TextColor.orange).modelColor
    
    let newView = TextViewClass(state: state,
                                modelIndex: modelIndex,
                                globalIndex: textModel.index,
                                view: newTextView,
                                color: nsColor)
    newView.delegate = self

    return newView
  }
  
  func createTextView(textModel: TextModel, index: Int) -> TextViewDrawable {
    let newTextView = createTextAnnotation(modelable: textModel)
    
    newTextView.delegate = self
    
    let state = TextViewState(model: textModel, isSelected: false)
    
    let newView = TextViewClass(state: state,
                                modelIndex: index,
                                globalIndex: textModel.index,
                                view: newTextView,
                                color: .defaultColor())
    newView.delegate = self
    
    return newView
  }
	
	
  func redrawTexts(model: TextModel, canvas: CanvasModel) {
    guard let index = canvas.texts.firstIndex(of: model) else { return }
    
    let view = createTextView(textModel: model, index: index)
    view.delegate = self
    add(view)
    view.updateFrame(with: model)
    view.deselect()
    view.isSelected = false
  }
}

// TextViewDelegate
extension TextCanvas {
  func textView(_ arrowView: TextViewDrawable, didUpdate model: TextModel, atIndex index: Int) {
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
