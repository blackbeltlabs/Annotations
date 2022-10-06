import Foundation
import Combine
import Cocoa


public class ModelsManager {
  
  // MARK: - Dependencies
  let renderer: Renderer
  let mouseInteractionHandler: MouseInteractionHandler
  
  // MARK: - Models
  private let models = CurrentValueSubject<AnnotationModelsSet, Never>(.init([]))
  let selectedModel = CurrentValueSubject<AnnotationModel?, Never>(nil)
  
  let beingCreatedModel = CurrentValueSubject<AnnotationModel?, Never>(nil)
  
  // MARK: - Combine
  public var commonCancellables = Set<AnyCancellable>()
  
  // MARK: - Public settings
  public var solidColorForObsfuscate: Bool = false
  public var isUserInteractionEnabled = CurrentValueSubject<Bool, Never>(true)
  
  public var createModeSubject = CurrentValueSubject<CanvasItemType?, Never>(.arrow)
  public var createColorSubject = CurrentValueSubject<ModelColor, Never>(.defaultColor())
  
  public let viewSizeUpdated = PassthroughSubject<CGSize, Never>()
  
  // used for obfuscate purposes
  private let backgroundImage = CurrentValueSubject<NSImage?, Never>(nil)

  init(renderer: Renderer, mouseInteractionHandler: MouseInteractionHandler) {
    self.renderer = renderer
    self.mouseInteractionHandler = mouseInteractionHandler
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
      .receive(on: DispatchQueue.main)
      .sink { [weak self] (previousSelection, currentSelection) in
        guard let self else { return }
        if let previousSelection {
          self.renderer.renderSelection(for: previousSelection, isSelected: false)
        }
        
        if let currentSelection {
          self.renderer.render([currentSelection])
          self.renderer.renderSelection(for: currentSelection, isSelected: true)
        }
        
      }
      .store(in: &commonCancellables)
    
    beingCreatedModel
      .compactMap { $0 }
      .sink { [weak self] model in
        guard let self = self else { return }
        self.renderer.render([model])
      }
      .store(in: &commonCancellables)
    
    
    // COLOR
    createColorSubject
      .dropFirst()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] color in
        guard let self else { return }
        // if there is a selected annotation then update its color
        // and update it in models storage
        guard var selectedAnnotation = self.selectedModel.value else { return }
          
        selectedAnnotation.color = color
        self.update(model: selectedAnnotation)
      }
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
    
    self.models.send(allModelsSet)
    renderer.renderRemoval(of: model.id)
  }
  
  public func deleteSelectedModel() {
    guard let value = selectedModel.value else { return }
    delete(model: value)
  }
  
  public func select(model: AnnotationModel) {
    guard models.value.contains(model) else { return }
    selectedModel.send(model)
  }
  
  public func deselect() {
    selectedModel.send(nil)
  }
  
  public func update(model: AnnotationModel) {
    var allModels = models.value
    allModels.update(model)
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
  public func addBackgroundImage(_ image: NSImage) {
    backgroundImage.send(solidColorForObsfuscate ? nil : image)
  }
}


// MARK: - MouseInteractionHandlerDataSource
extension ModelsManager: MouseInteractionHandlerDataSource {
  var annotations: [AnnotationModel] {
    models.value.all
  }
  
  var selectedAnnotation: AnnotationModel? {
    selectedModel.value
  }
  
  var createMode: CanvasItemType? {
    createModeSubject.value
  }
  
  var createColor: ModelColor {
    createColorSubject.value
  }
  
  func renderNew(_ model: AnnotationModel?) {
    beingCreatedModel.send(model)
  }
}
