import Foundation

protocol KnobsCreator {
  associatedtype F: AnnotationModel
  func createKnobs(for annotation: F) -> KnobPair
}
