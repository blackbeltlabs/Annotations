import Quartz

class CanvasLayer: CALayer, DrawableElement {
  var id: String = ""
}

class CanvasShapeLayer: CAShapeLayer, DrawableElement {
  var id: String = ""
}


extension CAShapeLayer {
  func setup(with settings: LayerUISettings) {
    lineWidth = settings.lineWidth
    strokeColor = settings.strokeColor
    fillColor = settings.fillColor
    lineJoin = settings.lineJoin
    lineCap = settings.lineCap
    fillRule = settings.fillRule
    lineDashPhase = settings.lineDash.phase
    lineDashPattern = settings.lineDash.lengths?.compactMap { NSNumber(floatLiteral: $0) }
  }
}
