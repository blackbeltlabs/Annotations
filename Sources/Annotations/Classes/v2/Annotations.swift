import Foundation

final class Annotations {
  static func instantiate() -> (ModelsManager, DrawableCanvasView) {
    let canvasView = DrawableCanvasView(frame: .zero)
    let renderer = Renderer(canvasView: canvasView)
    let modelsManager = ModelsManager(renderer: renderer)
    
    return (modelsManager, canvasView)
  }
}
