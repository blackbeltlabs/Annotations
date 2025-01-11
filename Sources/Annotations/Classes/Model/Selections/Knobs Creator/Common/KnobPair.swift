import Foundation

public protocol KnobType: Sendable {
  
}

protocol KnobPair: Sendable {
  var allKnobsWithType: [(KnobType, Knob)] { get }
  var allKnobs: [Knob] { get }
}
