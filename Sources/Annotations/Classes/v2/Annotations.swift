import Foundation

public final class AnnotationsCanvasFactory {
  
  // a custom shared history instance could be passed if needed
  public static func instantiate(_ customHistory: SharedHistory? = nil) -> (modelsManager: ModelsManager, canvasView: DrawableCanvasView, history: SharedHistory) {
    let canvasView = DrawableCanvasView(frame: .zero)
    let renderer = Renderer(canvasView: canvasView)
    let mouseInteractionHandler = MouseInteractionHandler()
    let history = customHistory ?? SharedHistory()
    let modelsManager = ModelsManager(renderer: renderer,
                                      mouseInteractionHandler: mouseInteractionHandler,
                                      history: history)
    mouseInteractionHandler.dataSource = modelsManager
    setupPublishers(canvasView: canvasView,
                    modelsManager: modelsManager,
                    mouseInteractionHandler: mouseInteractionHandler)
    
    return (modelsManager, canvasView, history)
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
