import Foundation

public enum TextKnobType: KnobType {
  case resizeLeft
  case resizeRight
  case bottomScale
}

struct TextKnobPair: KnobPair {

  init(resizeLeft: Knob, resizeRight: Knob, bottomScale: Knob) {
    knobsDict = [
                 .resizeLeft : resizeLeft,
                 .resizeRight : resizeRight,
                 .bottomScale : bottomScale
                ]
  }
  
  let knobsDict: [TextKnobType: Knob]
  
  var allKnobs: [Knob] {knobsDict.map(\.value)}
  
  var allKnobsWithType: [(KnobType, Knob)] {
    knobsDict.map { ($0.key, $0.value ) }
  }
}


class TextKnobsCreator: KnobsCreator {
  func createKnobs(for annotation: Text) -> KnobPair {
    let selectionFrame = TextBordersCreator.bordersRect(for: annotation)
    
    let leftCenterPoint = CGPoint(x: selectionFrame.minX, y: selectionFrame.midY)
    let rightCenterPoint = CGPoint(x: selectionFrame.maxX, y: selectionFrame.midY)
    let bottomCenterPoint = CGPoint(x: selectionFrame.midX, y: selectionFrame.maxY)
    
    return TextKnobPair(resizeLeft: .fromCenterPoint(point: leftCenterPoint,
                                                     sizePart: 11.0,
                                                     id: annotation.id + "_0",
                                                     borderColor: .textSideKnobBorderColor),
                        resizeRight: .fromCenterPoint(point: rightCenterPoint,
                                                      sizePart: 11.0,
                                                      id: annotation.id + "_1",
                                                      borderColor: .textSideKnobBorderColor),
                        bottomScale: .fromCenterPoint(point: bottomCenterPoint,
                                                      sizePart: 12.0,
                                                      id: annotation.id + "_2",
                                                      borderColor: .textScaleKnobBorderColor))
  }
}
