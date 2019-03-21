//
//  KnobView.swift
//  Annotate
//
//  Created by Mirko on 12/30/18.
//  Copyright © 2018 Blackbelt Labs. All rights reserved.
//

import Cocoa

public struct KnobViewState {
  var model: PointModel
}

public protocol KnobView: class {
  static var width: CGFloat { get }
  static var color: NSColor { get }
  
  var state: KnobViewState { get set }
  var layer: CAShapeLayer { get set }
}

extension KnobView {
  var model: PointModel { return state.model }
  
  var path: CGPath {
    get {
      return layer.path!
    }
    set {
      layer.path = newValue
      layer.bounds = path.boundingBox
      layer.frame = layer.bounds
    }
  }
  
  static func createPath(model: PointModel) -> CGPath {
    let rect = model.cgPoint.centeredSquare(width: Self.width)
    return CGPath(ellipseIn: rect, transform: nil)
  }
  
  func update(model: PointModel) {
    layer.shapePath = Self.createPath(model: model)
  }
  
  func apply(transform: CGAffineTransform) {
    var mutableTransform = transform
    path = path.copy(using: &mutableTransform)!
  }
  
  func contains(point: PointModel) -> Bool {
    let distance = point.distanceTo(model)
    return distance < Double(Self.width / 2.0)
  }
  
  func addTo(canvas: CanvasView) {
    canvas.canvasLayer.addSublayer(layer)
  }
  
  func removeFrom(canvas: CanvasView) {
    layer.removeFromSuperlayer()
  }
  
  func render(state: KnobViewState, oldState: KnobViewState? = nil) {
    layer.shapePath = Self.createPath(model: model)
  }
}

class KnobViewClass: KnobView {
  var state: KnobViewState {
    didSet {
      render(state: state, oldState: oldValue)
    }
  }
  
  static let width: CGFloat = 10
  static let color: NSColor = .gray
  
  var layer: CAShapeLayer
  
  init(model: PointModel) {
    state = KnobViewState(model: model)
    layer = CAShapeLayer()
    layer.fillColor = KnobViewClass.color.cgColor
    render(state: state)
  }
}
