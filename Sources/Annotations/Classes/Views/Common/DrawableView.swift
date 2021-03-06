import Cocoa

protocol DrawableView: CanvasDrawable {
  var layer: CAShapeLayer { get }
  var knobs: [KnobView] { get }
}

extension DrawableView {
  func addTo(canvas: CanvasView, zPosition: CGFloat?) {
    canvas.canvasLayer.addSublayer(layer)
    if let zPosition = zPosition {
      layer.zPosition = zPosition
    } else {
      canvas.setMaximumZPosition(to: layer)
    }
  }
  
  func removeFrom(canvas: CanvasView) {
    layer.removeFromSuperlayer()
    knobs.forEach { $0.removeFrom(canvas: canvas) }
  }
  
  func contains(point: PointModel) -> Bool {
    layer.path!.contains(point.cgPoint)
  }
  
  func bringToTop(canvas: CanvasView) {
    canvas.setMaximumZPosition(to: layer)
  }
}
