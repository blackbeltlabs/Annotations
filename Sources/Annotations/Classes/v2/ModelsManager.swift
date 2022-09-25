import Foundation
import Combine
import Cocoa


public class ModelsManager {
  let renderer: Renderer
  
  private(set) var models: [AnnotationModel] = []
    
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
    
    viewSizeUpdate.sink { [weak self] _ in
      self?.renderAll()
      self?.renderer.renderObfuscatedArea(type: .solidColor(.black))
    }
    .store(in: &commonCancellables)
    
    Publishers.CombineLatest(
      viewSizeUpdate.debounce(for: 0.1, scheduler: DispatchQueue.main),
      backgroundImage)
    .map { $0.1 }
    .receive(on: DispatchQueue.main)
    .sink { [weak self] image in
      if let image {
        self?.renderer.renderObfuscatedArea(type: .image(image))
      } else {
        self?.renderer.renderObfuscatedArea(type: .solidColor(.black))
      }
    }.store(in: &commonCancellables)
  
  }
  
  public func add(models: [AnnotationModel]) {
    self.models = models
    renderer.render(models)
  }
  
  func renderAll() {
    renderer.render(models)
  }
  
  // add background image that is used for obfuscated purposes
  public func addBackgroundImage(_ image: NSImage) {
    backgroundImage.send(solidColorForObsfuscate ? nil : image)
  }
}
