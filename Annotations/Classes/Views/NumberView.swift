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
    let numberLayer = CATextLayer()
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
  
  
  // MARK: - Knobs
  
  // path
  
  static func createPath(model: NumberModel) -> CGPath {
    
    let radius = 15.0
    
    let point = model.point
    
    let rect = CGRect(x: point.x - radius,
                      y: point.y - radius,
                      width: radius * 2.0,
                      height: radius * 2.0)
    
    return CGPath(ellipseIn: rect, transform: nil)
  }
  
  // no knobs for this shape
  func knobAt(point: PointModel) -> KnobView? {
    return nil
  }
  
  func draggedKnob(_ knob: KnobView, from: PointModel, to: PointModel) {
    
  }
  
    
  func dragged(from: PointModel, to: PointModel) {
    let delta = from.deltaTo(to)
    state.model.point = state.model.point.copyMoving(delta: delta)
  }
  
  
  // layer
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
      textLayer.frame.origin.y += 1
      
      textLayer.contentsScale = 2.0

      layer.removeAllAnimations()
      textLayer.removeAllAnimations()
      
      delegate?.drawableView(self, didUpdate: state.model, atIndex: modelIndex)
    }
    
    // render depending on text selected or not
    if state.isSelected {
      layer.strokeColor = NSColor.black.cgColor
      layer.lineWidth = 2.0
    } else {
      layer.strokeColor = NSColor.clear.cgColor
      layer.lineWidth = 0.0
    }

  }
  
  func updateColor(_ color: NSColor) {
    layer.fillColor = color.cgColor
    state.model = model.copyWithColor(color: color.annotationModelColor)
  }
    
}
