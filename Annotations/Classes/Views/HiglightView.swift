import Foundation

protocol HighlightViewDelegate {
  func highlightView(_ highlightView: HighlightView, didUpdate model: HighlightModel, atIndex index: Int)
  func highlightViewRects() -> [CGRect]
}

struct HighlightViewState {
  var model: HighlightModel
  var isSelected: Bool
}

class HiglightParentLayer: CALayer {}
class HighlightLayerMask: CAShapeLayer {}
class HighlightLayer: CAShapeLayer {}

class HighlightView: CanvasDrawable {
  var state: HighlightViewState {
    didSet {
      self.render(state: self.state, oldState: oldValue)
    }
  }
  
  var delegate: HighlightViewDelegate?
  
  var layer: HighlightLayer
  var maskRects: [CGRect]
  var maskPath: CGPath?
  var globalIndex: Int
  var modelIndex: Int
  
  var color: NSColor? {
    guard let color = layer.strokeColor else { return nil }
    return NSColor(cgColor: color)
  }
  
  lazy var knobDict: [RectPoint: KnobView] = [
    .origin: KnobView(model: model.origin),
    .to: KnobView(model: model.to),
    .originY: KnobView(model: model.origin.returnPointModel(dx: model.origin.x, dy: model.to.y)),
    .toX: KnobView(model: model.to.returnPointModel(dx: model.to.x, dy: model.origin.y))
  ]
  
  convenience init(state: HighlightViewState,
                   modelIndex: Int,
                   globalIndex: Int,
                   maskRects: [CGRect],
                   color: ModelColor) {
    
    let layerColor = NSColor.color(from: color).cgColor
    let layer = type(of: self).createLayer(color: layerColor, state: state)
    
    self.init(state: state, modelIndex: modelIndex, globalIndex: globalIndex, layer: layer, maskRects: maskRects)
  }
  
  init(state: HighlightViewState, modelIndex: Int, globalIndex: Int, layer: HighlightLayer, maskRects: [CGRect]) {
    self.state = state
    self.modelIndex = modelIndex
    self.globalIndex = globalIndex
    self.layer = layer
    self.maskRects = maskRects
    self.render(state: state)
  }
  
  static var modelType: CanvasItemType { .highlight }
  
  var model: HighlightModel { state.model }
  
  var knobs: [KnobView] {
    RectPoint.allCases.map { knobAt(rectPoint: $0)}
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
      
      let bezier = NSBezierPath.concaveRectPath(rect: newValue.boundingBoxOfPath, radius: 4)
      
      if let mask = layer.superlayer?.mask as? HighlightLayerMask {
        let maskPath = CGMutablePath()
        maskRects[modelIndex] = newValue.boundingBoxOfPath
        maskRects.forEach {
          maskPath.addPath(NSBezierPath.concaveRectPath(rect: $0, radius: 4))
        }
        maskPath.addRect(frame)
        mask.path = maskPath
      }
      
      if let maskLayer = layer.mask as? HighlightLayerMask {
        let layerPath = CGMutablePath()
        layerPath.addPath(bezier)
        layerPath.addRect(frame)
        maskLayer.path = layerPath
      }
      
      self.maskPath = bezier
    }
  }
  
  var isSelected: Bool {
    get { return state.isSelected }
    set { state.isSelected = newValue }
  }
  
  static func createPath(model: RectModel) -> CGPath {
    return NSBezierPath(rect: NSRect(fromPoint: model.origin.cgPoint, toPoint: model.to.cgPoint)).cgPath
  }
  
  static func createLayer(color: CGColor, state: HighlightViewState) -> HighlightLayer {
    let maskLayer = HighlightLayerMask()
    maskLayer.fillRule = .evenOdd
    
    let layer = HighlightLayer()
    layer.fillColor = NSColor.clear.cgColor
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
    return maskPath?.contains(point.cgPoint) ?? false
  }
  
  func parentLayer(from canvas: CanvasView) -> HiglightParentLayer? {
    return canvas.canvasLayer.sublayers?.first { type(of: $0) == HiglightParentLayer.self } as? HiglightParentLayer
  }
  
  func childrenLayers(from canvas: CanvasView) -> [HighlightLayer] {
    return canvas.canvasLayer.sublayers?.filter { type(of: $0) == HighlightLayer.self } as? [HighlightLayer] ?? []
  }
  
  func addTo(canvas: CanvasView) {
    var maskLayer: HighlightLayerMask
    if let parent = parentLayer(from: canvas) {
      parent.addSublayer(layer)
      maskLayer = parent.mask as! HighlightLayerMask
    } else {
      let parent = HiglightParentLayer()
      parent.frame = canvas.canvasLayer.frame
      parent.backgroundColor = NSColor.color(from: .transparent).cgColor
      
      canvas.canvasLayer.addSublayer(parent)
      parent.addSublayer(layer)
      
      let mask = HighlightLayerMask()
      mask.fillRule = .evenOdd
      parent.mask = mask
      maskLayer = mask
    }
    
    let maskPath = CGMutablePath()
    let frame = NSScreen.main?.frame ?? .zero
    maskRects.forEach {
      maskPath.addPath(NSBezierPath.concaveRectPath(rect: $0, radius: 4))
    }
    maskPath.addRect(frame)
    maskLayer.path = maskPath
  }
  
  func removeFrom(canvas: CanvasView) {
    layer.removeFromSuperlayer()
    knobs.forEach { $0.removeFrom(canvas: canvas) }
    
    if childrenLayers(from: canvas).isEmpty {
      parentLayer(from: canvas)?.removeFromSuperlayer()
    }
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
      maskRects = delegate?.highlightViewRects() ?? maskRects
      path = type(of: self).createPath(model: model)
      
      for rectPoint in RectPoint.allCases {
        knobAt(rectPoint: rectPoint).state.model = state.model.valueFor(rectPoint: rectPoint)
      }
      
      delegate?.highlightView(self, didUpdate: self.model, atIndex: self.modelIndex)
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
