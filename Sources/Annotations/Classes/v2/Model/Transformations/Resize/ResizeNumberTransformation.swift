import Foundation

class ResizeNumberTransformation: ResizeTransformation {
  
  func resizingStarted(_ annotation: Number, knobType: RectKnobType, point: CGPoint) {
    ResizeRectTransformation.startResizingRectBased(annotation, knobType: knobType, point: point)
  }
  
  func resizedAnnotation(_ annotation: Number, knobType: RectKnobType, delta: CGVector) -> Number {
    let number = ResizeRectTransformation.resizedRectBased(annotation,
                                                           knobType: knobType,
                                                           delta: delta,
                                                           keepSquare: true)
    
    let rect = CGRect(fromPoint: number.to.cgPoint,
                      toPoint: number.origin.cgPoint)
    
    guard rect.width > 15.0 && rect.height > 15.0 else {
      return annotation
    }

    
    // FIXME: - Maybe use older approach hare
    if ceil(rect.width) != ceil(rect.height) {
      return number
    }

    return number
  }
}
