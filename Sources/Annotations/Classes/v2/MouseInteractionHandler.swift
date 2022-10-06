import Foundation
import CoreGraphics

protocol MouseInteractionHandlerDataSource: AnyObject {
  var annotations: [AnnotationModel] { get }
  
  func update(model: AnnotationModel)
  
  var selectedAnnotation: AnnotationModel? { get }
  var createMode: CanvasItemType? { get }
  var createColor: ModelColor { get }
  
  func select(model: AnnotationModel)
  func deselect()
  
  func renderNew(_ model: AnnotationModel)
}

private struct PossibleDragging {
  let lastDraggedPoint: CGPoint
  let type: PossibleDraggingType
  let modifiedAnnotation: AnnotationModel?
  
  init(lastDraggedPoint: CGPoint,
       type: PossibleDraggingType,
       modifiedAnnotation: AnnotationModel? = nil) {
    self.lastDraggedPoint = lastDraggedPoint
    self.type = type
    self.modifiedAnnotation = modifiedAnnotation
  }
  
  func copy(with newDraggedPoint: CGPoint,
            modifiedAnnotation: AnnotationModel?) -> PossibleDragging {
    .init(lastDraggedPoint: newDraggedPoint,
          type: type,
          modifiedAnnotation: modifiedAnnotation)
  }
  
  var isCreateMode: Bool {
    switch type {
    case .create(let canvasItemType):
      return true
    default:
      return false
    }
  }
}

private enum PossibleDraggingType {
  case create(CanvasItemType)
  case move
  case resize(KnobType)
}


class MouseInteractionHandler {
  
  weak var dataSource: MouseInteractionHandlerDataSource?
  
  private var possibleMovement: PossibleDragging?
  
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
                                   type: .resize(knobType))
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
                                 type: .move)
        return
      }
    }
    
    dataSource.deselect()
    
    
    if let createMode = dataSource.createMode {
      possibleMovement = .init(lastDraggedPoint: point, type: .create(createMode))
    } else {
      possibleMovement = nil
    }
  }
  
  func handleMouseDragged(point: CGPoint) {
    guard let dataSource else { return }
    guard let possibleMovement else { return }
    let lastDraggedPoint = possibleMovement.lastDraggedPoint
    

    let delta = CGVector(dx: point.x - lastDraggedPoint.x,
                         dy: point.y - lastDraggedPoint.y)
    
    switch possibleMovement.type {
    case .create(let createMode):
      // annotation was already created
      if let annotation = possibleMovement.modifiedAnnotation {
        let updatedAnnotation = NewCreation.updatedAnnotation(annotation: annotation,
                                                              draggedPoint: point)
        dataSource.renderNew(updatedAnnotation)
        self.possibleMovement = possibleMovement.copy(with: point,
                                                      modifiedAnnotation: updatedAnnotation)
      } else {
        let newAnnotation = ModelsCreator.createModelFromTwoPoints(createModeType: createMode,
                                                                   first: possibleMovement.lastDraggedPoint,
                                                                   second: point,
                                                                   zPosition: newZPosition,
                                                                   color: dataSource.createColor)
        dataSource.renderNew(newAnnotation)
        self.possibleMovement = possibleMovement.copy(with: point, modifiedAnnotation: newAnnotation)
      }
    case .move:
        guard let selectedAnnotation = dataSource.selectedAnnotation else {
          return
        }
      // move selected annotation if needed
        let updatedAnnotation = MovementTransformation.movedAnnotation(selectedAnnotation, delta: delta)
        dataSource.select(model: updatedAnnotation)

      self.possibleMovement = possibleMovement.copy(with: point,
                                                    modifiedAnnotation: updatedAnnotation)
    case .resize(let knobType):
      guard let selectedAnnotation = dataSource.selectedAnnotation else {
        return
      }
      
      let updatedAnnotation = ResizeTransformationFactory.resizedAnnotation(annotation: selectedAnnotation,
                                                                            knob: knobType,
                                                                            delta: delta)
      
      dataSource.select(model: updatedAnnotation)
      
      
      self.possibleMovement = possibleMovement.copy(with: point,
                                                    modifiedAnnotation: updatedAnnotation)
    }
  }
  
  func handleMouseUp(point: CGPoint) {
    guard let possibleMovement else { return }
    
    if let modifiedAnnotation = possibleMovement.modifiedAnnotation {
      dataSource?.update(model: modifiedAnnotation)
      if possibleMovement.isCreateMode {
        dataSource?.select(model: modifiedAnnotation)
      }
    }

    self.possibleMovement = nil
  }
  
  private var newZPosition: CGFloat {
    let max =
      dataSource!
      .annotations
      .map(\.zPosition)
      .max() ?? 0
    return max + 1
  }
}
