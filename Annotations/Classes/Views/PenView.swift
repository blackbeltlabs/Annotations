//
//  PenView.swift
//  Zappy Arrow Annotation
//
//  Created by Mirko on 1/6/19.
//  Copyright © 2019 Blackbelt Labs. All rights reserved.
//

import Cocoa

protocol PenViewDelegate {
  func penView(_ penView: PenView, didUpdate model: PenModel, atIndex index: Int)
}

struct PenViewState {
  var model: PenModel
  var isSelected: Bool
}

protocol PenView: CanvasDrawable {
  var delegate: PenViewDelegate? { get set }
  var state: PenViewState { get set }
  var layer: CAShapeLayer { get }
}

extension PenView {
  static var modelType: CanvasItemType { return .pen }

  var isSelected: Bool {
    get { return state.isSelected }
    set { state.isSelected = newValue }
  }
  
  static func createPath(model: PenModel) -> CGPath {
    let points = model.points.map { $0.cgPoint }
    let path = NSBezierPath.line(points: points)
    
    return path.cgPath
  }
  
  static func createLayer() -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.fillColor = NSColor.clear.cgColor
    layer.strokeColor = NSColor.annotations.cgColor
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
}

class PenViewClass: PenView {
  var delegate: PenViewDelegate?
  var layer: CAShapeLayer
  
  var state: PenViewState {
    didSet {
      render(state: state, oldState: oldValue)
    }
  }
  
  var modelIndex: Int
  
  init(state: PenViewState, modelIndex: Int) {
    self.state = state
    self.modelIndex = modelIndex
    layer = PenViewClass.createLayer()
    render(state: state)
  }
}
