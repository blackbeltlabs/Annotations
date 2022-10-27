import Foundation

public protocol KnobType {
  
}

protocol KnobPair {
  var allKnobsWithType: [(KnobType, Knob)] { get }
  var allKnobs: [Knob] { get }
}
