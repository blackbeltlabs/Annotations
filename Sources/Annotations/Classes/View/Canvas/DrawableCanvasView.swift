import Cocoa
import Combine

private enum MouseEventType {
  case down
  case dragged
  case up
  case moved
}

private class SelectionMainView: NSView {
  override var isFlipped: Bool { true }
}

public class DrawableCanvasView: NSView {
  // MARK: - Layers
  let obfuscateLayer: ObfuscateLayer = ObfuscateLayer()
  let higlightsLayer = HiglightsLayer()
  
  let selectionView: NSView = {
    let view = SelectionMainView()
    view.wantsLayer = true
    return view
  }()
  
  var selectionsLayer: CALayer {
    selectionView.layer!
  }
    
  private var selectionDrawables = DrawableModelsSet([])
  
  // MARK: - Touches
  private var trackingArea: NSTrackingArea?

  // MARK: - Helpers
  let imageColorsCalculator = ImageColorsCalculator()
  
  // MARK: - Publishers
  let viewSizeUpdated = PassthroughSubject<CGSize, Never>()
  let viewLayoutUpdated = PassthroughSubject<Void, Never>()
  
  let mouseDownSubject = PassthroughSubject<CGPoint, Never>()
  let mouseDraggedSubject = PassthroughSubject<CGPoint, Never>()
  let mouseUpSubject = PassthroughSubject<CGPoint, Never>()
  let mouseMovedSubject = PassthroughSubject<CGPoint, Never>()
  
  let legibilityButtonPressedSubject = PassthroughSubject<String, Never>()
  let emojiButtonPressedSubject = PassthroughSubject<String, Never>()
  
  let emojiPickerisPresented = CurrentValueSubject<Bool, Never>(false)
  private var emojiPickerPresentedCancellable: AnyCancellable?
  
  let textViewEditingSubject = PassthroughSubject<Bool, Never>()
    
  var isUserInteractionEnabled: Bool = true
  
  // MARK: - Cancellables
  
  var commonCancellables = Set<AnyCancellable>()
  
  public override var frame: NSRect {
    didSet {
      viewSizeUpdated.send(frame.size)
    }
  }
  
  // MARK: - Init
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    wantsLayer = true
    
    layer?.addSublayer(obfuscateLayer)
    layer?.addSublayer(higlightsLayer)
    addSubview(selectionView)
    
    selectionsLayer.zPosition = 10000000
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func layout() {
    super.layout()
    obfuscateLayer.frame = bounds
    higlightsLayer.frame = bounds
    
    selectionView.frame = bounds
    viewLayoutUpdated.send(())
  }
  
  // MARK: - Tracking areas
  override public func updateTrackingAreas() {
    if let trackingArea = trackingArea {
      removeTrackingArea(trackingArea)
    }
    
    let options : NSTrackingArea.Options = [.activeInKeyWindow, .mouseMoved]
    let newTrackingArea = NSTrackingArea(rect: self.bounds, options: options,
                                         owner: self, userInfo: nil)
    self.addTrackingArea(newTrackingArea)
    self.trackingArea = newTrackingArea
  }
  
  // MARK: - Mouse touches
  
  override public func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)
    handleMouseEventType(.down, event: event)
  }
  
  override public func mouseDragged(with event: NSEvent) {
    super.mouseDragged(with: event)
    handleMouseEventType(.dragged, event: event)
  }
  
  override public func mouseUp(with event: NSEvent) {
    super.mouseUp(with: event)
    handleMouseEventType(.up, event: event)
  }
  
  public override func mouseMoved(with event: NSEvent) {
    super.mouseMoved(with: event)
    handleMouseEventType(.moved, event: event)
  }
    
  public override func hitTest(_ point: NSPoint) -> NSView? {
    guard isUserInteractionEnabled else {
      return nil
    }
    return super.hitTest(point)
  }
  
  private func handleMouseEventType(_ type: MouseEventType, event: NSEvent) {
    guard isUserInteractionEnabled else { return }
    let point = convert(event.locationInWindow, from: nil)
    
    switch type {
    case .down:
      mouseDownSubject.send(point)
    case .dragged:
      mouseDraggedSubject.send(point)
    case .up:
      mouseUpSubject.send(point)
    case .moved:
      mouseMovedSubject.send(point)
    }
  }
  
  private func mousePressPoint(from event: NSEvent) -> CGPoint {
    convert(event.locationInWindow, from: nil)
  }
  
  // need just leave it empty to ensure that custom cursors will work
  // and will not blink
  // https://stackoverflow.com/a/64370679/5236187
  public override func cursorUpdate(with event: NSEvent) { }
}

