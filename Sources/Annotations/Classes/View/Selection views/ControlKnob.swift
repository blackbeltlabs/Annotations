import QuartzCore

final class ControlKnob: CanvasLayer, @unchecked Sendable {
  
  // MARK: - Init
  override init() {
    super.init()
    masksToBounds = true
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(layer: Any) {
    super.init(layer: layer
    )
  }
  
  // MARK: - Render
  func render(with rect: CGRect, backgroundColor: CGColor, borderColor: CGColor, borderWidth: CGFloat) {
    self.frame = rect
    self.backgroundColor = backgroundColor
    self.borderWidth = 1.0
    self.borderColor = borderColor
  }
  
  override func layoutSublayers() {
    super.layoutSublayers()
    cornerRadius = bounds.width / 2.0
  }
}


