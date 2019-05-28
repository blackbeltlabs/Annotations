import Foundation

protocol ObfuscateCanvas: RectCanvas {
  var model: CanvasModel { get set }
  func add(_ item: CanvasDrawable)
}

extension ObfuscateCanvas {
  func redrawObfuscates(model: CanvasModel) {
    for (index, model) in model.obfuscates.enumerated() {
      let state = RectViewState(model: model, isSelected: false)
      let view = ObfuscateViewClass(state: state, modelIndex: index)
      view.delegate = self
      add(view)
    }
  }
  
  func createObfuscateView(origin: PointModel, to: PointModel) -> (CanvasDrawable?, KnobView?) {
    if origin.distanceTo(to) < 5 {
      return (nil, nil)
    }
    
    let newRect = RectModel(origin: origin, to: to)
    model.obfuscates.append(newRect)
    
    let state = RectViewState(model: newRect, isSelected: false)
    let newView = ObfuscateViewClass(state: state, modelIndex: model.obfuscates.count - 1)
    newView.delegate = self
    
    let selectedKnob = newView.knobAt(rectPoint: .to)
    
    return (newView, selectedKnob)
  }
  
  func delete(obfuscate: RectView) -> CanvasModel {
    return model.copyWithout(type: .obfuscate, index: obfuscate.modelIndex)
  }
  
  func rectView(_ rectView: RectView, didUpdate model: RectModel, atIndex index: Int) {
    guard rectView.modelType == .obfuscate else {
      return
    }
    
    self.model.obfuscates[index] = model
  }
}
