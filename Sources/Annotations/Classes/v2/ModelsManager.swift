import Foundation
import Combine
import Cocoa


public class ModelsManager {
  let renderer: Renderer
  
  private(set) var models = CurrentValueSubject<[AnnotationModel], Never>([])
    
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
  
  }
  
  public func add(models: [AnnotationModel]) {
    self.models.send(models)
  }
  
  // add background image that is used for obfuscated purposes
  public func addBackgroundImage(_ image: NSImage) {
    backgroundImage.send(solidColorForObsfuscate ? nil : image)
  }
}
