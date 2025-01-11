import Quartz

class NumberLayer: CanvasShapeLayer, @unchecked Sendable {
  let textLayer: CATextLayer = {
    let numberLayer = NumberTextLayer()
    numberLayer.contentsScale = 2.0
    numberLayer.font = "Helvetica-Bold" as CFTypeRef
    numberLayer.fontSize = 20
    numberLayer.alignmentMode = .center
    numberLayer.foregroundColor = NSColor.white.cgColor
    return numberLayer
  }()
  
  // MARK: - Init
  override init() {
    super.init()
    MainActor.assumeIsolated() {
      addSublayer(textLayer)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(layer: Any) {
    super.init(layer: layer)
  }
}
