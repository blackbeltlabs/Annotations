import Foundation
import CoreGraphics

protocol MouseInteractionHandlerDataSource: AnyObject {
  var annotations: [AnnotationModel] { get }
  
  func update(model: AnnotationModel)
  func select(model: AnnotationModel)
  func deselect()
  
  var selectedAnnotation: AnnotationModel? { get }
}

private struct PossibleMovement {
  let lastDraggedPoint: CGPoint
  let type: PossibleMovementType
  let modifiedAnnotation: AnnotationModel?
  
  init(lastDraggedPoint: CGPoint,
       type: PossibleMovementType,
       modifiedAnnotation: AnnotationModel? = nil) {
    self.lastDraggedPoint = lastDraggedPoint
    self.type = type
    self.modifiedAnnotation = modifiedAnnotation
  }
  
  func copy(with newDraggedPoint: CGPoint,
            modifiedAnnotation: AnnotationModel?) -> PossibleMovement {
    .init(lastDraggedPoint: newDraggedPoint,
          type: type,
          modifiedAnnotation: modifiedAnnotation)
  }
}

private enum PossibleMovementType {
  case annotation
  case knob(KnobType)
}


class MouseInteractionHandler {
  
  weak var dataSource: MouseInteractionHandlerDataSource?
  
  private var possibleMovement: PossibleMovement?
  
  func handleMouseDown(point: CGPoint) {
    guard let dataSource = dataSource else { return }
   
    let annotations = dataSource.annotations.sorted(by: { $0.zPosition > $1.zPosition })
    
    // if annotation was selected before
    // try to select knobs
    if let selectedAnnotation = dataSource.selectedAnnotation,
       let knobPair = KnobsFactory.knobPair(for: selectedAnnotation) {
      
      for (knobType, knob) in knobPair.allKnobsWithType {
        if knob.frameRect.contains(point) {
          possibleMovement = .init(lastDraggedPoint: point,
                                   type: .knob(knobType))
          ResizeTransformationFactory.resizingStarted(selectedAnnotation, knob: knobType, point: point)
          return
        }
      }
    }
    
    for annotation in annotations {
      let selectionPath = SelectionPathFactory.selectionPath(for: annotation)
      if let selectionPath, selectionPath.contains(point) {
        dataSource.select(model: annotation)
        possibleMovement = .init(lastDraggedPoint: point,
                                 type: .annotation)
        return
      }
    }
    
    dataSource.deselect()
    
    possibleMovement = nil
  }
  
  func handleMouseDragged(point: CGPoint) {
    guard let possibleMovement else { return }
    let lastDraggedPoint = possibleMovement.lastDraggedPoint
    
    guard let selectedAnnotation = dataSource?.selectedAnnotation else {
      return
    }
    
    let delta = CGVector(dx: point.x - lastDraggedPoint.x,
                         dy: point.y - lastDraggedPoint.y)
    
    switch possibleMovement.type {
    case .annotation:
      // move selected annotation if needed
        let updatedAnnotation = MovementTransformation.movedAnnotation(selectedAnnotation, delta: delta)
        dataSource?.select(model: updatedAnnotation)

      self.possibleMovement = possibleMovement.copy(with: point,
                                                    modifiedAnnotation: updatedAnnotation)
    case .knob(let knobType):
      let updatedAnnotation = ResizeTransformationFactory.resizedAnnotation(annotation: selectedAnnotation,
                                                                            knob: knobType,
                                                                            delta: delta)
      
      dataSource?.select(model: updatedAnnotation)
      
      
      self.possibleMovement = possibleMovement.copy(with: point,
                                                    modifiedAnnotation: updatedAnnotation)
    }
  }
  
  func handleMouseUp(point: CGPoint) {
    if let modifiedAnnotation = possibleMovement?.modifiedAnnotation {
      dataSource?.update(model: modifiedAnnotation)
    }
    
    possibleMovement = nil
  }
}
