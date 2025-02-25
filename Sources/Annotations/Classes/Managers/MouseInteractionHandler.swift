import Foundation
import CoreGraphics
import Combine

@MainActor
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

private struct PossibleDragging : Sendable{
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

private enum PossibleDraggingType: Sendable {
  case create(CanvasItemType)
  case move
  case resize(KnobType)
}

// Responsible for editing and creation of new annotations
@MainActor
class MouseInteractionHandler {
  
  // MARK: - Weak dependencies
  weak var dataSource: MouseInteractionHandlerDataSource?
  weak var renderer: Renderer?
  
  // MARK: - Dependincies
  private let textAnnotationsManager: TextAnnotationsManager
  private let positionsHandler: PositionHandler
  
  // MARK: - Properties
  private var possibleMovement: PossibleDragging?
  private var textCouldBeEdited: Bool = false
  
  var isEditingMode: Bool {
    textAnnotationsManager.isEditing
  }

  // MARK: - Init
  init(textAnnotationsManager: TextAnnotationsManager, positionsHandler: PositionHandler) {
    self.textAnnotationsManager = textAnnotationsManager
    self.positionsHandler = positionsHandler
  }
  
  // MARK: - Mouse events
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
    
    // if text annotation is editing then need to cancel that
    // on mouse press
    // but this action doesn't prevent from selection of another annotations
    // so we shouldn't return here
    if textAnnotationsManager.isEditing {
      let result = textAnnotationsManager.cancelEditing()
      if let model = result.model, result.textWasUpdated {
        dataSource.update(model: model)
      }
    }
    
    // select the correct annotation depending on their visibility on canvas here
    // and prepare for possible movement, resizing or editing
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
    
    
    // Can't create new annotation like text or number if was deselected (for better UI)
    var wasDeselected: Bool = false
    if dataSource.selectedAnnotation != nil {
      dataSource.deselect()
      wasDeselected = true
    }
    
    // create some annotations from a single press for different create modes
    if let createMode = dataSource.createMode {
      if createMode == .number, !wasDeselected {
        let number = Number.modelWithRadius(centerPoint: point.modelPoint,
                                            radius: Number.defaultRadius,
                                            value: nextModelNumber,
                                            zPosition: positionsHandler.newZPosition,
                                            color: dataSource.createColor)
        dataSource.update(model: number)
        dataSource.select(model: number)
      } else if createMode == .text, !wasDeselected {
        let newText = TextAnnotationsManager.createNewTextAnnotation(from: point,
                                                                     color: dataSource.createColor,
                                                                     zPosition: positionsHandler.newZPosition,
                                                                     textStyle: textAnnotationsManager.textStyle)
        
        dataSource.select(model: newText, renderingType: nil)
        
        textAnnotationsManager.handleTextEditing(for: newText, createMode: true, showEmojiPicker: true) { text in
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
      updateCursorWhenMoving(for: updatedAnnotation)
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
      updateCursorWhenDragging(knobType: knobType)
    }
  }
  
  func handleMouseUp(point: CGPoint) {
    guard let dataSource = dataSource else { return }
    guard let possibleMovement else { return }
    
    defer {
      self.possibleMovement = nil
    }
  
    // if annotations was modified here (moved or resized)
    // then need to updates models
    if let modifiedAnnotation = possibleMovement.modifiedAnnotation {
      
      if var text = modifiedAnnotation as? Text {
    
        if let updatedAnnotation = ResizeTextTransformation.reduceHeightIfNeeded(for: text) {
          dataSource.select(model: updatedAnnotation)
          text = updatedAnnotation
        }
        
        if textAnnotationsManager.isEditing {
          textAnnotationsManager.updateEditingText(text)
        } else {
          dataSource.update(model: text)
        }
        return
      }
      
      dataSource.update(model: modifiedAnnotation)
      // select annotation that just was created
      if possibleMovement.isCreateMode {
        dataSource.select(model: modifiedAnnotation)
      }
    } else {
      // could start text editing here if there is a second tap
      // on the text annotation
      if let selectedAnnotation = dataSource.selectedAnnotation as? Text,
         textCouldBeEdited {
        textAnnotationsManager.handleTextEditing(for: selectedAnnotation, showEmojiPicker: true) { text in
          dataSource.select(model: text, renderingType: TextRenderingType.textEditingUpdate, checkIfContainsInModelsSet: false)
        }
        textCouldBeEdited = false
      }
    }
  }
  
 
  // show proper cursor depending on mouse movement position
  // currently cursors are supported for text annotations only
  func handleMouseMoved(point: CGPoint) {
    guard let dataSource = dataSource else { return }
    
    guard possibleMovement == nil else { return }
    
    guard let selectedAnnotation = dataSource.selectedAnnotation as? Text else { return }
        
    let selectionRect = TextSelectionPathCreator.selectionRect(for: selectedAnnotation)
    
    let textKnobPair = TextKnobsCreator().createKnobs(for: selectedAnnotation)

    if let first = textKnobPair.allKnobsWithType.first(where: { $0.1.frameRect.contains(point) })  {
      if let knobType = first.0 as? TextKnobType {
        setCursorFor(textKnobType: knobType)
        return
      }
    }
    
    if textAnnotationsManager.isEditing {
      if TextSelectionPathCreator.textViewRect(for: selectedAnnotation).contains(point) {
        renderer?.setCursor(type: .textEditing)
      } else {
        renderer?.setCursor(type: .default)
      }
    } else {
      if selectionRect.contains(point) {
        renderer?.setCursor(type: .textMove)
      } else {
        renderer?.setCursor(type: .default)
      }
    }
  }
  
  // MARK: - Color update
  func handleColorUpdateForEditedAnnotation(_ color: ModelColor) {
    guard textAnnotationsManager.isEditing else { return }
    self.textAnnotationsManager.updateEditingText(with: color)
    self.dataSource?.select(model: self.textAnnotationsManager.editingText!,
                            renderingType: nil)
  }
  
  // MARK: - Cursor updates
  private func updateCursorWhenMoving(for annotation: AnnotationModel) {
    if annotation is Text {
      renderer?.setCursor(type: .textMove)
    }
  }
  
  private func updateCursorWhenDragging(knobType: KnobType) {
    if let knobType = knobType as? TextKnobType {
      setCursorFor(textKnobType: knobType)
    } else {
      renderer?.setCursor(type: .default)
    }
  }
  
  private func setCursorFor(textKnobType: TextKnobType) {
    switch textKnobType {
    case .resizeLeft, .resizeRight:
      renderer?.setCursor(type: .textResize)
    case .bottomScale:
      renderer?.setCursor(type: .textScale)
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
    guard let selectedAnnotation = dataSource?.selectedAnnotation as? Text,
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
