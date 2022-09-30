import Foundation

struct RectKnobPair: KnobPair {
  let bottomLeft: Knob
  let bottomRight: Knob
  let topLeft: Knob
  let topRight: Knob
  
  var allKnobs: [Knob] { [bottomLeft, bottomRight, topLeft, topRight] }
}


class RectKnobsCreator: KnobsCreator {
  static func createKnobs(for rectBased: RectBased) -> KnobPair {
    let rect = CGRect.rect(fromPoint: rectBased.origin.cgPoint,
                           toPoint: rectBased.to.cgPoint)
    
    return RectKnobPair(bottomLeft: .fromCenterPoint(point: .init(x: rect.minX, y: rect.maxY)),
                        bottomRight: .fromCenterPoint(point: .init(x: rect.maxX, y: rect.maxY)),
                        topLeft: .fromCenterPoint(point: .init(x: rect.minX, y: rect.minY)),
                        topRight: .fromCenterPoint(point: .init(x: rect.maxX, y: rect.minY)))      
  }
  
  func createKnobs(for annotation: Rect) -> KnobPair {
    return Self.createKnobs(for: annotation)
  }
}
