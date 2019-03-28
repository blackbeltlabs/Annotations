//
//  CanvasViewClass.swift
//  Zappy Arrow Annotation
//
//  Created by Mirko on 1/6/19.
//  Copyright © 2019 Blackbelt Labs. All rights reserved.
//

import Cocoa

public class CanvasViewClass: NSView, CanvasView, EditableCanvasView, ArrowCanvas, PenCanvas {
  public var delegate: CanvasViewDelegate?
  
  public var model: CanvasModel = .empty
  public var isChanged: Bool = false
  
  public var createMode: CanvasItemType = .arrow
  
  public var items: [CanvasDrawable] = []
  
  var trackingArea: NSTrackingArea?
  var arrowLayers: [CAShapeLayer] = []
  public var selectedItem: CanvasDrawable? {
    didSet {
      didUpdate(selectedItem: selectedItem, oldValue: oldValue)
    }
  }
  
  public var selectedKnob: KnobView?
  public var lastDraggedPoint: PointModel?
  
  public var view: NSView { return self }
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    
    setup()
  }
  
  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
    
    setup()
  }
  
  func setup() {
    wantsLayer = true
  }
  
  override public func updateTrackingAreas() {
    if let trackingArea = trackingArea {
      removeTrackingArea(trackingArea)
    }
    
    let options : NSTrackingArea.Options = [.activeInKeyWindow, .mouseMoved]
    let newTrackingArea = NSTrackingArea(rect: self.bounds, options: options,
                                         owner: self, userInfo: nil)
    self.addTrackingArea(newTrackingArea)
    self.trackingArea = newTrackingArea
  }
  
  override public func mouseDown(with event: NSEvent) {
    let location = eventLocation(event)
    mouseDown(location.pointModel)
  }
  
  override public func mouseDragged(with event: NSEvent) {
    let location = eventLocation(event)
    mouseDragged(location.pointModel)
  }
  
  override public func mouseUp(with event: NSEvent) {
    let location = eventLocation(event)
    mouseUp(location.pointModel)
  }
  
  func eventLocation(_ event: NSEvent) -> CGPoint {
    return convert(event.locationInWindow, from: nil)
  }
}

extension CanvasViewClass {
  public func redraw() {
    items.forEach { $0.removeFrom(canvas: self) }
    items = []
    
    redrawArrows(model: model)
    redrawPens(model: model)
  }
  
  func markState(model: CanvasModel) {
    delegate?.canvasView(self, didUpdateModel: model)
  }
  
  public func createItem(mouseDown: PointModel) -> (CanvasDrawable?, KnobView?) {
    return (nil, nil)
  }
  
  public func createItem(dragFrom: PointModel, to: PointModel) -> (CanvasDrawable?, KnobView?) {
    switch createMode {
    case .arrow: return createArrowView(origin: dragFrom, to: to)
    case .pen: return createPenView(origin: dragFrom, to: to)
    default: return (nil, nil)
    }
  }
  
  public func delete(item: CanvasDrawable) -> CanvasModel {
    switch item {
    case let arrow as ArrowView: return delete(arrow: arrow)
    case let pen as PenView: return delete(pen: pen)
    default: return model
    }
  }
}
