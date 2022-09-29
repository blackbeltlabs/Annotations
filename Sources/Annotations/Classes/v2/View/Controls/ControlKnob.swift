import QuartzCore

final class ControlKnob: CanvasLayer {
  
  // MARK: - Init
  init(backgroundColor: CGColor, borderColor: CGColor) {
    super.init()
    setup(backgroundColor: backgroundColor, borderColor: borderColor)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  private func setup(backgroundColor: CGColor, borderColor: CGColor) {
    masksToBounds = true
    self.backgroundColor = backgroundColor
    borderWidth = 1.0
    self.borderColor = borderColor
  }
  
  // MARK: - Render
  func render(with rect: CGRect) {
    self.frame = rect
  }
  
  override func layoutSublayers() {
    super.layoutSublayers()
    cornerRadius = bounds.width / 2.0
  }
}


