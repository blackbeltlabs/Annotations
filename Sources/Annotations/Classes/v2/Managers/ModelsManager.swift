import Foundation
import Combine
import Cocoa


protocol RenderingType {
  
}


enum CommonRenderingType: RenderingType {
  case dontRenderSelection
}

enum TextRenderingType: RenderingType {
  case newModel
  case resize
  case scale
  case textEditingUpdate
}

struct RenderedModel {
  let model: AnnotationModel
  let renderingType: RenderingType?
  
  var id: String { model.id }
}

public class ModelsManager {
  
  // MARK: - Dependencies
  let renderer: Renderer
  let mouseInteractionHandler: MouseInteractionHandler
  let history: SharedHistory
  
  // MARK: - Models
  private let models = CurrentValueSubject<AnnotationModelsSet, Never>(.init([]))
  
  let selectedModel = CurrentValueSubject<RenderedModel?, Never>(nil)
  
  // MARK: - Combine
  public var commonCancellables = Set<AnyCancellable>()
  
  // MARK: - Public settings
  var solidColorForObsfuscate: Bool = false
  let isUserInteractionEnabled = CurrentValueSubject<Bool, Never>(true)
  let createModeSubject = CurrentValueSubject<CanvasItemType?, Never>(.arrow)
  let createColorSubject = CurrentValueSubject<ModelColor, Never>(.defaultColor())
  
  public let viewSizeUpdated = PassthroughSubject<CGSize, Never>()
  
  // used for obfuscate purposes
  private let backgroundImage = CurrentValueSubject<NSImage?, Never>(nil)

  init(renderer: Renderer, mouseInteractionHandler: MouseInteractionHandler, history: SharedHistory) {
    self.renderer = renderer
    self.mouseInteractionHandler = mouseInteractionHandler
    self.history = history
    setupPublishers()
  }
  
