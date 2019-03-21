//
//  Canvas.swift
//  Annotate
//
//  Created by Mirko on 12/27/18.
//  Copyright © 2018 Blackbelt Labs. All rights reserved.
//

import Cocoa
import CoreGraphics

public protocol CanvasViewDelegate {
  func canvasView(_ canvasView: CanvasView, didUpdateModel model: CanvasModel)
}

public protocol CanvasView: class {
  var delegate: CanvasViewDelegate? { get set }
  var model: CanvasModel { get set }
  var view: NSView { get }
  var layer: CALayer? { get }
  var items: [CanvasDrawable] { get set }
  
  func redraw()
}

extension CanvasView {
  var canvasLayer: CALayer {
    return layer!
  }
  
  public func add(_ item: CanvasDrawable) {
    item.addTo(canvas: self)
    items.append(item)
  }
  
  public func update(model: CanvasModel) {
    self.model = model
    redraw()
  }
}

