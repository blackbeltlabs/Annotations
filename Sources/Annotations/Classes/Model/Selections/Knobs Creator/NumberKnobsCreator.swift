
import Foundation

class NumberKnobsCreator: KnobsCreator {
  func createKnobs(for annotation: Number) -> KnobPair {
    return RectKnobsCreator.createKnobs(for: annotation)
  }
}
