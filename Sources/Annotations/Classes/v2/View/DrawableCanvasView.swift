import Cocoa
import Combine

public class DrawableCanvasView: NSView {
  let obfuscateLayer: ObfuscateLayer = ObfuscateLayer()
  let higlightsLayer = HiglightsLayer()
  let imageColorsCalculator = ImageColorsCalculator()

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    wantsLayer = true
    
    layer?.addSublayer(obfuscateLayer)
    layer?.addSublayer(higlightsLayer)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  let viewSizeUpdated = PassthroughSubject<CGSize, Never>()
  
  public override func layout() {
    super.layout()
   
    obfuscateLayer.frame = bounds
    higlightsLayer.frame = bounds
    
    viewSizeUpdated.send(frame.size)
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
    
    return regularLayers + obfuscateLayers + highlightDrawables
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
    numberLayer.textLayer.frame = numberLayer.path!.boundingBox
    numberLayer.textLayer.fontSize = numberFontSize
    numberLayer.textLayer.string = String(format: "%d", numberValue)
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
    
  }
  
  private func drawable(with id: String) -> DrawableElement? {
    drawables.first(where: { $0.id == id })
  }
}
