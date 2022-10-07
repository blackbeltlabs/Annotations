import Cocoa
import Combine

private enum MouseEventType {
  case down
  case dragged
  case up
}

public class DrawableCanvasView: NSView {
  // MARK: - Layers
  let obfuscateLayer: ObfuscateLayer = ObfuscateLayer()
  let higlightsLayer = HiglightsLayer()
  
  let selectionsLayer = CALayer()
  
  private var knobLayers: [CALayer] = []
  
  // MARK: - Touches
  private var trackingArea: NSTrackingArea?

  // MARK: - Helpers
  let imageColorsCalculator = ImageColorsCalculator()
  
  // MARK: - Publishers
  let viewSizeUpdated = PassthroughSubject<CGSize, Never>()
  
  let mouseDownSubject = PassthroughSubject<CGPoint, Never>()
  let mouseDraggedSubject = PassthroughSubject<CGPoint, Never>()
  let mouseUpSubject = PassthroughSubject<CGPoint, Never>()
  
  var isUserInteractionEnabled: Bool = true
  
  // MARK: - Cancellables
  
  var commonCancellables = Set<AnyCancellable>()
  
  // MARK: - Init
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    wantsLayer = true
    
    layer?.addSublayer(obfuscateLayer)
    layer?.addSublayer(higlightsLayer)
    layer?.addSublayer(selectionsLayer)
    
    selectionsLayer.zPosition = 10000000
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Frame updates
  public override var frame: NSRect {
    didSet {
      viewSizeUpdated.send(frame.size)
    }
  }
  
  public override func layout() {
    super.layout()
    obfuscateLayer.frame = bounds
    higlightsLayer.frame = bounds
    selectionsLayer.frame = bounds
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
    }
  }
  
  private func mousePressPoint(from event: NSEvent) -> CGPoint {
    convert(event.locationInWindow, from: nil)
  }
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
  
  func renderText(text: Text) {
    // FIXME: - Implement update here
    if let textAnnotation = drawable(with: text.id) as? TextAnnotationView {
      renderTextAnnotation(textAnnotation, with: text)
    } else {
      let textView = TextAnnotationView(frame: frame)
      self.addSubview(textView)
      renderTextAnnotation(textView, with: text)
    }
  }
  
  private func renderTextAnnotation(_ annotation: TextAnnotationView,
                                    with textModel: Text) {
    let frame = CGRect(fromPoint: textModel.origin.cgPoint,
                       toPoint: textModel.to.cgPoint)
    
    annotation.id = textModel.id
    annotation.frame = frame
    annotation.string = textModel.text
    annotation.setStyle(textModel.style)
    annotation.setLegibilityEffectEnabled(textModel.legibilityEffectEnabled)
    annotation.setZPosition(textModel.zPosition)
    annotation.isEditable = false
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
    drawables.forEach { self.removeDrawable($0) }
    knobLayers.forEach { $0.removeFromSuperlayer() }
  }
}

extension DrawableCanvasView {
  
  func renderSelections(_ selections: [Selection]) {
    if selections.isEmpty {
      removeAllSelections()
      return
    }
    
    for selection in selections {
      renderOrUpdateSelection(selection)
    }
  }
  
  func renderOrUpdateSelection(_ selection: Selection) {
    switch selection {
    case let knob as Knob:
      let layerToRender: ControlKnob
      if let knobLayer = knobLayers.compactMap({ $0 as? DrawableElement }).first(where: { $0.id == knob.id }) as? ControlKnob {
        layerToRender = knobLayer
      } else {
        layerToRender = createKnobLayer(with: knob.id)
        selectionsLayer.addSublayer(layerToRender)
        knobLayers.append(layerToRender)
      }
      layerToRender.render(with: knob.frameRect,
                           backgroundColor: NSColor.zapierOrange.cgColor,
                           borderColor: NSColor.knob.cgColor,
                           borderWidth: 1.0)
    case let border as Border:
      let layerToRender: ControlBorder
      
      if let borderLayer =  knobLayers.compactMap({ $0 as? DrawableElement }).first(where: { $0.id == border.id }) as? ControlBorder {
        layerToRender = borderLayer
      } else {
        layerToRender = createBorderLayer(with: border.id)
        selectionsLayer.addSublayer(layerToRender)
        knobLayers.append(layerToRender)
      }
      
      layerToRender.setup(with: border.path, strokeColor: border.color, lineWidth: border.lineWidth)
      
      print("Render border")
    default:
      break
    }
  }
  
  func createSelectionLayer<T: CALayer & DrawableElement>(of type: T.Type, id: String, zPosition: CGFloat) -> T {
    var selectionLayer = T()
    selectionLayer.id = id
    selectionLayer.zPosition = zPosition
    return selectionLayer
  }
  
  func createKnobLayer(with id: String) -> ControlKnob {
    createSelectionLayer(of: ControlKnob.self, id: id, zPosition: 2)
  }
  

  func createBorderLayer(with id: String) -> ControlBorder {
    createSelectionLayer(of: ControlBorder.self, id: id, zPosition: 1)
  }
  
  func removeAllSelections() {
    for knob in knobLayers {
      knob.removeFromSuperlayer()
    }

    knobLayers = []
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


extension TextContainerView: DrawableElement {
  
}
