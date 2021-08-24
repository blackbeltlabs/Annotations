import Foundation

protocol NumberCanvas: AnyCanvas, CanvasDrawableDelegate {

}

extension NumberCanvas {
  
  func redrawNumber(model: NumberModel, canvas: CanvasModel) {
    guard let modelIndex = canvas.numbers.firstIndex(of: model) else { return }
    let state = ViewState<NumberModel>(model: model, isSelected: false)
    let view = NumberView(state: state,
                          modelIndex: modelIndex,
                          globalIndex: model.index,
                          color: model.color)
    view.delegate = self
    add(view, zPosition: model.zPosition)
  }
  
  func createNumberView(origin: PointModel, color: ModelColor) -> (CanvasDrawable?, KnobView?) {

    let newNumber = NumberModel.modelWithRadius(index: model.elements.count + 1,
                                                centerPoint: origin,
                                                radius: NumberModel.defaultRadius,
                                                number: UInt(model.numbers.count + 1),
                                                color: color)
  
    model.numbers.append(newNumber)
    
    let state = ViewState<NumberModel>(model: newNumber, isSelected: false)
    
    let newView = NumberView(state: state,
                             modelIndex: model.numbers.count - 1,
                             globalIndex: newNumber.index,
                             color: color)
    
    newView.delegate = self
    
    lastUpdatedModelId = newNumber.id
    
    return (newView, nil)
  }
  
  
  func delete(number: NumberView) -> CanvasModel {
    return model.copyWithout(type: .number, index: number.modelIndex)
  }
  
  func drawableView(_ view: CanvasDrawable, didUpdate model: Any, atIndex index: Int) {
    self.model.numbers[index] = model as! NumberModel
  }
}
