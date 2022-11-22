import Foundation
import CoreGraphics

class ControlBorder: CanvasShapeLayer {
  func setup(with path: CGPath, strokeColor: CGColor, lineWidth: CGFloat) {
    masksToBounds = false
    fillColor = .clear
    self.strokeColor = strokeColor
    self.lineWidth = lineWidth
    self.path = path
  }
}
