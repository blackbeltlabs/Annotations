import Foundation


protocol ArrowCanvas: AnyCanvas, ArrowViewDelegate {

}

extension ArrowCanvas {
  func redrawArrow(model: ArrowModel, canvas: CanvasModel) {
    guard let modelIndex = canvas.arrows.firstIndex(of: model) else { return }
    let state = ArrowViewState(model: model, isSelected: false)
    let view = ArrowView(state: state,
                         modelIndex: modelIndex,
                         globalIndex: model.index,
                         color: model.color)
    view.delegate = self
    add(view, zPosition: model.zPosition)
  }
  
  func createArrowView(origin: PointModel, to: PointModel, color: ModelColor) -> (CanvasDrawable?, KnobView?) {
    if origin.distanceTo(to) < 10 {
      return (nil, nil)
    }
    
    let newArrow = ArrowModel(index: model.elements.count + 1,
                              origin: origin,
                              to: to,
                              color: color)
    
    model.arrows.append(newArrow)
    
    let state = ArrowViewState(model: newArrow, isSelected: false)
    let newView = ArrowView(state: state,
                            modelIndex: model.arrows.count - 1,
                            globalIndex: newArrow.index,
                            color: color)
    newView.delegate = self
    
    let selectedKnob = newView.knobAt(arrowPoint: .to)
    
    return (newView, selectedKnob)
  }
  
  func delete(arrow: ArrowView) -> CanvasModel {
    return model.copyWithout(type: .arrow, index: arrow.modelIndex)
  }
  
  func arrowView(_ arrowView: ArrowView, didUpdate model: ArrowModel, atIndex index: Int) {
    lastUpdatedModelId = model.id
    self.model.arrows[index] = model
  }
}
