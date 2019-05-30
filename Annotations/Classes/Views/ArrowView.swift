//
//  ArrowView.swift
//  Annotate
//
//  Created by Mirko on 12/30/18.
//  Copyright © 2018 Blackbelt Labs. All rights reserved.
//

import Cocoa

protocol ArrowViewDelegate {
  func arrowView(_ arrowView: ArrowView, didUpdate model: ArrowModel, atIndex index: Int)
}

struct ArrowViewState {
  var model: ArrowModel
  var isSelected: Bool
}

protocol ArrowView: CanvasDrawable {
  var delegate: ArrowViewDelegate? { get set }
  var state: ArrowViewState { get set }
  var modelIndex: Int { get set }
  var layer: CAShapeLayer { get }
  var knobDict: [ArrowPoint: KnobView] { get }
}

extension ArrowView {
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
      tailWidth: 5,
      headWidth: 15,
      headLength: length >= 20 ? 20 : CGFloat(length)
    )
    
    return arrow.cgPath
  }
  
  static func createLayer() -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.fillColor = NSColor.annotations.cgColor
    layer.strokeColor = NSColor.annotations.cgColor
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
    let arrowPoint = (ArrowPoint.allCases.first { (arrowPoint) -> Bool in
      return knobDict[arrowPoint]! === knob
    })!
    let delta = from.deltaTo(to)
    state.model = model.copyMoving(arrowPoint: arrowPoint, delta: delta)
  }
  
  func render(state: ArrowViewState, oldState: ArrowViewState? = nil) {
    if state.model != oldState?.model {
      layer.shapePath = ArrowViewClass.createPath(model: state.model)
      
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
}

class ArrowViewClass: ArrowView {
  var state: ArrowViewState {
    didSet {
      render(state: state, oldState: oldValue)
    }
  }
  
  var delegate: ArrowViewDelegate?
  
  var layer: CAShapeLayer
  var modelIndex: Int
  
  lazy var knobDict: [ArrowPoint: KnobView] = [
    .origin: KnobViewClass(model: model.origin),
    .to: KnobViewClass(model: model.to)
  ]
  
  init(state: ArrowViewState, modelIndex: Int) {
    self.state = state
    self.modelIndex = modelIndex
    layer = ArrowViewClass.createLayer()
    render(state: state)
  }
}
