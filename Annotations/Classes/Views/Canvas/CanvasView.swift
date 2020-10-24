import Cocoa

public protocol CanvasViewDelegate {
  func canvasView(_ canvasView: CanvasView, didUpdateModel model: CanvasModel)
  func canvasView(_ canvasView: CanvasView, didCreateAnnotation annotation: CanvasDrawable)
  func canvasView(_ canvasView: CanvasView, didStartEditing annotation: TextAnnotation)
  func canvasView(_ canvasView: CanvasView, didEndEditing annotation: TextAnnotation)
  func canvasView(_ canvasView: CanvasView, didDeselect annotation: TextAnnotation)
}

public class CanvasView: NSView, ArrowCanvas, PenCanvas, RectCanvas, TextCanvas, ObfuscateCanvas, TextAnnotationCanvas, HighlightCanvas, TextAnnotationDelegate {
  
  public var delegate: CanvasViewDelegate?
  public var textCanvasDelegate: TextAnnotationDelegate?
  
  public var isUserInteractionEnabled: Bool = true {
    didSet {
      if !isUserInteractionEnabled {
        deselectSelectedItem()
      }
    }
  }
  
  public override var isFlipped: Bool { true }
  
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
  public var textStyle: TextParams = TextParams.defaultFont()
  
  // MARK: - Helpers and handlers
  private let canvasViewEventsHandler = CanvasViewEventsHandler()
  
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
    canvasViewEventsHandler.canvasView = self
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
  
  // MARK: - Mouse events
  
  override public func mouseDown(with event: NSEvent) {
    super.mouseDown(with: event)
    
    canvasViewEventsHandler.mouseDown(with: event)
  }
  
  override public func mouseDragged(with event: NSEvent) {
    super.mouseDragged(with: event)
    
    canvasViewEventsHandler.mouseDragged(with: event)
  }
  
  override public func mouseUp(with event: NSEvent) {
    super.mouseUp(with: event)
    
    canvasViewEventsHandler.mouseUp(with: event)
  }
  
  public override func hitTest(_ point: NSPoint) -> NSView? {
    guard isUserInteractionEnabled else {
      return nil
    }
    return super.hitTest(point)
  }
}

extension CanvasView {
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
        redrawTexts(model: text, canvas: self.model)
      case let rect as RectModel:
        redrawRect(model: rect, canvas: model)
      default:
        print("Unknown type")
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
      var params: TextParams = textStyle
      if params.foregroundColor == nil {
        params.foregroundColor = color
      }
      return createTextView(origin: mouseDown, params: params)
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
      guard color != previousColor else { return }
      
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


extension CanvasView {
    var canvasLayer: CALayer {
      return layer!
    }
    
    public func add(_ item: CanvasDrawable) {
      item.addTo(canvas: self)
      items.append(item)
      
      delegate?.canvasView(self, didCreateAnnotation: item)
    }
    
    public func update(model: CanvasModel) {
      self.model = model
      redraw()
    }
}


// MARK: - Editable
extension CanvasView {
  func didUpdate(selectedItem: CanvasDrawable?, oldValue: CanvasDrawable?) {
    oldValue?.isSelected = false
  }
  
  public func deleteSelectedItem() {
    if let selectedItem = selectedItem {
      let newModel = delete(item: selectedItem)
      update(model: newModel)
      delegate?.canvasView(self, didUpdateModel: newModel)
      return
    }
    
    if let selectedTextAnnotation = selectedTextAnnotation {
      selectedTextAnnotation.delete()
      self.selectedTextAnnotation = nil
    }
  }
  
  public func deselectSelectedItem() {
    selectedItem = nil
    selectedTextAnnotation?.deselect()
    selectedTextAnnotation = nil
  }
  
  func itemAt(point: PointModel) -> CanvasDrawable? {
    return items.first(where: { (item) -> Bool in
      return item.contains(point: point)
    })
  }
}
