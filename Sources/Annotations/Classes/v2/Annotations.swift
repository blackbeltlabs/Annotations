import Foundation

public final class AnnotationsCanvasFactory {
  public static func instantiate() -> (modelsManager: ModelsManager, canvasView: DrawableCanvasView) {
    let canvasView = DrawableCanvasView(frame: .zero)
    let renderer = Renderer(canvasView: canvasView)
    let mouseInteractionHandler = MouseInteractionHandler()
    let modelsManager = ModelsManager(renderer: renderer,
                                      mouseInteractionHandler: mouseInteractionHandler)
    
    setupPublishers(canvasView: canvasView,
                    modelsManager: modelsManager,
                    mouseInteractionHandler: mouseInteractionHandler)
    
    return (modelsManager, canvasView)
  }
  
  static func setupPublishers(canvasView: DrawableCanvasView,
                              modelsManager: ModelsManager,
                              mouseInteractionHandler: MouseInteractionHandler) {
    
    canvasView
      .viewSizeUpdated
      .sink { [weak modelsManager] size in
        modelsManager?.viewSizeUpdated.send(size)
      }
      .store(in: &modelsManager.commonCancellables)
    
    modelsManager
      .isUserInteractionEnabled
      .receive(on: DispatchQueue.main)
      .assign(to: \.isUserInteractionEnabled, on: canvasView)
      .store(in: &canvasView.commonCancellables)
    
    // Mouse events
    
    canvasView
      .mouseDownSubject
      .sink { [weak mouseInteractionHandler] point in
        mouseInteractionHandler?.handleMouseDown(point: point)
      }
      .store(in: &canvasView.commonCancellables)
    
    canvasView
      .mouseDraggedSubject
      .sink { [weak mouseInteractionHandler] point in
        mouseInteractionHandler?.handleMouseDragged(point: point)
      }
      .store(in: &canvasView.commonCancellables)
    
    
    canvasView
      .mouseUpSubject
      .sink { [weak mouseInteractionHandler] point in
        mouseInteractionHandler?.handleMouseUp(point: point)
      }
      .store(in: &canvasView.commonCancellables)
  
  }
}
