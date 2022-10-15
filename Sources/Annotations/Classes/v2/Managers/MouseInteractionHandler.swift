import Foundation
import CoreGraphics
import Combine

protocol MouseInteractionHandlerDataSource: AnyObject {
  var annotations: [AnnotationModel] { get }
  
  func update(model: AnnotationModel)
  
  var selectedAnnotation: AnnotationModel? { get }
  var createMode: CanvasItemType? { get }
  var createColor: ModelColor { get }
  
  func select(model: AnnotationModel)
  
  func select(model: AnnotationModel, renderingType: RenderingType?)
  func select(model: AnnotationModel, renderingType: RenderingType?, checkIfContainsInModelsSet: Bool)
  
  func deselect()
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
  weak var renderer: Renderer?
  
  private var possibleMovement: PossibleDragging?
  
  private let textAnnotationsManager: TextAnnotationsManager
  private let positionsHandler: PositionHandler
  
  private var textCouldBeEdited: Bool = false
  
  var isEditingMode: Bool {
    textAnnotationsManager.isEditing
  }


  init(textAnnotationsManager: TextAnnotationsManager, positionsHandler: PositionHandler) {
    self.textAnnotationsManager = textAnnotationsManager
    self.positionsHandler = positionsHandler
  }
  
  func handleColorUpdateForEditedAnnotation(_ color: ModelColor) {
    guard textAnnotationsManager.isEditing else { return }
    self.textAnnotationsManager.updateEditingText(with: color)
    self.dataSource?.select(model: self.textAnnotationsManager.editingText!,
                            renderingType: nil)
  }
  
  func handleMouseDown(point: CGPoint) {
    guard let dataSource = dataSource else { return }
       
    // if annotation was selected before
    // try to select knobs
    // or if it is a create mode for text annotation then can transform it during creation
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
    
    // if not knob was selected and there was a create mode of text annotations
    // then need to complete its creation and add to canvas
    if textAnnotationsManager.createMode {
      guard let text = textAnnotationsManager.cancelEditing().model else { return }
      
      
      dataSource.deselect()
      
      //if text is empty then need just remove this annotation
      if text.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        renderer?.renderRemoval(of: text.id)
      } else {
        dataSource.update(model: text)
      }
    
      return
    }
    
    let annotations = dataSource.annotations.sorted(by: { $0.zPosition > $1.zPosition })
    
    for annotation in annotations {
      let selectionPath = SelectionPathFactory.selectionPath(for: annotation)
      if let selectionPath, selectionPath.contains(point) {
        
        // if this is a text annotation, and text annotation was already selected
        // then it could be edited on double tap
        if annotation.id == dataSource.selectedAnnotation?.id,
           annotation is Text {
          textCouldBeEdited = true
        }
              
        let maxZPosition = positionsHandler.maxZPosition
        
        // update zPosition if needed
        if annotation.zPosition < maxZPosition,
           positionsHandler.makesSenseToUpdateZPosition(for: annotation) {
          var updatedAnnotation = annotation
          updatedAnnotation.zPosition = positionsHandler.newZPosition
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
                                            zPosition: positionsHandler.newZPosition,
                                            color: dataSource.createColor)
        dataSource.update(model: number)
        dataSource.select(model: number)
      } else if createMode == .text {
        let newText = TextAnnotationsManager.createNewTextAnnotation(from: point,
                                                                     color: dataSource.createColor,
                                                                     zPosition: positionsHandler.newZPosition,
                                                                     textStyle: textAnnotationsManager.textStyle)
        
        dataSource.select(model: newText, renderingType: nil)
        
        textAnnotationsManager.handleTextEditing(for: newText, createMode: true) { text in
          dataSource.select(model: text,
                            renderingType: TextRenderingType.textEditingUpdate)
        }
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
                                                        zPosition: positionsHandler.newZPosition,
                                                        color: dataSource.createColor)
        }
      }()
      
      guard let beingCreatedAnnotation else { return }
      
      dataSource.select(model: beingCreatedAnnotation,
                        renderingType: CommonRenderingType.dontRenderSelection,
                        checkIfContainsInModelsSet: false)
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
      
      dataSource.select(model: updatedAnnotation, renderingType: renderingType(for: knobType), checkIfContainsInModelsSet: false)
      self.possibleMovement = possibleMovement.copy(with: point,
                                                    modifiedAnnotation: updatedAnnotation)
    }
  }
  
  func handleMouseUp(point: CGPoint) {
    guard let dataSource = dataSource else { return }
    guard let possibleMovement else { return }
    
    defer {
      self.possibleMovement = nil
    }
  
    if let modifiedAnnotation = possibleMovement.modifiedAnnotation {
      if textAnnotationsManager.isEditing, let text = modifiedAnnotation as? Text {
        textAnnotationsManager.updateEditingText(text)
        return
      }
      
      dataSource.update(model: modifiedAnnotation)
      // select annotation that just was created
      if possibleMovement.isCreateMode {
        dataSource.select(model: modifiedAnnotation)
      }
    } else {
      if let selectedAnnotation = dataSource.selectedAnnotation as? Text,
         textCouldBeEdited {
        textAnnotationsManager.handleTextEditing(for: selectedAnnotation) { text in
          dataSource.select(model: text, renderingType: TextRenderingType.textEditingUpdate, checkIfContainsInModelsSet: false)
        }
        textCouldBeEdited = false
      }
    }
  }
  
  // MARK: - Mouse button presses for text annotations
  func handleLegibilityButtonPressed(_ buttonId: String) {
    guard let textAnnotationId = SelectionsIdManager.extractAnnotationIdFromNumberId(buttonId) else { return }
    guard var selectedAnnotation = dataSource?.selectedAnnotation as? Text,
          selectedAnnotation.id == textAnnotationId else { return }
    
    selectedAnnotation.legibilityEffectEnabled.toggle()
    
    if textAnnotationsManager.isEditing {
      textAnnotationsManager.updateEditingText(selectedAnnotation)
      dataSource?.select(model: selectedAnnotation, renderingType: nil)
    } else {
      dataSource?.update(model: selectedAnnotation)
    }
  }
  
  func handleEmojiPickerPressed(_ buttonId: String) {
    guard let textAnnotationId = SelectionsIdManager.extractAnnotationIdFromNumberId(buttonId) else { return }
    guard var selectedAnnotation = dataSource?.selectedAnnotation as? Text,
          selectedAnnotation.id == textAnnotationId else { return }
    renderer?.renderTextEmojiPicker(for: textAnnotationId)
  }
  
}

// customise rendering type for some kind of updates
extension MouseInteractionHandler {
  private func renderingType(for knobType: KnobType) -> RenderingType? {
    guard let knobType = knobType as? TextKnobType else { return nil }
    switch knobType {
    case .resizeLeft:
      return TextRenderingType.resize
    case .resizeRight:
      return TextRenderingType.resize
    case .bottomScale:
      return TextRenderingType.scale
    }
  }
}

// MARK: - Numbers
extension MouseInteractionHandler {
  fileprivate var nextModelNumber: Int {
    dataSource!.annotations.compactMap { $0 as? Number }.count + 1
  }
}
