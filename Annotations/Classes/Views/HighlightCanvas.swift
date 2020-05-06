import Foundation

protocol HighlightCanvas: class, HighlightViewDelegate {
  var model: CanvasModel { get set }
  func add(_ item: CanvasDrawable)
}

extension HighlightCanvas {
  func redrawHighlight(model: HighlightModel, canvas: CanvasModel) {
    guard let modelIndex = canvas.highlights.firstIndex(of: model) else { return }
    let state = HighlightViewState(model: model, isSelected: false)
    let rects = canvas.highlights.map { $0.rect }
    let view = HighlightViewClass(state: state,
                                  modelIndex: modelIndex,
                                  globalIndex: model.index,
                                  maskRects: rects,
                                  color: model.color)
    view.delegate = self
    add(view)
  }
  
  func createHighlightView(origin: PointModel, to: PointModel, color: ModelColor, size: CGSize) -> (CanvasDrawable?, KnobView?) {
    if origin.distanceTo(to) < 5 {
      return (nil, nil)
    }
    
    let newRect = HighlightModel(index: model.elements.count + 1,
                            origin: origin, to: to, color: color)
    let rects = model.highlights.map { $0.rect }
    model.highlights.append(newRect)
    
    let state = HighlightViewState(model: newRect, isSelected: false)
    let newView = HighlightViewClass(state: state,
                                     modelIndex: model.highlights.count - 1,
                                     globalIndex: newRect.index,
                                     maskRects: rects,
                                     color: color)
    newView.delegate = self
    
    let selectedKnob = newView.knobAt(rectPoint: .to)
    
    return (newView, selectedKnob)
  }
  
  func delete(highlight: HighlightView) -> CanvasModel {
    return model.copyWithout(type: .highlight, index: highlight.modelIndex)
  }
  
  func highlightView(_ highlightView: HighlightView,
                     didUpdate model: HighlightModel,
                     atIndex index: Int) {
    self.model.highlights[index] = model
  }
  
  func highlightViewRects() -> [CGRect] {
    return model.highlights.map { $0.rect}
  }
}
