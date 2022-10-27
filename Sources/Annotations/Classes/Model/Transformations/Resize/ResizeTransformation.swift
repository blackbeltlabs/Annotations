import Foundation

protocol ResizeTransformation {
  associatedtype F: AnnotationModel
  associatedtype T: KnobType
  
  func resizingStarted(_ annotation: F, knobType: T, point: CGPoint)
  
  func resizedAnnotation(_ annotation: F, knobType: T, delta: CGVector) -> F
}



extension ResizeTransformation {
  func resizingStarted(_ annotation: F, knobType: T, point: CGPoint) {
    
  }
}
