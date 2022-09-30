import Foundation

class ResizeArrowTransformation: ResizeTransformation {
  func resizedAnnotation(_ annotation: Arrow, knobType: ArrowKnobType, delta: CGVector) -> Arrow {
    var updatedAnnotation = annotation
    switch knobType {
    case .from:
      updatedAnnotation.origin = annotation.origin.applyingDelta(vector: delta)
    case .to:
      updatedAnnotation.to = annotation.to.applyingDelta(vector: delta)
    }
    return updatedAnnotation
  }
}
