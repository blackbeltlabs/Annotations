import Foundation

protocol TextCanvas: TextAnnotationCanvas, TextViewDelegate where Self: CanvasView {
  var selectedItem: CanvasDrawable? { get set }
  var model: CanvasModel { get set }
}

extension TextCanvas {
  public func createTextView(text: String = "",
                             origin: PointModel,
                             params: TextParams,
                             zPosition: CGFloat) -> TextViewAnnotation {
    let newTextView = createTextAnnotation(text: text,
                                           location: origin.cgPoint,
                                           textParams: params)
    newTextView.delegate = self
    
    let textModel = TextModel(origin: origin,
                              text: text,
                              textParams: params,
                              index: model.elements.count + 1)
    model.texts.append(textModel)
    
    let state = TextViewState(model: textModel, isSelected: false)
    let modelIndex = model.texts.count - 1
    
    let nsColor = params.foregroundColor ?? ModelColor.orange
    
    let newView = TextViewAnnotation(state: state,
                                     modelIndex: modelIndex,
                                     globalIndex: textModel.index,
                                     view: newTextView,
                                     color: nsColor)
    newView.delegate = self

    return newView
  }
  
  func createTextView(textModel: TextModel, index: Int) -> TextViewAnnotation {
    let newTextView = createTextAnnotation(modelable: textModel)
    
    
    newTextView.delegate = self
    
    let state = TextViewState(model: textModel, isSelected: false)
    
    let nsColor = textModel.style.foregroundColor ?? .orange
    
    let newView = TextViewAnnotation(state: state,
                                     modelIndex: index,
                                     globalIndex: textModel.index,
                                     view: newTextView,
                                     color: nsColor)
    newView.delegate = self
  
    
    return newView
  }
	
	
  func redrawTexts(model: TextModel, canvas: CanvasModel) {
    guard let index = canvas.texts.firstIndex(of: model) else { return }
    
    let view = createTextView(textModel: model, index: index)
    view.delegate = self
    add(view, zPosition: model.zPosition)
    view.updateFrame(with: model)
    view.deselect()
    view.isSelected = false
  }
}

// TextViewDelegate
extension TextCanvas {
  func textView(_ arrowView: TextViewAnnotation, didUpdate model: TextModel, atIndex index: Int) {
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
    // update zPosition of textAnnotation to the highest one if selected
    textAnnotation.layer?.zPosition = generateZPosition()
  }
  
  public func textAnnotationDidDeselect(textAnnotation: TextAnnotation) {
    if textAnnotation.text.count == 0 {
      textAnnotation.delete()
    }
  }
  
  public func textAnnotationDidEdit(textAnnotation: TextAnnotation) {
    delegate?.canvasView(self, didEdit: textAnnotation)
  }
  
  public func textAnnotationDidMove(textAnnotation: TextAnnotation) {
    
  }
  
  public func textAnnotationDidStartEditing(textAnnotation: TextAnnotation) {
    delegate?.canvasView(self, didStartEditing: textAnnotation)
  }
  
  public func textAnnotationDidEndEditing(textAnnotation: TextAnnotation) {
    delegate?.canvasView(self, didEndEditing: textAnnotation)
  }
  
  public func emojiPickerPresentationStateChanged(_ isPresented: Bool) {
    delegate?.canvasView(self, emojiPickerPresentationStateChanged: isPresented)
  }
}
