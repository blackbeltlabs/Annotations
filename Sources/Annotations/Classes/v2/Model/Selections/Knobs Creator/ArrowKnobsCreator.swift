import Foundation

struct ArrowKnobPair: KnobPair {
  let from: Knob
  let to: Knob
  
  var allKnobs: [Knob] { [from, to] }
}

class ArrowKnobsCreator: KnobsCreator {
  func createKnobs(for annotation: Arrow) -> KnobPair {
    ArrowKnobPair(from: .fromCenterPoint(point: annotation.origin.cgPoint),
                  to:  .fromCenterPoint(point: annotation.to.cgPoint))
  }
}
