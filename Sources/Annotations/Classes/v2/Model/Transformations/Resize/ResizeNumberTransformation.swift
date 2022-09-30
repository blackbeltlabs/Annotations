import Foundation

class ResizeNumberTransformation: ResizeTransformation {
  func resizedAnnotation(_ annotation: Number, knobType: RectKnobType, delta: CGVector) -> Number {
    ResizeRectTransformation.resizedRectBased(annotation, knobType: knobType, delta: delta)
  }
}
