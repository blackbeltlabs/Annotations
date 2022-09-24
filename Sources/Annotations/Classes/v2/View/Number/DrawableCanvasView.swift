import Cocoa
import Combine

public class DrawableCanvasView: NSView {
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    wantsLayer = true
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  let viewSizeUpdated = PassthroughSubject<CGSize, Never>()
}


protocol DrawableElement {
  var id: String { get set }
}

extension DrawableCanvasView: RendererCanvas {
  
  public override var isFlipped: Bool { true }
  
  var drawables: [DrawableElement] {
    let sublayers = layer?.sublayers ?? []
  
    return sublayers.compactMap { $0 as? DrawableElement }
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
      layer?.addSublayer(newLayer)
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
  
  func renderText(text: Text) {
    
  }
  
  private func drawable(with id: String) -> DrawableElement? {
    drawables.first(where: { $0.id == id })
  }
  
  public override func layout() {
    super.layout()
    viewSizeUpdated.send(frame.size)
  }
}
