import Quartz

class CanvasShapeLayer: CAShapeLayer, DrawableElement {
  var id: String = ""
  
  func setup(with settings: LayerUISettings) {
    lineWidth = lineWidth
    strokeColor = settings.strokeColor
    fillColor = settings.fillColor
    lineJoin = settings.lineJoin
    lineCap = settings.lineCap
    fillRule = settings.fillRule
    lineDashPhase = settings.lineDash.phase
    lineDashPattern = settings.lineDash.lengths?.compactMap { NSNumber(floatLiteral: $0) }
  }
}
