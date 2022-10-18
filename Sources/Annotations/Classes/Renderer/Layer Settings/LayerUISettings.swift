import CoreGraphics
import Quartz

struct LayerUISettings {
  let lineWidth: CGFloat
  let strokeColor: CGColor?
  let fillColor: CGColor?
  let lineJoin: CAShapeLayerLineJoin
  let lineCap: CAShapeLayerLineCap
  let fillRule: CAShapeLayerFillRule
  let lineDash: (phase: CGFloat, lengths: [CGFloat]?)
  
  internal init(lineWidth: CGFloat,
                strokeColor: CGColor? = nil,
                fillColor: CGColor? = nil,
                lineJoin: CAShapeLayerLineJoin = .miter,
                lineCap: CAShapeLayerLineCap = .butt,
                fillRule: CAShapeLayerFillRule = .nonZero,
                lineDash: (phase: CGFloat, lengths: [CGFloat]?) = (0, nil)) {
    self.lineWidth = lineWidth
    self.strokeColor = strokeColor
    self.fillColor = fillColor
    self.lineJoin = lineJoin
    self.lineCap = lineCap
    self.fillRule = fillRule
    self.lineDash = lineDash
  }
}
