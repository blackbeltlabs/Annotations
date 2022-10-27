import Cocoa
import Combine


// this class manages all models data that is used by Annotations
// and is a source of truth for the view
public class ModelsManager {
  
  // MARK: - Dependencies
  private let renderer: Renderer
  private let mouseInteractionHandler: MouseInteractionHandler
  private let history: SharedHistory
  
  // MARK: - Models
  private let models = CurrentValueSubject<AnnotationModelsSet, Never>(.init([]))
  let selectedModel = CurrentValueSubject<RenderedModel?, Never>(nil)
  
  // MARK: - Combine
  var commonCancellables = Set<AnyCancellable>()
  
  // MARK: - Public settings
  let obfuscateType = CurrentValueSubject<ObfuscateType, Never>(.solid)
  let isUserInteractionEnabled = CurrentValueSubject<Bool, Never>(true)
  let createModeSubject = CurrentValueSubject<CanvasItemType?, Never>(.arrow)
  let createColorSubject = CurrentValueSubject<ModelColor, Never>(.defaultColor())
  
  // MARK: - Public
  public let viewSizeUpdated = PassthroughSubject<CGSize, Never>()
  
  public var allModelsPublisher: AnyPublisher<[AnnotationModel], Never> {
    models
      .map(\.all)
      .eraseToAnyPublisher()
  }

  // MARK: - Init
  init(renderer: Renderer, mouseInteractionHandler: MouseInteractionHandler, history: SharedHistory) {
    self.renderer = renderer
    self.mouseInteractionHandler = mouseInteractionHandler
    self.history = history
    setupPublishers()
  }
  
  private func setupPublishers() {
    let viewSizeUpdate = viewSizeUpdated.share()
    
    // render all models if viewSizeUpdated (or initial one is set)
    // or models are updated (or initial one array is set)
    Publishers.CombineLatest(viewSizeUpdate, models)
      .map(\.1)
      .sink { [weak self] models in
        guard let self = self else { return }
        if models.all.isEmpty {
          self.renderer.renderRemovalAll()
        } else {
          self.renderer.render(models.all)
          self.updateSelectionModelIfNeeded(with: models.all)
        }
      }
      .store(in: &commonCancellables)
    
    // render obfuscate area
    Publishers.CombineLatest(
      viewSizeUpdate,
      obfuscateType.removeDuplicates())
    .map(\.1)
    .sink { [weak self] obfuscateType in
      let obfuscatedAreaType: ObfuscatedAreaType = {
        switch obfuscateType {
        case .solid:
          return .solidColor(.black)
        case .imagePattern(let image):
          return .image(image)
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
    // Ensure that is runned on the main thread
    Publishers.CombineLatest(viewSizeUpdate, selectionPreviousCurrent)
      .map(\.1)
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
  
  // MARK: - Public
  
  // add one or multiple models
  public func add(models: [AnnotationModel]) {
    let modelsSet = AnnotationModelsSet(models)
    self.models.send(modelsSet)
  }
  
  // update model and add to history
  public func update(model: AnnotationModel, updateHistory: Bool = true) {
    var allModels = models.value
    
    if updateHistory {
      if let oldModel = allModels.model(for: model.id) {
        history.addUndo {
          self.update(model: oldModel)
        }
      } else {
        history.addUndo { [weak self] in
          self?.delete(model: model)
        }
      }
    }
    
    allModels.update(model)
    
    if let numbers = updateNumbersIfNeeded(in: allModels.all) {
      allModels.update(numbers)
    }
    
    models.send(allModels)
  }
  
  // delete single model
  public func delete(model: AnnotationModel, updateHistory: Bool = true) {
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
    
    if updateHistory {
      history.addUndo { [weak self] in
        self?.update(model: model)
      }
    }
  }
  
  // Select / deselect / remove selected
  public func select(model: AnnotationModel) {
    select(model: model, renderingType: nil, checkIfContainsInModelsSet: true)
  }
  
  public func deselect() {
    selectedModel.send(nil)
  }
  
  public func deleteSelectedModel() {
    guard let value = selectedModel.value else { return }
    delete(model: value.model)
  }
  
  // Delete all and clear the history
  public func removeAll() {    
    var currentSet = models.value
    currentSet.refresh(with: [])
    models.send(currentSet)
    
    history.clear()
  }
  
  // if the canvas view contains annotations
  public func containsAnnotations() -> Bool {
    !models.value.all.isEmpty
  }
    
  // MARK: - Select
  func select(model: AnnotationModel,
              renderingType: RenderingType?) {
    select(model: model, renderingType: renderingType, checkIfContainsInModelsSet: false)
  }
  
  func select(model: AnnotationModel,
              renderingType: RenderingType?,
              checkIfContainsInModelsSet: Bool) {
    if checkIfContainsInModelsSet {
      guard models.value.contains(model) else { return }
    }
    selectedModel.send(.init(model: model,
                             renderingType: renderingType))
  }
  
  // MARK; - Private
  private func updateSelectionModelIfNeeded(with models: [AnnotationModel]) {
    guard let selectedAnnotation = selectedModel.value else { return }
  
    guard let firstIndex = models.firstIndex(where: { $0.id == selectedAnnotation.id }) else { return }
    
    select(model: models[firstIndex])
  }

  // MARK: - Numbers
  // if some intermediate number was deleted then it might need to update their values
  private func updateNumbersIfNeeded(in models: [AnnotationModel]) -> [Number]? {
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
extension ModelsManager: MouseInteractionHandlerDataSource, PositionHandlerDataSource, AnalyticsDataSource {
  func update(model: AnnotationModel) {
    update(model: model, updateHistory: true)
  }
  
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
