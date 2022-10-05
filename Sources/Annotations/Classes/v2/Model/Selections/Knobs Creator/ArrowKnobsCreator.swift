import Foundation

public enum ArrowKnobType: KnobType {
  case from
  case to
}

struct ArrowKnobPair: KnobPair {
  
  init(from: Knob, to: Knob) {
    knobsDict = [.from : from,
                 .to : to]
  }

  let knobsDict: [ArrowKnobType: Knob]
  var allKnobs: [Knob] { knobsDict.map(\.value) }
  
  var allKnobsWithType: [(KnobType, Knob)] { knobsDict.map { ($0.key, $0.value ) } }
}

class ArrowKnobsCreator: KnobsCreator {
  func createKnobs(for annotation: Arrow) -> KnobPair {
    ArrowKnobPair(from: .fromCenterPoint(point: annotation.origin.cgPoint),
                  to:  .fromCenterPoint(point: annotation.to.cgPoint))
  }
}
