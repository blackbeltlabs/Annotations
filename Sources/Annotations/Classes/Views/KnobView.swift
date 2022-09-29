import Cocoa

public struct KnobViewState {
  var model: PointModel
}

public class KnobView {
  var state: KnobViewState {
    didSet {
      render(state: state, oldState: oldValue)
    }
  }
  
  static let width: CGFloat = 9
  
  var layer: CAShapeLayer
  
  init(model: PointModel) {
    state = KnobViewState(model: model)
    layer = CAShapeLayer()
    layer.fillColor = NSColor.zapierOrange.cgColor
    layer.strokeColor = NSColor.knob.cgColor
    layer.lineWidth = 1
    render(state: state)
  }
  
  var model: PointModel { return state.model }
  
  var path: CGPath {
    get {
      return layer.path!
    }
    set {
      layer.path = newValue
      layer.bounds = path.boundingBox
      layer.frame = layer.bounds
    }
  }
  
  static func createPath(model: PointModel) -> CGPath {
    let rect = model.cgPoint.centeredSquare(width: Self.width)
    return CGPath(ellipseIn: rect, transform: nil)
  }
  
  func update(model: PointModel) {
    layer.shapePath = Self.createPath(model: model)
  }
  
  func apply(transform: CGAffineTransform) {
    var mutableTransform = transform
    path = path.copy(using: &mutableTransform)!
  }
  
  func contains(point: PointModel) -> Bool {
    let distance = point.distanceTo(model)
    return distance < Double(Self.width / 2.0)
  }
  
  func addTo(canvas: CanvasView) {
    canvas.canvasLayer.addSublayer(layer)
  }
  
  func removeFrom(canvas: CanvasView) {
    layer.removeFromSuperlayer()
  }
  
  func render(state: KnobViewState, oldState: KnobViewState? = nil) {
    layer.shapePath = Self.createPath(model: model)
  }
}
