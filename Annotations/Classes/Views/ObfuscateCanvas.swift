import Foundation

protocol ObfuscateCanvas: class, ObfuscateViewDelegate {
  var model: CanvasModel { get set }
  func add(_ item: CanvasDrawable)
}

extension ObfuscateCanvas {
  func redrawObfuscates(model: CanvasModel) {
    for (index, model) in model.obfuscates.enumerated() {
      let state = ObfuscateViewState(model: model, isSelected: false)
      let view = ObfuscateViewClass(state: state, modelIndex: index, color: model.color)
      view.delegate = self
      add(view)
    }
  }
  
  func createObfuscateView(origin: PointModel, to: PointModel, color: ModelColor) -> (CanvasDrawable?, KnobView?) {
    if origin.distanceTo(to) < 5 {
      return (nil, nil)
    }
    
    let newRect = RectModel(origin: origin, to: to, color: color)
    model.obfuscates.append(newRect)
    
    let state = ObfuscateViewState(model: newRect, isSelected: false)
    let newView = ObfuscateViewClass(state: state,
                                     modelIndex: model.obfuscates.count - 1,
                                     color: color)
    newView.delegate = self
    
    let selectedKnob = newView.knobAt(rectPoint: .to)
    
    return (newView, selectedKnob)
  }
  
  func delete(obfuscate: ObfuscateView) -> CanvasModel {
    return model.copyWithout(type: .obfuscate, index: obfuscate.modelIndex)
  }
  
  func obfuscateView(_ view: ObfuscateView, didUpdate model: RectModel, atIndex index: Int) {
    self.model.obfuscates[index] = model
  }
}
