import Foundation

class ResizeNumberTransformation: ResizeTransformation {
  
  func resizingStarted(_ annotation: Number, knobType: RectKnobType, point: CGPoint) {
    ResizeRectTransformation.startResizingRectBased(annotation, knobType: knobType, point: point)
  }
  
  func resizedAnnotation(_ annotation: Number, knobType: RectKnobType, delta: CGVector) -> Number {
    ResizeRectTransformation.resizedRectBased(annotation, knobType: knobType, delta: delta)
  }
}