protocol DrawableElement {
  var id: String { get set }
}

extension DrawableCanvasView: RendererCanvas {
  
  public override var isFlipped: Bool { true }
  
  var drawables: [DrawableElement] {
    let sublayers = layer?.sublayers ?? []
  
    let regularLayers = sublayers.compactMap { $0 as? DrawableElement }
    
    let obfuscateLayers = obfuscateLayer.allObfuscatedLayers.compactMap { $0 as? DrawableElement }
    
    let highlightDrawables = higlightsLayer.allHighlightDrawables
    
    
    let textAnnotations = subviews.compactMap { $0 as? DrawableElement }
    
    return regularLayers + obfuscateLayers + highlightDrawables + textAnnotations
  }
  
  func renderLayer(id: String,
                   type: LayerType,
                   renderingSet: LayerRenderingSet) {
    renderAnyShapeLayer(of: CanvasShapeLayer.self,
                        id: id,
                        type: type,
                        renderingSet: renderingSet)
  }
  
  @discardableResult
  private func renderAnyShapeLayer<T: CAShapeLayer & DrawableElement>(of layerType: T.Type,
                                                                      id: String,
                                                                      type: LayerType,
                                                                      renderingSet: LayerRenderingSet) -> T? {
    if let drawable = drawable(with: id) {
      if let layer  = drawable as? T {
        renderNormalLayer(layer: layer,
                          path: renderingSet.path,
                          settings: renderingSet.settings,
                          zPosition: renderingSet.zPosition)
        return layer
      } else if let highlight = drawable as? HiglightRectArea {
        higlightsLayer.addHighlightArea(path: renderingSet.path,
                                        id: id)
        return nil
      }
    } else {
      let newLayer: T = createNormalLayer(with: id)
      
      switch type {
      case .normal:
        layer?.addSublayer(newLayer)
      case .obfuscate:
        obfuscateLayer.addObfuscatedArea(newLayer)
      case .highlight:
        higlightsLayer.addHighlightArea(path: renderingSet.path,
                                        id: id)
        return newLayer
      }
   
      renderNormalLayer(layer: newLayer,
                        path: renderingSet.path,
                        settings: renderingSet.settings,
                        zPosition: renderingSet.zPosition)
      return newLayer
    }
    
    return nil
  }
  
  func renderNumber(id: String,
                    renderingSet: LayerRenderingSet,
                    numberValue: Int,
                    numberFontSize: CGFloat) {
    guard let numberLayer = renderAnyShapeLayer(of: NumberLayer.self,
                                                id: id,
                                                type: .normal,
                                                renderingSet: renderingSet) else {
      return
    }
    
    CATransaction.withoutAnimation {
      numberLayer.textLayer.frame = numberLayer.path!.boundingBox
      numberLayer.textLayer.fontSize = numberFontSize
      numberLayer.textLayer.string = String(format: "%d", numberValue)
    }
  }
  
  func createNormalLayer<T: CAShapeLayer & DrawableElement>(with id: String) -> T {
    var layer = T()
    layer.id = id
    if let backingScaleFactor = window?.screen?.backingScaleFactor {
      layer.contentsScale = backingScaleFactor
    }
    return layer
  }
    
