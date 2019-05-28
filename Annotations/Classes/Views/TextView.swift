import Cocoa
import TextAnnotation

protocol TextViewDelegate {
  func textView(_ arrowView: TextView, didUpdate model: TextModel, atIndex index: Int)
}

struct TextViewState {
  var model: TextModel
  var isSelected: Bool
}

protocol TextView: CanvasDrawable {
  var delegate: TextViewDelegate? { get set }
  var state: TextViewState { get set }
  var view: TextAnnotation! { get set }
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
    
    view.startEditing()
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
}

class TextViewClass: TextView {
  var state: TextViewState {
    didSet {
      render(state: state, oldState: oldValue)
    }
  }
  
  var delegate: TextViewDelegate?
  
  var view: TextAnnotation!
  
  var modelIndex: Int
  
  init(state: TextViewState, modelIndex: Int) {
    self.state = state
    self.modelIndex = modelIndex
  }
}
