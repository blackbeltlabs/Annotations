import Foundation

protocol ResizeTransformation {
  associatedtype F: AnnotationModel
  associatedtype T: KnobType
  func resizedAnnotation(_ annotation: F, knobType: T, delta: CGVector) -> F
}


