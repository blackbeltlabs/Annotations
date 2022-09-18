import Foundation
import Combine

class ModelsManager {
  let renderer: Renderer
  
  private var models: [AnnotationModel] = []

  
  init(renderer: Renderer) {
    self.renderer = renderer
  }
  
  func add(models: [AnnotationModel]) {
    self.models = models
    renderer.render(models)
  }
}
