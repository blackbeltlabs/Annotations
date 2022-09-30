import Foundation

public enum RectKnobType: KnobType {
  case bottomLeft
  case bottomRight
  case topLeft
  case topRight
}

struct RectKnobPair: KnobPair {

  init(bottomLeft: Knob, bottomRight: Knob, topLeft: Knob, topRight: Knob) {
    knobsDict = [
                 .bottomLeft : bottomLeft,
                 .bottomRight : bottomRight,
                 .topLeft : topLeft,
                 .topRight : topRight
                ]
  }
  
  let knobsDict: [RectKnobType: Knob]
  
  var allKnobs: [Knob] {knobsDict.map(\.value)}
}


class RectKnobsCreator: KnobsCreator {
  static func createKnobs(for rectBased: RectBased) -> KnobPair {
    let rect = CGRect.rect(fromPoint: rectBased.origin.cgPoint,
                           toPoint: rectBased.to.cgPoint)
    
    let rectPoints = rect.allPoints
        
    return RectKnobPair(bottomLeft: .fromCenterPoint(point: rectPoints.leftBottom),
                        bottomRight: .fromCenterPoint(point: rectPoints.rightBottom),
                        topLeft: .fromCenterPoint(point: rectPoints.leftTop),
                        topRight: .fromCenterPoint(point: rectPoints.rightTop))
  }
  
  func createKnobs(for annotation: Rect) -> KnobPair {
    return Self.createKnobs(for: annotation)
  }
}
