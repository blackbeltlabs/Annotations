import Cocoa
import Combine

public class DrawableCanvasView: NSView {
  let obfuscateLayer: ObfuscateLayer = ObfuscateLayer()
  let imageColorsCalculator = ImageColorsCalculator()

  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    wantsLayer = true
    
    layer?.addSublayer(obfuscateLayer)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  let viewSizeUpdated = PassthroughSubject<CGSize, Never>()
  
  
  public override func layout() {
    super.layout()
    viewSizeUpdated.send(frame.size)
    obfuscateLayer.frame = bounds
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
    
    return regularLayers + obfuscateLayers
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
                                                                      renderingSet: LayerRenderingSet) -> T {
    if let layer = drawable(with: id) as? T {
      renderNormalLayer(layer: layer,
                        path: renderingSet.path,
                        settings: renderingSet.settings,
                        zPosition: renderingSet.zPosition)
      return layer
    } else {
      let newLayer: T = createNormalLayer(with: id)
      if type == .normal {
        layer?.addSublayer(newLayer)
      } else {
        obfuscateLayer.addObfuscatedArea(newLayer)
      }
      renderNormalLayer(layer: newLayer,
                        path: renderingSet.path,
                        settings: renderingSet.settings,
                        zPosition: renderingSet.zPosition)
      return newLayer
    }
  }
  
  func renderNumber(id: String, renderingSet: LayerRenderingSet, numberValue: Int, numberFontSize: CGFloat) {
    let numberLayer = renderAnyShapeLayer(of: NumberLayer.self,
                                          id: id,
                                          type: .normal,
                                          renderingSet: renderingSet)
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
  
  func renderObfuscatedArea(_ type: ObfuscatedAreaType) {
    switch type {
    case .solidColor(let color):
      let fallbackImage = ObfuscateRendererHelper.obfuscateFallbackImage(size: frame.size,
                                                                         color)
      obfuscateLayer.setObfuscatedAreaContents(fallbackImage)
    case .image(let image):
      let size = frame.size
      imageColorsCalculator.mostUsedColors(from: image, count: 5) { [weak self] colors in
        guard let self = self else { return }
        let paletteImage = ObfuscateRendererHelper.obfuscatePaletteImage(size: size,
                                                                         colorPalette: colors)
        
        DispatchQueue.main.async {
          if let paletteImage {
            self.obfuscateLayer.setObfuscatedAreaContents(paletteImage)
          } else {
            self.renderObfuscatedArea(.solidColor(.black))
          }
        }
      }
    }
  }
  
  func renderText(text: Text) {
    
  }
  
  private func drawable(with id: String) -> DrawableElement? {
    drawables.first(where: { $0.id == id })
  }
}
