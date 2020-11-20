import Foundation

protocol NumberCanvas: CanvasDrawableDelegate {
  var model: CanvasModel { get set }
  func add(_ item: CanvasDrawable)
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
    add(view)
  }
  
  func createNumberView(origin: PointModel, color: ModelColor) -> (CanvasDrawable?, KnobView?) {

    let newNumber = NumberModel(index: model.elements.count + 1,
                                point: origin,
                                number: UInt(model.numbers.count + 1),
                                color: color)
  
    model.numbers.append(newNumber)
    
    let state = ViewState<NumberModel>(model: newNumber, isSelected: false)
    
    let newView = NumberView(state: state,
                             modelIndex: model.numbers.count - 1,
                             globalIndex: newNumber.index,
                             color: color)
    
    newView.delegate = self
    
    return (newView, nil)
  }
  
  
  func delete(number: NumberView) -> CanvasModel {
    return model.copyWithout(type: .number, index: number.modelIndex)
  }
  
  func drawableView(_ view: CanvasDrawable, didUpdate model: Any, atIndex index: Int) {
    self.model.numbers[index] = model as! NumberModel
  }
  /*
  func redrawPen(model: PenModel, canvas: CanvasModel) {
    guard let modelIndex = canvas.pens.firstIndex(of: model) else { return }
    let state = PenViewState(model: model, isSelected: false)
    let view = PenView(state: state,
                       modelIndex: modelIndex,
                       globalIndex: model.index,
                      color: model.color)
    view.delegate = self
    add(view)
  }
  
 
 
  
  func penView(_ penView: PenView, didUpdate model: PenModel, atIndex index: Int) {
    self.model.pens[index] = model
  }
 
 */
}
