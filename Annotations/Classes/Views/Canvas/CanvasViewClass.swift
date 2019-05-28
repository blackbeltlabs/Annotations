//
//  CanvasViewClass.swift
//  Zappy Arrow Annotation
//
//  Created by Mirko on 1/6/19.
//  Copyright © 2019 Blackbelt Labs. All rights reserved.
//

import Cocoa
import TextAnnotation

public class CanvasViewClass: NSView, CanvasView, EditableCanvasView, ArrowCanvas, PenCanvas, RectCanvas, TextCanvas {
  public var delegate: CanvasViewDelegate?
  public var textCanvasDelegate: TextAnnotationDelegate?
  
  public var isUserInteractionEnabled: Bool = true {
    didSet {
      if !isUserInteractionEnabled {
        selectedItem = nil
        selectedTextAnnotation?.deselect()
      }
    }
  }
  
  public var model = CanvasModel()
  public var isChanged: Bool = false
  
  public var createMode: CanvasItemType = .arrow
  
  public var items: [CanvasDrawable] = []
  
  var trackingArea: NSTrackingArea?
  var arrowLayers: [CAShapeLayer] = []
  public var selectedItem: CanvasDrawable? {
    didSet {
      didUpdate(selectedItem: selectedItem, oldValue: oldValue)
      
      if selectedItem != nil {
        selectedTextAnnotation?.deselect()
        selectedTextAnnotation = nil
      }
    }
  }
  
  public var selectedKnob: KnobView?
  public var lastDraggedPoint: PointModel?
  
  public var view: NSView { return self }
  
  // TextAnnotation support
  public var textAnnotations: [TextAnnotation] = []
  public var selectedTextAnnotation: TextAnnotation?
  public var lastMouseLocation: NSPoint?
  
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
    
    if mouseDown(location.pointModel) {
      return
    }
    
    if selectedTextAnnotation == nil && createMode == .text {
//      let textAnnotation = addTextAnnotation(text: "", location: location)
//      textAnnotation.delegate = self  
//      textAnnotation.startEditing()
    } else {
      selectedTextAnnotation?.deselect()
      selectedTextAnnotation = nil
    }
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
    items.forEach {
      guard $0.modelType != .text else { return }
      $0.removeFrom(canvas: self)
    }
    items = []
    
    redrawArrows(model: model)
    redrawPens(model: model)
    redrawRects(model: model)
  }
  
  func markState(model: CanvasModel) {
    delegate?.canvasView(self, didUpdateModel: model)
  }
  
  public func createItem(mouseDown: PointModel) -> CanvasDrawable? {
    switch createMode {
    case .text:
      return createTextView(origin: mouseDown)
    default:
      return nil
    }
  }
  
  public func createItem(dragFrom: PointModel, to: PointModel) -> (CanvasDrawable?, KnobView?) {
    switch createMode {
    case .text: return (nil, nil)
    case .arrow: return createArrowView(origin: dragFrom, to: to)
    case .rect: return createRectView(origin: dragFrom, to: to)
    case .pen: return createPenView(origin: dragFrom, to: to)
    }
  }
  
  public func delete(item: CanvasDrawable) -> CanvasModel {
    switch item {
    case let arrow as ArrowView: return delete(arrow: arrow)
    case let rect as RectView: return delete(rect: rect)
    case let pen as PenView: return delete(pen: pen)
    default: return model
    }
  }
}
