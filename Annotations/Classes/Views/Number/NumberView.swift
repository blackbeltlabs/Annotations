import Foundation

class NumberView: DrawableView {
  var state: ViewState<NumberModel> {
    didSet {
      render(state: state, oldState: oldValue)
    }
  }
  
  weak var delegate: CanvasDrawableDelegate?
  var layer: CAShapeLayer
  
  let textLayer: CATextLayer = {
    let numberLayer = NumberTextLayer()
    numberLayer.font = "Helvetica-Bold" as CFTypeRef
    numberLayer.fontSize = 20
    numberLayer.alignmentMode = .center
    numberLayer.foregroundColor = NSColor.white.cgColor
    return numberLayer
  }()
  
  var globalIndex: Int
  var modelIndex: Int
  
  var color: NSColor? {
    guard let color = layer.fillColor else { return nil }
    return NSColor(cgColor: color)
  }
  
  lazy var knobDict: [RectPoint: KnobView] = [
    .origin: KnobView(model: model.origin),
    .to: KnobView(model: model.to),
    .originY: KnobView(model: model.origin.returnPointModel(dx: model.origin.x, dy: model.to.y)),
    .toX: KnobView(model: model.to.returnPointModel(dx: model.to.x, dy: model.origin.y))
  ]
  
  var knobs: [KnobView] {
    RectPoint.allCases.map { knobAt(rectPoint: $0)}
  }
  
  func knobAt(rectPoint: RectPoint) -> KnobView {
    return knobDict[rectPoint]!
  }
  
  // MARK: - Init
  convenience init(state: ViewState<NumberModel>,
                   modelIndex: Int,
                   globalIndex: Int,
                   color: ModelColor) {
    
    let layerColor = NSColor.color(from: color).cgColor
    let layer = type(of: self).createLayer(color: layerColor)
    
    self.init(state: state, modelIndex: modelIndex, globalIndex: globalIndex, layer: layer)
  }
  
  init(state: ViewState<NumberModel>, modelIndex: Int, globalIndex: Int, layer: CAShapeLayer) {
    self.state = state
    self.modelIndex = modelIndex
    self.globalIndex = globalIndex
    self.layer = layer
    self.layer.addSublayer(textLayer)
    self.render(state: state)
  }
  
  static var modelType: CanvasItemType { return .number }
  
  var model: NumberModel { return state.model }
  
  var isSelected: Bool {
    get { return state.isSelected }
    set { state.isSelected = newValue }
  }
  
  // MARK: - Path
  static func createPath(model: NumberModel) -> CGPath {
  
    CGPath(ellipseIn: model.rect, transform: nil)
  }
  
  func knobAt(point: PointModel) -> KnobView? {
    return knobs.first(where: { (knob) -> Bool in
      return knob.contains(point: point)
    })
  }
  
  func draggedKnob(_ knob: KnobView, from: PointModel, to: PointModel) {
    if let rectPoint = (RectPoint.allCases.first { (rectPoint) -> Bool in
      return knobDict[rectPoint]! === knob
    }) {
      let delta = from.deltaTo(to)
      state.model = model.copyMoving(rectPoint: rectPoint, delta: delta)
    }
  }
  
  func dragged(from: PointModel, to: PointModel) {
    let delta = from.deltaTo(to)
    state.model = model.copyMoving(delta: delta)
  }
  
  // MARK: - Layer
  static func createLayer(color: CGColor) -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.fillColor = color
    layer.strokeColor = NSColor.clear.cgColor
    layer.lineWidth = 0

    return layer
  }

  func render(state: ViewState<NumberModel>, oldState: ViewState<NumberModel>? = nil) {
    if state.model != oldState?.model {
      layer.shapePath = Self.createPath(model: state.model)
   
      textLayer.string = NSString(format: "%d", model.number)
      textLayer.frame = layer.bounds
      
      textLayer.contentsScale = 2.0
      
      textLayer.fontSize = state.model.size.height * 0.6

      layer.removeAllAnimations()
      textLayer.removeAllAnimations()
      
      
      for rectPoint in RectPoint.allCases {
        knobAt(rectPoint: rectPoint).state.model = state.model.valueFor(rectPoint: rectPoint)        
      }
      
      delegate?.drawableView(self, didUpdate: state.model, atIndex: modelIndex)
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
    state.model = model.copyWithColor(color: color.annotationModelColor)
  }
}
