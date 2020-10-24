import Cocoa

protocol PenViewDelegate {
  func penView(_ penView: PenView, didUpdate model: PenModel, atIndex index: Int)
}

struct PenViewState {
  var model: PenModel
  var isSelected: Bool
}

class PenView: CanvasDrawable {
  var delegate: PenViewDelegate?
  var layer: CAShapeLayer
  
  var state: PenViewState {
    didSet {
      render(state: state, oldState: oldValue)
    }
  }
  
  var globalIndex: Int
  var modelIndex: Int
  var color: NSColor? {
    guard let color = layer.strokeColor else { return nil }
    return NSColor(cgColor: color)
  }
  
  init(state: PenViewState, modelIndex: Int, globalIndex: Int, color: ModelColor) {
    self.state = state
    self.modelIndex = modelIndex
    self.globalIndex = globalIndex
    layer = PenView.createLayer(color: NSColor.color(from:color).cgColor)
    render(state: state)
  }
  
  static var modelType: CanvasItemType { return .pen }
  
  var model: PenModel { return state.model }

  var isSelected: Bool {
    get { return state.isSelected }
    set { state.isSelected = newValue }
  }
  
  static func createPath(model: PenModel) -> CGPath {
    let points = model.points.map { $0.cgPoint }
    let path = NSBezierPath.line(points: points)
    
    return path.cgPath
  }
  
  static func createLayer(color: CGColor) -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.fillColor = NSColor.clear.cgColor
    layer.strokeColor = color
    layer.lineWidth = 5
    
    return layer
  }
  
  func addTo(canvas: CanvasView) {
    canvas.canvasLayer.addSublayer(layer)
  }
  
  func removeFrom(canvas: CanvasView) {
    layer.removeFromSuperlayer()
  }
  
  func contains(point: PointModel) -> Bool {
    let tapTargetPath = layer.path!.copy(strokingWithWidth: 10, lineCap: .butt, lineJoin: .miter, miterLimit: 1)

    return tapTargetPath.contains(point.cgPoint)
  }
  
  func knobAt(point: PointModel) -> KnobView? {
    return nil
  }
  
  func draggedKnob(_ knob: KnobView, from: PointModel, to: PointModel) {
    
  }
  
  func dragged(from: PointModel, to: PointModel) {
    if state.isSelected {
      let delta = from.deltaTo(to)
      state.model.points = state.model.points.map { $0.copyMoving(delta: delta) }
    } else {
      state.model.points.append(to)
    }
  }
  
  func render(state: PenViewState, oldState: PenViewState? = nil) {
    if state.model != oldState?.model {
      layer.shapePath = Self.createPath(model: state.model)
      
      delegate?.penView(self, didUpdate: state.model, atIndex: modelIndex)
    }
    
    if state.isSelected != oldState?.isSelected {
      if state.isSelected {
        select()
      } else {
        unselect()
      }
    }
  }
  
  func addAnimation() {
    layer.lineDashPattern = [10,5,5,5]
    
    let lineDashAnimation = CABasicAnimation(keyPath: "lineDashPhase")
    lineDashAnimation.fromValue = 0
    lineDashAnimation.toValue = layer.lineDashPattern?.reduce(0) { $0 + $1.intValue }
    lineDashAnimation.duration = 1.5
    lineDashAnimation.repeatCount = Float.greatestFiniteMagnitude
    layer.add(lineDashAnimation, forKey: "temp")
  }
  
  func select() {
    addAnimation()
  }
  
  func unselect() {
    layer.lineDashPattern = nil
    layer.removeAnimation(forKey: "temp")
  }
  
  
  func updateColor(_ color: NSColor) {
    layer.strokeColor = color.cgColor
    state.model = model.copyWithColor(color: color.annotationModelColor)
  }
}
