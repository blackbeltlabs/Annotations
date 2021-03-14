import Cocoa

protocol TextViewDelegate {
  func textView(_ textView: TextViewAnnotation, didUpdate model: TextModel, atIndex index: Int)
}

struct TextViewState {
  var model: TextModel
  var isSelected: Bool
}

class TextViewAnnotation: CanvasDrawable {
  var state: TextViewState {
    didSet {
      render(state: state, oldState: oldValue)
    }
  }
  
  var delegate: TextViewDelegate?
  let view: TextAnnotation
  var globalIndex: Int
  var modelIndex: Int
  let color: NSColor?
  
  init(state: TextViewState, modelIndex: Int, globalIndex: Int, view: TextAnnotation, color: ModelColor) {
    self.state = state
    self.modelIndex = modelIndex
    self.view = view
    self.color = NSColor.color(from: color)
    self.globalIndex = globalIndex
    view.textUpdateDelegate = self
  }
  
  static var modelType: CanvasItemType { return .text }

  var model: TextModel { return state.model }
  
  var isSelected: Bool {
    get { return state.isSelected }
    set { state.isSelected = newValue }
  }
  
  func knobAt(point: PointModel) -> KnobView? {
    return nil
  }
  
  func contains(point: PointModel) -> Bool {
    return false
  }
  
  func addTo(canvas: CanvasView, zPosition: CGFloat?) {
    view.addTo(canvas: canvas, zPosition: zPosition)
  }
  
  func removeFrom(canvas: CanvasView) {
    view.delete()
  }
  
  
  func bringToTop(canvas: CanvasView) {
   
  }
  
  func dragged(from: PointModel, to: PointModel) {
    
  }
  
  func draggedKnob(_ knob: KnobView, from: PointModel, to: PointModel) {
    
  }
  
  func render(state: TextViewState, oldState: TextViewState? = nil) {
    
  }
  
  func updateFrame(with action: TextAnnotationModelable) {
    view.updateFrame(with: action)
  }
  
  func deselect() {
    isSelected = false
    view.deselect()
  }
  
  func doInitialSetupOnCanvas() {
    view.startEditing()
  }
  
  func updateColor(_ color: NSColor) {
    let model = self.model.copyWithColor(color: color.annotationModelColor)
    view.updateColor(with: color)
    delegate?.textView(self, didUpdate: model, atIndex: modelIndex)
  }
}

extension TextViewAnnotation: TextAnnotationUpdateDelegate {
  func textAnnotationUpdated(textAnnotation: TextAnnotation,
                             modelable: TextAnnotationModelable) {
    
    let model = TextModel(origin: PointModel(index: globalIndex,
                                             x: Double(modelable.frame.origin.x),
                                             y: Double(modelable.frame.origin.y)),
                          text: modelable.text,
                          frame: modelable.frame,
                          textParams: modelable.style,
                          index: globalIndex,
                          legibilityEffectEnabled: modelable.legibilityEffectEnabled)
    
    delegate?.textView(self, didUpdate: model, atIndex: modelIndex)
  }
}
