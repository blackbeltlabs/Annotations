import Foundation

protocol HighlightViewDelegate {
  func highlightView(_ highlightView: HighlightView, didUpdate model: RectModel, atIndex index: Int)
}

struct HighlightViewState {
  var model: RectModel
  var isSelected: Bool
}

protocol HighlightView: CanvasDrawable {
  var delegate: HighlightViewDelegate? { get set }
  var state: HighlightViewState { get set }
  var modelIndex: Int { get set }
  var layer: CAShapeLayer { get }
  var knobDict: [RectPoint: KnobView] { get }
  
}

extension HighlightView {
  static var modelType: CanvasItemType { return .highlight }
  
  var model: RectModel { return state.model }
  
  var knobs: [KnobView] {
    return RectPoint.allCases.map { knobAt(rectPoint: $0)}
  }
  
  var path: CGPath {
    get {
      return layer.path!
    }
    set {
      let frame = NSScreen.main?.frame ?? .zero
      let path = CGPath(rect: frame, transform: nil)
      layer.path = path
      layer.bounds = path.boundingBox
      layer.frame = layer.bounds
      
      guard let mask = layer.mask as? CAShapeLayer else { return }

      let maskPath = CGMutablePath()
      let bezier = NSBezierPath.concaveRectPath(rect: newValue.boundingBoxOfPath,
                                                radius: 4)
      maskPath.addPath(bezier)
      maskPath.addRect(frame)
      mask.path = maskPath
    }
  }
  
  var isSelected: Bool {
    get { return state.isSelected }
    set { state.isSelected = newValue }
  }
  
  static func createPath(model: RectModel) -> CGPath {
    return NSBezierPath(rect: NSRect(fromPoint: model.origin.cgPoint, toPoint: model.to.cgPoint)).cgPath
  }
  
  static func createLayer(color: CGColor, state: HighlightViewState) -> CAShapeLayer {
    let maskLayer = CAShapeLayer()
    maskLayer.fillRule = .evenOdd
    
    let layer = CAShapeLayer()
    layer.fillColor = NSColor.color(from: .transparent).cgColor
    layer.mask = maskLayer
    
    return layer
  }
  
  func knobAt(point: PointModel) -> KnobView? {
    return knobs.first(where: { (knob) -> Bool in
      return knob.contains(point: point)
    })
  }
  
  func knobAt(rectPoint: RectPoint) -> KnobView {
    return knobDict[rectPoint]!
  }
  
  func contains(point: PointModel) -> Bool {
    return layer.path!.contains(point.cgPoint)
  }
  
  func addTo(canvas: CanvasView) {
    canvas.canvasLayer.addSublayer(layer)
  }
  
  func removeFrom(canvas: CanvasView) {
    layer.removeFromSuperlayer()
    knobs.forEach { $0.removeFrom(canvas: canvas) }
  }
  
  func dragged(from: PointModel, to: PointModel) {
    let delta = from.deltaTo(to)
    state.model = model.copyMoving(delta: delta)
  }
  
  func draggedKnob(_ knob: KnobView, from: PointModel, to: PointModel) {
    if let rectPoint = (RectPoint.allCases.first { (rectPoint) -> Bool in
      return knobDict[rectPoint]! === knob
    }) {
      let delta = from.deltaTo(to)
      state.model = model.copyMoving(rectPoint: rectPoint, delta: delta)
    }
  }
  
  func render(state: HighlightViewState, oldState: HighlightViewState? = nil) {
    if state.model != oldState?.model {
      path = type(of: self).createPath(model: model)
      
      for rectPoint in RectPoint.allCases {
        knobAt(rectPoint: rectPoint).state.model = state.model.valueFor(rectPoint: rectPoint)
      }
      
      self.delegate?.highlightView(self, didUpdate: self.model, atIndex: self.modelIndex)
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
    layer.strokeColor = color.cgColor
    state.model = model.copyWithColor(color: color.annotationModelColor)
  }
}

class HighlightViewClass: HighlightView {
  var state: HighlightViewState {
    didSet {
      self.render(state: self.state, oldState: oldValue)
    }
  }
  
  var delegate: HighlightViewDelegate?
  
  var layer: CAShapeLayer
  var modelIndex: Int
  
  var color: NSColor? {
    guard let color = layer.strokeColor else { return nil }
    return NSColor(cgColor: color)
  }
  
  lazy var knobDict: [RectPoint: KnobView] = [
    .origin: KnobViewClass(model: model.origin),
    .to: KnobViewClass(model: model.to),
    .originY: KnobViewClass(model: model.origin.returnPointModel(dx:model.origin.x, dy:model.to.y)),
    .toX: KnobViewClass(model: model.to.returnPointModel(dx:model.to.x, dy:model.origin.y))
  ]
  
  convenience init(state: HighlightViewState, modelIndex: Int, color: ModelColor) {
    let layerColor = NSColor.color(from: color).cgColor
    let layer = type(of: self).createLayer(color: layerColor, state: state)
    
    self.init(state: state, modelIndex: modelIndex, layer: layer)
  }
  
  init(state: HighlightViewState, modelIndex: Int, layer: CAShapeLayer) {
    self.state = state
    self.modelIndex = modelIndex
    self.layer = layer
    self.render(state: state)
  }
}
