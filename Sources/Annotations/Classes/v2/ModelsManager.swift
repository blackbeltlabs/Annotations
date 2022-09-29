import Foundation
import Combine
import Cocoa


public class ModelsManager {
  let renderer: Renderer
  
  let models = CurrentValueSubject<[AnnotationModel], Never>([])
  
  let selectedModel = CurrentValueSubject<AnnotationModel?, Never>(nil)
    
  // MARK: - Combine
  public var commonCancellables = Set<AnyCancellable>()
  
  // MARK: - Public settings
  public var solidColorForObsfuscate: Bool = false
  
  public let viewSizeUpdated = PassthroughSubject<CGSize, Never>()
  
  // used for obfuscate purposes
  private let backgroundImage = CurrentValueSubject<NSImage?, Never>(nil)

  init(renderer: Renderer) {
    self.renderer = renderer
    setupPublishers()
  }
  
  func setupPublishers() {
    let viewSizeUpdate = viewSizeUpdated.share()
    
    Publishers.CombineLatest(viewSizeUpdate, models)
      .map(\.1)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] models in
        self?.renderer.render(models)
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
    }.store(in: &commonCancellables)
   
    
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
        guard let self = self else { return }
        if let previousSelection {
          self.renderer.renderSelection(for: previousSelection, isSelected: false)
        }
        if let currentSelection {
          self.renderer.renderSelection(for: currentSelection, isSelected: true)
        }
        
      }.store(in: &commonCancellables)
  
  }
  
  public func add(models: [AnnotationModel]) {
    self.models.send(models)
  }
  
  public func select(model: AnnotationModel) {
    guard models.value.contains(where: { $0.id == model.id }) else { return }
    selectedModel.send(model)
  }
  
  public func deselect() {
    selectedModel.send(nil)
  }
  
  // add background image that is used for obfuscated purposes
  public func addBackgroundImage(_ image: NSImage) {
    backgroundImage.send(solidColorForObsfuscate ? nil : image)
  }
}
