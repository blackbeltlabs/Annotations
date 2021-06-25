import Foundation

protocol RectCanvas: AnyObject, RectViewDelegate {
  var model: CanvasModel { get set }
  func add(_ item: CanvasDrawable, zPosition: CGFloat?)
}

extension RectCanvas {
  func redrawRect(model: RectModel, canvas: CanvasModel) {
    guard let modelIndex = canvas.rects.firstIndex(of: model) else { return }
    let state = RectViewState(model: model, isSelected: false)
    let view = RectView(state: state,
                        modelIndex: modelIndex,
                        globalIndex: model.index,
                        color: model.color)
    view.delegate = self
    add(view, zPosition: model.zPosition)
  }
  
  func createRectView(origin: PointModel, to: PointModel, color: ModelColor) -> (CanvasDrawable?, KnobView?) {
    if origin.distanceTo(to) < 5 {
      return (nil, nil)
    }
    
    let newRect = RectModel(index: model.elements.count + 1,
                            origin: origin,
                            to: to,
                            color: color)
    
    model.rects.append(newRect)
    
    let state = RectViewState(model: newRect, isSelected: false)
    let newView = RectView(state: state,
                           modelIndex: model.rects.count - 1,
                           globalIndex: model.index,
                           color: color)
    newView.delegate = self
    
    let selectedKnob = newView.knobAt(rectPoint: .to)
    
    return (newView, selectedKnob)
  }
  
  func delete(rect: RectView) -> CanvasModel {
    return model.copyWithout(type: .rect, index: rect.modelIndex)
  }
  
  func rectView(_ rectView: RectView, didUpdate model: RectModel, atIndex index: Int) {
    self.model.rects[index] = model
  }
}
