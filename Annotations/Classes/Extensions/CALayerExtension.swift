import AppKit

extension CALayer {
  func applySketchShadow(
    color: NSColor = .black,
    alpha: Float = 0.5,
    xOffset: CGFloat = 0,
    yOffset: CGFloat = 2,
    blur: CGFloat = 4,
    spread: CGFloat = 0) {
    
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: xOffset, height: yOffset)
    shadowRadius = blur / 2.0
    if spread == 0 {
      shadowPath = nil
    } else {
      let dx = -spread
      let rect = bounds.insetBy(dx: dx, dy: dx)
      shadowPath = NSBezierPath(rect: rect).cgPath
    }
  }
}
