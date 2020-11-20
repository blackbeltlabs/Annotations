import Cocoa

protocol DrawableView: CanvasDrawable {
  var layer: CAShapeLayer { get }
}

extension DrawableView {
  func addTo(canvas: CanvasView) {
    canvas.canvasLayer.addSublayer(layer)
  }
  
  func removeFrom(canvas: CanvasView) {
    layer.removeFromSuperlayer()
  }
  
  func contains(point: PointModel) -> Bool {
    layer.path!.contains(point.cgPoint)
  }
}
