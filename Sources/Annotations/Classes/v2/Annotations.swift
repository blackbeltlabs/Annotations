import Foundation

public final class AnnotationsCanvasFactory {
  public static func instantiate() -> (modelsManager: ModelsManager, canvasView: DrawableCanvasView) {
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
      .sink { [weak modelsManager] size in
        modelsManager?.viewSizeUpdated.send(size)
      }.store(in: &modelsManager.commonCancellables)
    
    modelsManager
      .isUserInteractionEnabled
      .receive(on: DispatchQueue.main)
      .assign(to: \.isUserInteractionEnabled, on: canvasView )
      .store(in: &canvasView.commonCancellables)
  }
}
