import Foundation

public struct AnnotationsManagingParts {
  public let modelsManager: ModelsManager
  public let history: SharedHistory
  public let settings: Settings
  public let analytics: Analytics
}

public final class AnnotationsCanvasFactory {
  
  // a custom shared history instance could be passed if needed
  public static func instantiate(_ customHistory: SharedHistory? = nil) -> (canvasView: DrawableCanvasView,
                                                                            parts: AnnotationsManagingParts) {
    let canvasView = DrawableCanvasView(frame: .zero)
    let renderer = Renderer(canvasView: canvasView)
    let textAnnotationsManager = TextAnnotationsManager()
    
    let positionsHandler = PositionHandler()
    let mouseInteractionHandler = MouseInteractionHandler(textAnnotationsManager: textAnnotationsManager,
                                                          positionsHandler: positionsHandler)
    let history = customHistory ?? SharedHistory()
    let modelsManager = ModelsManager(renderer: renderer,
                                      mouseInteractionHandler: mouseInteractionHandler,
                                      history: history)
    
    let settings = Settings()
    
    let analytics = Analytics()
    analytics.dataSource = modelsManager
    
    positionsHandler.dataSource = modelsManager
    mouseInteractionHandler.dataSource = modelsManager
    mouseInteractionHandler.renderer = renderer
    textAnnotationsManager.source = renderer
    setupPublishers(canvasView: canvasView,
                    modelsManager: modelsManager,
                    mouseInteractionHandler: mouseInteractionHandler)
    
    bindSettings(settings: settings,
                 modelsManager: modelsManager,
                 canvas: canvasView,
                 textAnnotationManager: textAnnotationsManager)
    
    return (canvasView, .init(modelsManager: modelsManager,
                              history: history,
                              settings: settings,
                              analytics: analytics))
  }
  
  static func bindSettings(settings: Settings,
                           modelsManager: ModelsManager,
                           canvas: DrawableCanvasView,
                           textAnnotationManager: TextAnnotationsManager) {
    settings
      .solidColorForObsfuscate
      .receive(on: DispatchQueue.main)
      .assign(to: \.solidColorForObsfuscate, on: modelsManager)
      .store(in: &modelsManager.commonCancellables)
  
    settings
      .isUserInteractionEnabled
      .receive(on: DispatchQueue.main)
      .assign(to: \.value, on: modelsManager.isUserInteractionEnabled)
      .store(in: &modelsManager.commonCancellables)
    
    settings
      .currentAnnotationTypeSubject
      .receive(on: DispatchQueue.main)
      .assign(to: \.value, on: modelsManager.createModeSubject)
      .store(in: &modelsManager.commonCancellables)
    
    settings
      .createColorSubject
      .receive(on: DispatchQueue.main)
      .assign(to: \.value, on: modelsManager.createColorSubject)
      .store(in: &modelsManager.commonCancellables)
    
    settings
      .backgroundImageSubject
      .receive(on: DispatchQueue.main)
      .sink { [weak modelsManager] image in
        modelsManager?.addBackgroundImage(image)
      }
      .store(in: &modelsManager.commonCancellables)
    
    settings
      .textStyleSubject
      .receive(on: DispatchQueue.main)
      .assign(to: \.textStyle, on: textAnnotationManager)
      .store(in: &modelsManager.commonCancellables)
    
    canvas
      .textViewEditingSubject
      .sink { [weak settings] isEditing in
        settings?.textViewIsEditingSubject.send(isEditing)
      }
      .store(in: &modelsManager.commonCancellables)
    
    canvas
      .emojiPickerisPresented
      .sink { [weak settings] isPresented in
        settings?.emojiPickerIsPresented.send(isPresented)
      }
      .store(in: &modelsManager.commonCancellables)
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
    
    canvasView
      .mouseMovedSubject
      .sink { [weak mouseInteractionHandler] point in
        mouseInteractionHandler?.handleMouseMoved(point: point)
      }
      .store(in: &canvasView.commonCancellables)
    
    canvasView
      .legibilityButtonPressedSubject
      .sink { [weak mouseInteractionHandler] id in
        mouseInteractionHandler?.handleLegibilityButtonPressed(id)
      }
      .store(in: &canvasView.commonCancellables)
    
    canvasView
      .emojiButtonPressedSubject
      .sink { [weak mouseInteractionHandler] id in
        mouseInteractionHandler?.handleEmojiPickerPressed(id)
      }
      .store(in: &canvasView.commonCancellables)
  }
}
