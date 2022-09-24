import Quartz

class ObfuscateLayer: CALayer {
  private let maskLayer: CALayer = CALayer()
    
  override init() {
    super.init()
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  private func setup() {
    self.mask = maskLayer
  }
  
  // MARK: - Obfuscated
  func addObfuscatedArea(_ shapeLayer: CAShapeLayer) {
    maskLayer.addSublayer(shapeLayer)
  }
  
  var allObfuscatedLayers: [CALayer] {
    maskLayer.sublayers ?? []
  }
}
