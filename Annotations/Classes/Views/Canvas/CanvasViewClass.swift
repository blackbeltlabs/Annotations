//
//  CanvasViewClass.swift
//  Zappy Arrow Annotation
//
//  Created by Mirko on 1/6/19.
//  Copyright © 2019 Blackbelt Labs. All rights reserved.
//

import Cocoa
import TextAnnotation

public class CanvasViewClass: NSView, CanvasView, EditableCanvasView, ArrowCanvas, PenCanvas, RectCanvas, TextCanvas, ObfuscateCanvas, TextAnnotationCanvas, HighlightCanvas, TextAnnotationDelegate {
  public var delegate: CanvasViewDelegate?
  public var textCanvasDelegate: TextAnnotationDelegate?
  
  public var isUserInteractionEnabled: Bool = true {
    didSet {
      if !isUserInteractionEnabled {
        deselectSelectedItem()
      }
    }
  }
  
  public var model = CanvasModel()
  public var isChanged: Bool = false
  
  public var createMode: CanvasItemType = .arrow
  public var createColor: ModelColor = ModelColor.defaultColor() {
    didSet {
      updateSelectedItemColor(createColor)
    }
  }
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
  
  // MARK: - Initializers
  
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
  
  // MARK: - Actions
  
  override public func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)
    
    let location = eventLocation(event)
    
    if mouseDown(location.pointModel) {
      return
    }
    
    if selectedTextAnnotation == nil && createMode == .text {
//      let textAnnotation = addTextAnnotation(text: "", location: location)
//      textAnnotation.delegate = self  
//      textAnnotation.startEditing()
    } else {
      deselectTextAnnotation()
    }
  }
  
  override public func mouseDragged(with event: NSEvent) {
    super.mouseDragged(with: event)
    
    let location = eventLocation(event)
    mouseDragged(location.pointModel)
  }
  
  override public func mouseUp(with event: NSEvent) {
    super.mouseUp(with: event)
    
    let location = eventLocation(event)
    mouseUp(location.pointModel)
  }
  
  func eventLocation(_ event: NSEvent) -> CGPoint {
    return convert(event.locationInWindow, from: nil)
  }
  
  public override func hitTest(_ point: NSPoint) -> NSView? {
    guard isUserInteractionEnabled else {
      return nil
    }
    return super.hitTest(point)
  }
}

extension CanvasViewClass {
  public func redraw() {
		
    items.forEach { $0.removeFrom(canvas: self) }
    items = []
    
    let elements = model.elementsSorted
    
    for element in elements {
      switch element {
      case let highlight as HighlightModel:
        redrawHighlight(model: highlight, canvas: model)
      case let arrow as ArrowModel:
        redrawArrow(model: arrow, canvas: model)
      case let pen as PenModel:
        redrawPen(model: pen, canvas: model)
      case let obfuscate as ObfuscateModel:
        redrawObfuscate(model: obfuscate, canvas: model)
      case let text as TextModel:
        redrawTexts(model: text, canvas: model)
      case let rect as RectModel:
        redrawRect(model: rect, canvas: model)
      default:
        print("Uknown type")
      }
    }
    
    selectedItem = nil
    selectedTextAnnotation = nil
  }
  
  func markState(model: CanvasModel) {
    delegate?.canvasView(self, didUpdateModel: model)
  }
  
  // MARK: - Create item
  public func createItem(mouseDown: PointModel, color: ModelColor) -> CanvasDrawable? {
    switch createMode {
    case .text:
      return createTextView(origin: mouseDown, color: color)
    default:
      return nil
    }
  }
  
  public func createItem(dragFrom: PointModel, to: PointModel, color: ModelColor) -> (CanvasDrawable?, KnobView?) {
    switch createMode {
    case .text: return (nil, nil)
    case .arrow: return createArrowView(origin: dragFrom, to: to, color: color)
    case .rect: return createRectView(origin: dragFrom, to: to, color: color)
    case .obfuscate: return createObfuscateView(origin: dragFrom, to: to, color: color)
    case .pen: return createPenView(origin: dragFrom, to: to, color: color)
    case .highlight: return createHighlightView(origin: dragFrom, to: to, color: color, size: frame.size)
    }
  }
  
  // MARK: - Delete item
  
  public func delete(item: CanvasDrawable) -> CanvasModel {
    switch item {
    case let arrow as ArrowView: return delete(arrow: arrow)
    case let obfuscate as ObfuscateView: return delete(obfuscate: obfuscate)
    case let rect as RectView: return delete(rect: rect)
    case let pen as PenView: return delete(pen: pen)
    case let highlight as HighlightView: return delete(highlight: highlight)
    default: return model
    }
  }
  
  // MARK: - Text annotation
  
  public var isSelectedTextAnnotation: Bool {
    return selectedTextAnnotation != nil
  }
  
  public func deselectTextAnnotation() {
    guard let selectedTextAnnotation = self.selectedTextAnnotation else { return }
    selectedTextAnnotation.deselect()
    self.selectedTextAnnotation = nil
    
    delegate?.canvasView(self, didDeselect: selectedTextAnnotation)
  }
  
  // MARK: - Update items color
  
  public func updateSelectedItemColor(_ color: ModelColor) {
    if let selectedTextAnnotation = selectedTextAnnotation {
      
      let previousColor = selectedTextAnnotation.textColor
      guard color.textColor != previousColor else { return }
      
      selectedTextAnnotation.updateColor(with: NSColor.color(from: color))
      
    } else if let selectedItem = selectedItem {
      guard let selectedItemColor = selectedItem.color else { return }
      
      let previousColor = selectedItemColor.annotationModelColor
      guard previousColor != color else { return }
            
      selectedItem.updateColor(NSColor.color(from: color))
      
      delegate?.canvasView(self, didUpdateModel: model)
      
    }
    
  }
}
