import Cocoa
import TextAnnotation

protocol TextViewDelegate {
  func textView(_ textView: TextView, didUpdate model: TextModel, atIndex index: Int)
}

struct TextViewState {
  var model: TextModel
  var isSelected: Bool
}

protocol TextView: CanvasDrawable {
  var delegate: TextViewDelegate? { get set }
  var state: TextViewState { get set }
  var modelIndex: Int { get set }
  var view: TextAnnotation { get }
  func updateFrame(with action: TextAnnotationModelable)
  func deselect()
}

extension TextView {
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
  
  func addTo(canvas: CanvasView) {
    guard let textCanvas = canvas as? TextCanvas else {
      return
    }
    
    view.addTo(canvas: textCanvas)
    
   // view.startEditing()
    
   // delegate?.textView(self, didUpdate: model, atIndex: modelIndex)
  }
  
  func removeFrom(canvas: CanvasView) {
    view.delete()
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
}

class TextViewClass: TextView {
  
  var state: TextViewState {
    didSet {
      render(state: state, oldState: oldValue)
    }
  }
  
  var delegate: TextViewDelegate?
  
  let view: TextAnnotation
  
  var modelIndex: Int
  let color: NSColor
  
  init(state: TextViewState, modelIndex: Int, view: TextAnnotation, color: ModelColor) {
    self.state = state
    self.modelIndex = modelIndex
    self.view = view
    self.color = NSColor.color(from: color)
    view.textUpdateDelegate = self
  }
}

extension TextViewClass: TextAnnotationUpdateDelegate {
  func textAnnotationUpdated(textAnnotation: TextAnnotation,
                             modelable: TextAnnotationModelable) {
    
    let model = TextModel(origin: PointModel(x: Double(modelable.frame.origin.x),
                                             y: Double(modelable.frame.origin.y)),
                          text: modelable.text,
                          frame: modelable.frame,
                          fontName: modelable.fontName,
                          fontSize: modelable.fontSize,
                          color: modelable.color)
    
    delegate?.textView(self, didUpdate: model, atIndex: modelIndex)
  }
}
