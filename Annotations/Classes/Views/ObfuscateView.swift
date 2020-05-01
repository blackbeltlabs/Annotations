import Foundation
import Cocoa

protocol ObfuscateViewDelegate {
  func obfuscateView(_ view: ObfuscateView, didUpdate model: ObfuscateModel, atIndex index: Int)
}

struct ObfuscateViewState {
  var model: ObfuscateModel
  var isSelected: Bool
}

protocol ObfuscateView: CanvasDrawable {
  var delegate: ObfuscateViewDelegate? { get set }
  var state: ObfuscateViewState { get set }
  var modelIndex: Int { get set }
  var layer: CAShapeLayer { get }
  var knobDict: [RectPoint: KnobView] { get }
  
}

extension ObfuscateView {
  static var modelType: CanvasItemType { return .obfuscate }
  
  var model: ObfuscateModel { return state.model }
  
  var knobs: [KnobView] {
    return RectPoint.allCases.map { knobAt(rectPoint: $0)}
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
  
  static func createPath(model: RectModel) -> CGPath {
    return NSBezierPath(rect: NSRect(fromPoint: model.origin.cgPoint, toPoint: model.to.cgPoint)).cgPath
  }
  
  static func createLayer() -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.fillColor = NSColor.obfuscate.cgColor
    layer.strokeColor = NSColor.obfuscate.cgColor
    layer.lineWidth = 0
    
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
  
  func render(state: ObfuscateViewState, oldState: ObfuscateViewState? = nil) {
    if state.model != oldState?.model {
      layer.shapePath = type(of: self).createPath(model: model)
      
      for rectPoint in RectPoint.allCases {
        knobAt(rectPoint: rectPoint).state.model = state.model.valueFor(rectPoint: rectPoint)
      }
      
      self.delegate?.obfuscateView(self, didUpdate: self.model, atIndex: self.modelIndex)
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
    
  }
}

class ObfuscateViewClass: ObfuscateView {
  var state: ObfuscateViewState {
    didSet {
      self.render(state: self.state, oldState: oldValue)
    }
  }
  
  var delegate: ObfuscateViewDelegate?
  
  var layer: CAShapeLayer
  var globalIndex: Int
  var modelIndex: Int
  let color: NSColor?
  
  lazy var knobDict: [RectPoint: KnobView] = [
    .origin: KnobViewClass(model: model.origin),
    .to: KnobViewClass(model: model.to),
    .originY: KnobViewClass(model: model.origin.returnPointModel(dx:model.origin.x, dy:model.to.y)),
    .toX: KnobViewClass(model: model.to.returnPointModel(dx:model.to.x, dy:model.origin.y))
  ]
  
  convenience init(state: ObfuscateViewState,
                   modelIndex: Int,
                   globalIndex: Int,
                   color: ModelColor) {
    
    let layer = type(of: self).createLayer()
    
    self.init(state: state, modelIndex: modelIndex, globalIndex: globalIndex, layer: layer, color: color)
  }
  
  init(state: ObfuscateViewState, modelIndex: Int, globalIndex: Int, layer: CAShapeLayer, color: ModelColor) {
    self.state = state
    self.modelIndex = modelIndex
    self.globalIndex = globalIndex
    self.layer = layer
    self.color = NSColor.color(from: color)
    self.render(state: state)
  }
}
