import Quartz

class CanvasLayer: CALayer, DrawableElement, @unchecked Sendable {
  var id: String = ""
}

class CanvasShapeLayer: CAShapeLayer, DrawableElement, @unchecked Sendable {
  var id: String = ""
}

extension CAShapeLayer {
  func setup(with settings: LayerUISettings) {
    
    // MARK: - Ideally to separate cases where animations is required and where it is not needed
    CATransaction.withoutAnimation {
      lineWidth = settings.lineWidth
    }
    strokeColor = settings.strokeColor
    fillColor = settings.fillColor
    lineJoin = settings.lineJoin
    lineCap = settings.lineCap
    fillRule = settings.fillRule
    lineDashPhase = settings.lineDash.phase
    lineDashPattern = settings.lineDash.lengths?.compactMap { NSNumber(floatLiteral: $0) }
  }
}