  func renderNormalLayer(layer: CAShapeLayer,
                         path: CGPath,
                         settings: LayerUISettings,
                         zPosition: CGFloat) {
    layer.path = path
    layer.setup(with: settings)
    layer.zPosition = zPosition
  }
  
  func renderText(text: Text, rendererType: TextRenderingType?) {
    if let textAnnotation = drawable(with: text.id) as? TextAnnotationView {
      
      if let renderingType = rendererType {
        switch renderingType {
        case .resize:
          textAnnotation.frame = text.renderFrame
        case .scale:
          textAnnotation.frame = text.renderFrame
          let newFont = text.style.attributes[.font] as! NSFont
          print("New font size = \(newFont.pointSize)")
          textAnnotation.font = newFont
        case .textEditingUpdate:
          textAnnotation.frame = text.renderFrame
        case .newModel:
          renderTextAnnotation(textAnnotation, with: text)
        }
      } else {
        renderTextAnnotation(textAnnotation, with: text)
      }
    } else {
      let textView = TextAnnotationView(frame: frame)
      textView.setLinePadding(TextLayoutHelper.singleLinePadding)
      self.addSubview(textView)
      renderTextAnnotation(textView, with: text)
      stopEditingText(for: text.id)
    }
  }
  
  private func renderTextAnnotation(_ annotation: TextAnnotationView,
                                    with textModel: Text) {
    annotation.id = textModel.id
    annotation.frame = textModel.renderFrame
    if annotation.string != textModel.text {
      annotation.string = textModel.text
    }
    
    var style = textModel.style
    style.foregroundColor = textModel.color
    
    annotation.setStyle(style)
    annotation.setLegibilityEffectEnabled(textModel.legibilityEffectEnabled)
    annotation.setZPosition(textModel.zPosition)
  }
  
  func startEditingText(for id: String) -> AnyPublisher<String, Never>? {
    guard let textAnnotation = drawable(with: id) as? TextAnnotationView else { return nil }
    textAnnotation.setEditing(true)
    
    textViewEditingSubject.send(true)
    return textAnnotation.textDidChangedSubject.eraseToAnyPublisher()
  }
  
  func stopEditingText(for id: String) {
    guard let textAnnotation = drawable(with: id) as? TextAnnotationView else { return }
    textAnnotation.setEditing(false)
    
    textViewEditingSubject.send(false)
  }
  
  func renderRemoval(with id: String) {
    guard let drawable = drawable(with: id) else { return }
    removeDrawable(drawable)
  }
  
  private func removeDrawable(_ drawable: DrawableElement) {
    if let layer = drawable as? CALayer {
      layer.removeFromSuperlayer()
    } else if let view = drawable as? NSView {
      view.removeFromSuperview()
    } else if let highlightedArea = drawable as? HiglightRectArea {
      higlightsLayer.removeHighlightArea(highlightedArea.id)
    }
  }
  
  private func drawable(with id: String) -> DrawableElement? {
    drawables.first(where: { $0.id == id })
  }
  
  func clearAll() {
    CATransaction.withoutAnimation {
      self.drawables.forEach { self.removeDrawable($0) }
      self.selectionDrawables.all.forEach { self.removeDrawable($0) }
    }
  }
}

extension DrawableCanvasView {
  func renderSelections(_ selections: [Selection]) {
    CATransaction.withoutAnimation {
      if selections.isEmpty {
        removeAllSelections()
        return
      }
      
      for selection in selections {
        renderOrUpdateSelection(selection)
      }
    }
  }
  
  func renderRemovalSelections(_ selections: [Selection]) {
    for selection in selections {
      if let drawable = selectionDrawables.model(for: selection.id) {
        removeDrawable(drawable)
        selectionDrawables.remove(with: selection.id)
      }
    }
  }
  
