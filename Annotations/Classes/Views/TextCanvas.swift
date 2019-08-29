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
	func createTextView(text: String = "", origin: PointModel) -> TextView {
    let newTextView = createTextAnnotation(text: text, location: origin.cgPoint)
    newTextView.delegate = self
    
    let textModel = TextModel(origin: origin,
															text: text,
															actions: [])
    model.texts.append(textModel)
    
    let state = TextViewState(model: textModel, isSelected: false)
    
    let newView = TextViewClass(state: state, modelIndex: model.texts.count - 1)
    newView.view = newTextView
    
    return newView
  }
	
  func createTextView(text: String, origin: PointModel, index: Int) -> TextView {
    let newTextView = createTextAnnotation(text: text, location: origin.cgPoint)
    newTextView.delegate = self
    
    let textModel = TextModel(origin: origin,
                              text: text,
                              actions: [])
    
    let state = TextViewState(model: textModel, isSelected: false)
    
    let newView = TextViewClass(state: state, modelIndex: index)
    newView.view = newTextView
    
    return newView
  }
	
	
  func redrawTexts(model: CanvasModel) {
    for (index, model) in model.texts.enumerated() {
      let view = createTextView(text: model.text, origin: model.origin, index: index)
      view.delegate = self
      add(view)
      if let actions = model.actions {
        view.renderAnnotationActions(actions: actions)
      }
      view.deselect()
      view.isSelected = false
    }
  }
}

// TextViewDelegate
extension TextCanvas {
  func textView(_ arrowView: TextView, didUpdate model: TextModel, atIndex index: Int) {
    self.model.texts[index] = model
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
	
  public func textAnnotationDidActionPerformed(textAnnotation: TextAnnotation,
                                               action: TextAnnotationAction,
                                               allActions: [TextAnnotationAction]) {
    let tempTexts = model.texts
    guard let index = model.texts.firstIndex(where: { $0.text == textAnnotation.text }) else {
      return
    }
    
    var canvasModel = self.model
    
    var textModel = model.texts[index]
    
    if let allActions = allActions as? [TextAnnotationActionClass] {
      textModel.actions = allActions
    }
    
    canvasModel.texts[index] = textModel
    
    self.model = canvasModel
    
    delegate?.canvasView(self, didUpdateModel: canvasModel)
    print("Action performed = \(action)")
  }
}
