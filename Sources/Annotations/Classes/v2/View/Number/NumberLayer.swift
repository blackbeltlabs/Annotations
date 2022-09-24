import Quartz

class NumberLayer: CanvasShapeLayer {
  let textLayer: CATextLayer = {
    let numberLayer = NumberTextLayer()
    numberLayer.contentsScale = 2.0
    numberLayer.font = "Helvetica-Bold" as CFTypeRef
    numberLayer.fontSize = 20
    numberLayer.alignmentMode = .center
    numberLayer.foregroundColor = NSColor.white.cgColor
    return numberLayer
  }()
  
  
  override init() {
    super.init()
    addSublayer(textLayer)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