  func getOrCreateSelectionLayer<T: CALayer & DrawableElement>(id: String, creationClosure: (String) -> T) -> T {
    if let selectionTypeLayer = selectionDrawables.model(for: id) as? T {
      return selectionTypeLayer
    } else {
      let layer = creationClosure(id)
      selectionsLayer.addSublayer(layer)
      selectionDrawables.update(layer)
      return layer
    }
  }
  
  
  func getOrCreateSelectionControl<T: NSControl & DrawableElement>(id: String,
                                                                   creationClosure: (String) -> T) -> T {
    if let selectionTypeLayer = selectionDrawables.model(for: id) as? T {
      return selectionTypeLayer
    } else {
      let view = creationClosure(id)
      selectionDrawables.update(view)
      selectionView.addSubview(view)
      return view
    }
  }
  
  func renderOrUpdateSelection(_ selection: Selection) {
    switch selection {
    case let knob as Knob:
      let layerToRender: ControlKnob = getOrCreateSelectionLayer(id: knob.id) { id in
        SelectionDrawablesFactory.createKnobLayer(with: id)
      }
      
      layerToRender.render(with: knob.frameRect,
                           backgroundColor: knob.backgroundColor,
                           borderColor: knob.borderColor,
                           borderWidth: 1.0)
    case let border as Border:
      let layerToRender: ControlBorder = getOrCreateSelectionLayer(id: border.id) { id in
        SelectionDrawablesFactory.createBorderLayer(with: id)
      }
      layerToRender.setup(with: border.path, strokeColor: border.color, lineWidth: border.lineWidth)
      
    case let legibilityControl as LegibilityControl:
      let buttonToRender: LegibilityControlButton = getOrCreateSelectionControl(id: legibilityControl.id) { id in
        
        SelectionDrawablesFactory.createLegibilityButton(with: id,
                                                         target: self,
                                                         action: #selector(legibilityButtonPressed(_ :)))
      }
      
      buttonToRender.setupWith(frame: legibilityControl.frameRect,
                               imageType: legibilityControl.isEnabled ? .enabled : .disabled)
      
    case let emojiControl as EmojiControl:
      let buttonToRender: EmojiControlButton = getOrCreateSelectionControl(id: emojiControl.id) { id in
        SelectionDrawablesFactory.createEmojiButton(with: id,
                                                    target: self,
                                                    action: #selector(emojiButtonPressed(_ :)))
      }
      
      buttonToRender.setup(with: emojiControl.frameRect)
    default:
      break
    }
  }
  
  func removeAllSelections() {
    selectionDrawables.all.forEach { removeDrawable($0) }
    selectionDrawables.clearAll()
  }
  
  // MARK: - Cursor
  
  func setCursor(for type: CursorType) {
    let cursor = CursorHelper().cursor(for: type)
    cursor.set()
  }
  
  // MARK: - Actions
  @objc
  func legibilityButtonPressed(_ button: LegibilityControlButton) {
    legibilityButtonPressedSubject.send(button.id)
    print("Button pressed = \(button.id)")
  }
  
  @objc
  func emojiButtonPressed(_ button: EmojiControlButton) {
    emojiButtonPressedSubject.send(button.id)
  }
  
  func presentEmojiesPicker(for textId: String) {
    guard let textAnnotation = drawable(with: textId) as? TextAnnotationView else { return }
    emojiPickerisPresented.send(true)
    textAnnotation.presentEmojiPicker()
    
    emojiPickerPresentedCancellable =
    NotificationCenter
      .default
      .publisher(for: NSWindow.didBecomeKeyNotification, object: window)
      .first()
      .print()
      .map { _ in false }
      .assign(to: \.value, on: emojiPickerisPresented)
  }
  
}

extension DrawableCanvasView {
  func renderLineDashPhaseAnimation(for layerId: String,
                                    animation: LineDashPhaseAnimation,
                                    remove: Bool) {
    guard let layer = drawable(with: layerId) as? CanvasShapeLayer else { return }
    if remove {
      layer.removeLineDashPhaseAnimation(key: animation.animationKey)
    } else {
      layer.addLineDashPhaseAnimation(animation)
    }
  }
}
