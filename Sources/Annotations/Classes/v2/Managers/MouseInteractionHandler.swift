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
  
  func renderNew(_ model: AnnotationModel?)
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
    case .create:
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
  
  let textAnnotationsManager: TextAnnotationsManager
  
  var textCouldBeEdited: Bool = false
  
  init(textAnnotationsManager: TextAnnotationsManager) {
    self.textAnnotationsManager = textAnnotationsManager
  }
  
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
        
        // this annotation was already selected
        if annotation.id == dataSource.selectedAnnotation?.id,
           annotation is Text {
          textCouldBeEdited = true
        }
              
        let maxZPosition = self.maxZPosition
        
        // update zPosition if needed
        if annotation.zPosition < maxZPosition,
           makesSenseToUpdateZPosition(for: annotation) {
          var updatedAnnotation = annotation
          updatedAnnotation.zPosition = self.newZPosition
          dataSource.update(model: updatedAnnotation)
          dataSource.select(model: updatedAnnotation)
        } else {
          dataSource.select(model: annotation)
        }
        
        possibleMovement = .init(lastDraggedPoint: point,
                                 type: .move)
        
        return
      }
    }
    
    dataSource.deselect()
    
    if textAnnotationsManager.isEditing {
      let result = textAnnotationsManager.cancelEditing()
      if let model = result.model, result.textWasUpdated {
        dataSource.update(model: model)
      }
    }
    
    if let createMode = dataSource.createMode {
      
      if createMode == .number {
        let number = Number.modelWithRadius(centerPoint: point.modelPoint,
                                            radius: Number.defaultRadius,
                                            value: nextModelNumber,
                                            zPosition: newZPosition,
                                            color: dataSource.createColor)
        dataSource.update(model: number)
        dataSource.select(model: number)
      } else {
        possibleMovement = .init(lastDraggedPoint: point, type: .create(createMode))
      }
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
      let beingCreatedAnnotation: AnnotationModel? = {
        if let annotation = possibleMovement.modifiedAnnotation {
          return NewCreation.updatedAnnotation(annotation: annotation,
                                               draggedPoint: point)
        } else {
          guard ModelsCreatorValidator.isModelValid(for: createMode,
                                                    firstPoint: possibleMovement.lastDraggedPoint,
                                                    secondPoint: point) else {
            return nil
          }
          
          return ModelsCreator.createModelFromTwoPoints(createModeType: createMode,
                                                        first: possibleMovement.lastDraggedPoint,
                                                        second: point,
                                                        zPosition: newZPosition,
                                                        color: dataSource.createColor)
        }
      }()
      
      guard let beingCreatedAnnotation else { return }
      
      dataSource.renderNew(beingCreatedAnnotation)
      self.possibleMovement = possibleMovement.copy(with: point,
                                                    modifiedAnnotation: beingCreatedAnnotation)
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
    guard let dataSource = dataSource else { return }
    guard let possibleMovement else { return }
  
    if let modifiedAnnotation = possibleMovement.modifiedAnnotation {
      dataSource.update(model: modifiedAnnotation)
      // select annotation that just was created
      if possibleMovement.isCreateMode {
        dataSource.renderNew(nil)
        dataSource.select(model: modifiedAnnotation)
      }
    } else {
      if let selectedAnnotation = dataSource.selectedAnnotation as? Text,
         textCouldBeEdited {
        textAnnotationsManager.handleTextEditing(for: selectedAnnotation) { text in
          dataSource.select(model: text)
        }
        textCouldBeEdited = false
      }
    }

    self.possibleMovement = nil
  }
}

// MARK: - Z Positions
extension MouseInteractionHandler {
  fileprivate var maxZPosition: CGFloat {
      dataSource!
      .annotations
      .map(\.zPosition)
      .max() ?? 0
  }
  
  fileprivate var newZPosition: CGFloat {
    return maxZPosition + 1
  }
  
  // no need to update for obfuscate and higlight tools as not supported now
  func makesSenseToUpdateZPosition(for model: AnnotationModel) -> Bool {
    if let rect = model as? Rect {
      if rect.rectType == .highlight || rect.rectType == .obfuscate {
        return false
      }
    }
    
    return true
  }
}

// MARK: - Numbers

extension MouseInteractionHandler {
  fileprivate var nextModelNumber: Int {
    dataSource!.annotations.compactMap { $0 as? Number }.count + 1
  }
}
