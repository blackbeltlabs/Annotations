import Cocoa

protocol ArrowViewDelegate {
  func arrowView(_ arrowView: ArrowView, didUpdate model: ArrowModel, atIndex index: Int)
}

struct ArrowViewState {
  var model: ArrowModel
  var isSelected: Bool
}

class ArrowView: CanvasDrawable, DrawableView {
  var state: ArrowViewState {
    didSet {
      render(state: state, oldState: oldValue)
    }
  }
  
  var delegate: ArrowViewDelegate?
  
  var layer: CAShapeLayer
  var globalIndex: Int
  var modelIndex: Int
  
  var color: NSColor? {
    guard let fillColor = layer.fillColor else { return nil }
    return NSColor(cgColor: fillColor)
  }
  
  lazy var knobDict: [ArrowPoint: KnobView] = [
    .origin: KnobView(model: model.origin),
    .to: KnobView(model: model.to)
  ]
  
  init(state: ArrowViewState, modelIndex: Int, globalIndex: Int, color: ModelColor) {
    self.state = state
    self.modelIndex = modelIndex
    self.globalIndex = globalIndex
    layer = Self.createLayer(color: NSColor.color(from: color).cgColor)
    render(state: state)
  }
  
  static var modelType: CanvasItemType { return .arrow }

  var model: ArrowModel { return state.model }
  
  var knobs: [KnobView] {
    return ArrowPoint.allCases.map { knobAt(arrowPoint: $0) }
  }
  
  var path: CGPath {
    get {
      return layer.path!
    }
    set {
      layer.path = newValue
      layer.bounds = newValue.boundingBox
      layer.frame = layer.bounds
    }
  }
  
  var isSelected: Bool {
    get { return state.isSelected }
    set { state.isSelected = newValue }
  }
  
  static func createPath(model: ArrowModel) -> CGPath {
    let length = model.origin.distanceTo(model.to)
    let arrow = NSBezierPath.arrow(
      from: CGPoint(x: model.origin.x, y: model.origin.y),
      to: model.to.cgPoint,
      tailWidth: 5 + CGFloat(length) / 45,
      headWidth: 15 + CGFloat(length) / 15,
      headLength: length >= 20 ? 20 + CGFloat(length) / 15 : CGFloat(length)
    )
    
    return arrow.cgPath
  }
  
  static func createLayer(color: CGColor) -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.fillColor = color
    layer.strokeColor = color
    layer.lineWidth = 0
    
    return layer
  }
  
  func knobAt(point: PointModel) -> KnobView? {
    return knobs.first(where: { (knob) -> Bool in
      return knob.contains(point: point)
    })
  }
  
  func knobAt(arrowPoint: ArrowPoint) -> KnobView {
    return knobDict[arrowPoint]!
  }
  
  func dragged(from: PointModel, to: PointModel) {
    let delta = from.deltaTo(to)
    state.model = model.copyMoving(delta: delta)
  }
  
  func draggedKnob(_ knob: KnobView, from: PointModel, to: PointModel) {
    let arrowPoint = (ArrowPoint.allCases.first { (arrowPoint) -> Bool in
      return knobDict[arrowPoint]! === knob
    })!
    let delta = from.deltaTo(to)
    state.model = model.copyMoving(arrowPoint: arrowPoint, delta: delta)
  }
  
  func render(state: ArrowViewState, oldState: ArrowViewState? = nil) {
    if state.model != oldState?.model {
      layer.shapePath = Self.createPath(model: state.model)
      
      for arrowPoint in ArrowPoint.allCases {
        knobAt(arrowPoint: arrowPoint).state.model = state.model.valueFor(arrowPoint: arrowPoint)
      }
      
      delegate?.arrowView(self, didUpdate: model, atIndex: modelIndex)
    }
    
    if state.isSelected != oldState?.isSelected {
      if state.isSelected {
        knobs.forEach { (knob) in
          layer.addSublayer(knob.layer)
        }
      } else {
        CATransaction.withoutAnimation {
          knobs.forEach { (knob) in
            knob.layer.removeFromSuperlayer()
          }
        }
      }
    }
  }
  
  func updateColor(_ color: NSColor) {
    layer.fillColor = color.cgColor
    layer.strokeColor = color.cgColor
    state.model = model.copyWithColor(color: color.annotationModelColor)
  }
}
