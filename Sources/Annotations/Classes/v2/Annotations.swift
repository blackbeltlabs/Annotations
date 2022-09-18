import Foundation

final class Annotations {
  static func instantiate() -> (ModelsManager, DrawableCanvasView) {
    let canvasView = DrawableCanvasView(frame: .zero)
    let renderer = Renderer(canvasView: canvasView)
    let modelsManager = ModelsManager(renderer: renderer)
    
    setupPublishers(canvasView: canvasView,
                    modelsManager: modelsManager)
    
    return (modelsManager, canvasView)
  }
  
  static func setupPublishers(canvasView: DrawableCanvasView,
                              modelsManager: ModelsManager) {
    canvasView
      .viewSizeUpdated
      .sink { [weak modelsManager] _ in
        modelsManager?.renderAll()
      }.store(in: &modelsManager.commonCancellables)
  }
}
