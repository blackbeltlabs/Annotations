import Cocoa
import Combine

public class DrawableCanvasView: NSView {
  // MARK: - Layers
  let obfuscateLayer: ObfuscateLayer = ObfuscateLayer()
  let higlightsLayer = HiglightsLayer()
  
  private var knobLayers: [CanvasLayer] = []
  
  // MARK: - Touches
  private var trackingArea: NSTrackingArea?

  // MARK: - Helpers
  let imageColorsCalculator = ImageColorsCalculator()
  
  // MARK: - Publishers
  let viewSizeUpdated = PassthroughSubject<CGSize, Never>()
  
  var isUserInteractionEnabled: Bool = true
  
  // MARK: - Cancellables
  
  var commonCancellables = Set<AnyCancellable>()
  
  // MARK: - Init
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    wantsLayer = true
    
    layer?.addSublayer(obfuscateLayer)
    layer?.addSublayer(higlightsLayer)
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
    
    print("Mouse down with = \(event)")
   // canvasViewEventsHandler.mouseDown(with: event)
  }
  
  override public func mouseDragged(with event: NSEvent) {
    super.mouseDragged(with: event)
    print("Mouse dragged with = \(event)")
   // canvasViewEventsHandler.mouseDragged(with: event)
  }
  
  override public func mouseUp(with event: NSEvent) {
    super.mouseUp(with: event)
    
    print("Mouse up with = \(event)")
 //   canvasViewEventsHandler.mouseUp(with: event)
  }
  
  public override func hitTest(_ point: NSPoint) -> NSView? {
    guard isUserInteractionEnabled else {
      return nil
    }
    return super.hitTest(point)
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
    if drawables.contains(where: { $0.id == text.id }) {
      return
    }
    
    let textAnnotation = TextContainerView(modelable: text, enableEmojies: true)
    textAnnotation.id = text.id
    textAnnotation.state = .inactive
    textAnnotation.layer?.zPosition = text.zPosition
   
    addSubview(textAnnotation)
  }
  
  private func drawable(with id: String) -> DrawableElement? {
    drawables.first(where: { $0.id == id })
  }
}

extension DrawableCanvasView {
  func renderKnobs(_ knobs: [Knob]) {
    removeAllKnobs()
    for knob in knobs {
      let knobLayer = createKnobLayer(with: knob.id)
      knobLayer.render(with: knob.frameRect)
      layer?.addSublayer(knobLayer)
      knobLayers.append(knobLayer)
    }
  }
  
  func createKnobLayer(with id: String) -> ControlKnob {
    let knob = ControlKnob(backgroundColor: NSColor.zapierOrange.cgColor,
                           borderColor: NSColor.knob.cgColor)
    knob.zPosition = 1000000
    knob.id = id
    return knob
  }
    
  func removeAllKnobs() {
    for knob in knobLayers {
      knob.removeFromSuperlayer()
    }
    
    knobLayers = []
  }
  
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
