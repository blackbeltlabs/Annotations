import Foundation
import Combine


public class ModelsManager {
  let renderer: Renderer
  
  private var models: [AnnotationModel] = []
  
  public var commonCancellables = Set<AnyCancellable>()

  init(renderer: Renderer) {
    self.renderer = renderer
  }
  
  public func add(models: [AnnotationModel]) {
    self.models = models
    renderer.render(models)
  }
  
  func renderAll() {
    renderer.render(models)
  }
}
