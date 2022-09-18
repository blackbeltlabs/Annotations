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
                   path: CGPath,
                   settings: LayerUISettings,
                   zPosition: CGFloat) {
    
    if let layer = drawable(with: id) as? CanvasShapeLayer {
      renderNormalLayer(layer: layer, path: path, settings: settings, zPosition: zPosition)
    } else {
      let newLayer = createNormalLayer(with: id)
      layer?.addSublayer(newLayer)
      renderNormalLayer(layer: newLayer, path: path, settings: settings, zPosition: zPosition)
    }
  }
  
  func createNormalLayer(with id: String) -> CanvasShapeLayer {
    let layer = CanvasShapeLayer()
    layer.id = id
    if let backingScaleFactor = window?.screen?.backingScaleFactor {
      layer.contentsScale = backingScaleFactor
    }
    return layer
  }
    
  func renderNormalLayer(layer: CanvasShapeLayer, path: CGPath, settings: LayerUISettings, zPosition: CGFloat) {
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
