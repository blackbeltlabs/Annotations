import Foundation

protocol PenCanvas: class, PenViewDelegate {
  var model: CanvasModel { get set }
  func add(_ item: CanvasDrawable, zPosition: CGFloat?)
}

extension PenCanvas {
  func redrawPen(model: PenModel, canvas: CanvasModel) {
    guard let modelIndex = canvas.pens.firstIndex(of: model) else { return }
    let state = PenViewState(model: model, isSelected: false)
    let view = PenView(state: state,
                       modelIndex: modelIndex,
                       globalIndex: model.index,
                      color: model.color)
    view.delegate = self
    add(view, zPosition: model.zPosition)
  }
  
  func createPenView(origin: PointModel, to: PointModel, color: ModelColor) -> (CanvasDrawable?, KnobView?) {
    if origin.distanceTo(to) < 5 { return (nil, nil) }
    
    let newPen = PenModel(index: model.elements.count + 1,
                          points: [to], color: color)
    model.pens.append(newPen)
    
    let state = PenViewState(model: newPen, isSelected: false)
    let newView = PenView(state: state,
                          modelIndex: model.pens.count - 1,
                          globalIndex: newPen.index,
                          color: color)
    newView.delegate = self
    
    return (newView, nil)
  }
  
  func delete(pen: PenView) -> CanvasModel {
    return model.copyWithout(type: .pen, index: pen.modelIndex)
  }
  
  func penView(_ penView: PenView, didUpdate model: PenModel, atIndex index: Int) {
    self.model.pens[index] = model
  }
}
