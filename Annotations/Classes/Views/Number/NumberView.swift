import Foundation

enum NumberPoint: CaseIterable {
  case origin
  case originToX
  case originToY
  case originToXY
}

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
  
  lazy var knobDict: [NumberPoint: KnobView] = [
    .origin: KnobView(model: model.origin.pointModel),
    .originToX: KnobView(model: model.originToX.pointModel),
    .originToY: KnobView(model: model.originToY.pointModel),
    .originToXY: KnobView(model: model.originToXY.pointModel)
  ]
  
  var knobs: [KnobView] {
    NumberPoint.allCases.map { knobAt(numberPoint: $0)}
  }
  
  func knobAt(numberPoint: NumberPoint) -> KnobView {
    return knobDict[numberPoint]!
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
  
  // no knobs for this shape
  func knobAt(point: PointModel) -> KnobView? {
    return nil
  }
  
  func draggedKnob(_ knob: KnobView, from: PointModel, to: PointModel) {
    
  }
  
  func dragged(from: PointModel, to: PointModel) {
    let delta = from.deltaTo(to)
    state.model.centerPoint = state.model.centerPoint.copyMoving(delta: delta)
  }
  
  // MARK: - Layer
  static func createLayer(color: CGColor) -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.fillColor = color
    layer.strokeColor = NSColor.clear.cgColor
    layer.lineWidth = 0

    return layer
  }

  func render(state:  ViewState<NumberModel>, oldState: ViewState<NumberModel>? = nil) {
    if state.model != oldState?.model {
      layer.shapePath = Self.createPath(model: state.model)
   
      textLayer.string = NSString(format: "%d", model.number)
      textLayer.frame = layer.bounds
      
      textLayer.contentsScale = 2.0

      layer.removeAllAnimations()
      textLayer.removeAllAnimations()
      
      
      for numberPoint in NumberPoint.allCases {
        knobAt(numberPoint: numberPoint).state.model = state.model.valueFor(numberPoint: numberPoint)
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
