import Quartz

class ObfuscateLayer: CALayer {
  private let maskLayer: CALayer = CALayer()
  
  // MARK: - Init
  override init(layer: Any) {
    super.init(layer: layer)
  }
    
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
  
  func setObfuscatedAreaContents(_ contents: Any) {
    self.contents = contents
  }
}