  func setupPublishers() {
    let viewSizeUpdate = viewSizeUpdated.share()
    
    Publishers.CombineLatest(viewSizeUpdate, models)
      .map(\.1)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] models in
        guard let self = self else { return }
        self.renderer.render(models.all)
        self.updateSelectionModelIfNeeded(with: models.all)
      }
      .store(in: &commonCancellables)
    
    viewSizeUpdate.sink { [weak self] _ in
      self?.renderer.renderObfuscatedAreaBackground(type: .solidColor(.black))
    }
    .store(in: &commonCancellables)
    
    Publishers.CombineLatest(
      viewSizeUpdate.debounce(for: 0.1, scheduler: DispatchQueue.main),
      backgroundImage)
    .map(\.1)
    .receive(on: DispatchQueue.main)
    .sink { [weak self] image in
      let obfuscatedAreaType: ObfuscatedAreaType = {
        if let image {
          return .image(image)
        } else {
          return .solidColor(.black)
        }
      }()
      self?.renderer.renderObfuscatedAreaBackground(type: obfuscatedAreaType)
    }
    .store(in: &commonCancellables)
   
    // SELECTION
   let selectionPreviousCurrent =
    selectedModel
      .dropFirst()
      .scan((nil,nil)) { ($0.1, $1) }
    
    // deselect previous if needed
    // and select the current one
    Publishers.CombineLatest(viewSizeUpdate, selectionPreviousCurrent)
      .map(\.1)
  //    .receive(on: DispatchQueue.main) FIXME: - handle custom receive here
      .sink { [weak self] (previousSelection, currentSelection) in
        guard let self else { return }
      
        if let previousSelection, previousSelection.id != currentSelection?.id {
          self.renderer.renderSelection(for: previousSelection.model, isSelected: false)
        }
        
        if let currentSelection {
          self.renderer.render(currentSelection)
          
          if let renderingType = currentSelection.renderingType as? CommonRenderingType,
             renderingType == .dontRenderSelection {
            return
          }

          self.renderer.renderSelection(for: currentSelection.model, isSelected: true)
        }
        
      }
      .store(in: &commonCancellables)
    
    // COLOR
    createColorSubject
      .dropFirst()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] color in
        guard let self else { return }
        
        // a text annotation can be edited so need to handle that in mouseInteractionHandler
        if self.mouseInteractionHandler.isEditingMode {
          self.mouseInteractionHandler.handleColorUpdateForEditedAnnotation(color)
          return
        }
        
        // if there is a selected annotation then update its color
        // and update it in models storage
        guard var selectedAnnotation = self.selectedModel.value?.model else { return }
          
        selectedAnnotation.color = color
        
        // update in models storage only if exists
        if self.models.value.contains(selectedAnnotation) {
          self.update(model: selectedAnnotation)
        }
      }
      .store(in: &commonCancellables)
    
    // deselect selected annotation if userInteraction is disabled
    isUserInteractionEnabled
      .filter { !$0 }
      .map({ enabled -> RenderedModel? in
        return nil
      })
      .assign(to: \.value, on: selectedModel)
      .store(in: &commonCancellables)
  }
  
  public func add(models: [AnnotationModel]) {
    let modelsSet = AnnotationModelsSet(models)
    self.models.send(modelsSet)
  }
  
  // FIXME: - Handle with just models (without additional render removal)
  public func delete(model: AnnotationModel) {
    var allModelsSet = self.models.value
    allModelsSet.remove(with: model.id)
    
    if selectedAnnotation?.id == model.id {
      deselect()
    }
    
    // if number is deleted then it could be needed to recalculate number values
    if model is Number, let numbers = updateNumbersIfNeeded(in: allModelsSet.all) {
      allModelsSet.update(numbers)
    }
    
    self.models.send(allModelsSet)
    renderer.renderRemoval(of: model.id)
    
    history.addUndo { [weak self] in
      self?.update(model: model)
    }
  }
  
  public func containsAnnotations() -> Bool {
    !models.value.all.isEmpty
  }
  
  public func deleteSelectedModel() {
    guard let value = selectedModel.value else { return }
    delete(model: value.model)
  }
  
  public func select(model: AnnotationModel) {
    select(model: model, renderingType: nil, checkIfContainsInModelsSet: true)
  }
  
  func select(model: AnnotationModel, renderingType: RenderingType?) {
    select(model: model, renderingType: renderingType, checkIfContainsInModelsSet: false)
  }
  
  func select(model: AnnotationModel, renderingType: RenderingType?, checkIfContainsInModelsSet: Bool) {
    if checkIfContainsInModelsSet {
      guard models.value.contains(model) else { return }
    }
    selectedModel.send(.init(model: model,
                             renderingType: renderingType))
  }
  
  public func deselect() {
    selectedModel.send(nil)
  }
  
  public func update(model: AnnotationModel) {
    var allModels = models.value
    
    if let oldModel = allModels.model(for: model.id) {
      history.addUndo {
        self.update(model: oldModel)
      }
    } else {
      history.addUndo { [weak self] in
        self?.delete(model: model)
      }
    }
    
    allModels.update(model)
    
    if let numbers = updateNumbersIfNeeded(in: allModels.all) {
      allModels.update(numbers)
    }
    
    models.send(allModels)
  }
  
  public func updateCurrentColor(_ color: ModelColor) {
    createColorSubject.send(color)
  }
  
  private func updateSelectionModelIfNeeded(with models: [AnnotationModel]) {
    guard let selectedAnnotation = selectedModel.value else { return }
  
    guard let firstIndex = models.firstIndex(where: { $0.id == selectedAnnotation.id }) else { return }
    
    select(model: models[firstIndex])
  }
  
  // add background image that is used for obfuscated purposes
  func addBackgroundImage(_ image: NSImage) {
    backgroundImage.send(solidColorForObsfuscate ? nil : image)
  }
  
  // MARK: - Numbers
  // if some intermediate number was deleted then it might need to update their values
  func updateNumbersIfNeeded(in models: [AnnotationModel]) -> [Number]? {
    // 1. get all numbers sorted
    let allNumbers: [Number] = models.compactMap { $0 as? Number }.sorted { $0.value < $1.value }
    
    //2. check if need to update (in case if indexes order is incorrect)
    guard allNumbers.enumerated().first(where: { $0.element.value != $0.offset + 1 }) != nil else {
      return nil
    }

    // 3. update numbers order to be correct
    var updatedNumbers = allNumbers
    
    for i in 0..<updatedNumbers.count {
      updatedNumbers[i].value = i + 1
    }
    
    return updatedNumbers
  }
}


// MARK: - MouseInteractionHandlerDataSource
extension ModelsManager: MouseInteractionHandlerDataSource, PositionHandlerDataSource {
  var annotations: [AnnotationModel] {
    models.value.all
  }
  
  var selectedAnnotation: AnnotationModel? {
    selectedModel.value?.model
  }
  
  var createMode: CanvasItemType? {
    createModeSubject.value
  }
  
  var createColor: ModelColor {
    createColorSubject.value
  }
}
