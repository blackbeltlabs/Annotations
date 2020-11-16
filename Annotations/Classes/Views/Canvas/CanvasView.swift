import Cocoa

public enum CanvasViewTransformAction {
  case resize
  case move
}

public protocol CanvasViewDelegate: class {
  func canvasView(_ canvasView: CanvasView, didUpdateModel model: CanvasModel)
  func canvasView(_ canvasView: CanvasView, didCreateAnnotation annotation: CanvasDrawable)
  func canvasView(_ canvasView: CanvasView, didStartEditing annotation: TextAnnotation)
  func canvasView(_ canvasView: CanvasView, didEdit annotation: TextAnnotation)
  func canvasView(_ canvasView: CanvasView, didEndEditing annotation: TextAnnotation)
  func canvasView(_ canvasView: CanvasView, didDeselect annotation: TextAnnotation)
  func canvasView(_ canvasView: CanvasView,
                  didTransform annotation: CanvasDrawable,
                  action: CanvasViewTransformAction)
  
  func canvasView(_ canvasView: CanvasView, emojiPickerPresentationStateChanged state: Bool)
}

public class CanvasView: NSView, ArrowCanvas, PenCanvas, RectCanvas, TextCanvas, ObfuscateCanvas, TextAnnotationCanvas, HighlightCanvas, TextAnnotationDelegate, ObfuscateViewDelegate {
  
  public weak var delegate: CanvasViewDelegate?
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
      oldValue?.isSelected = false
      
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
  public var textExperimentalSettings: Bool = false
  public var enableEmojies: Bool = true
  
  // MARK: - Helpers and handlers
  private let canvasViewEventsHandler = CanvasViewEventsHandler()
  private let imageHelper = ImageHelper()
  private let imageColorsCalculator = ImageColorsCalculator()
    
  var obfuscateLayer: CALayer = CALayer()
  var obfuscateCanvasLayer: CALayer = CALayer() // palette layer
  var obfuscateMaskLayers: CALayer = CALayer() // obfuscate views are added here to be a mask of canvas layer
  
  // MARK: - Initializers
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    
    setup()
  }
  
  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
    
    setup()
  }
  
  private func setup() {
    wantsLayer = true
    canvasViewEventsHandler.canvasView = self
    
    layer?.addSublayer(obfuscateLayer)
    obfuscateLayer.addSublayer(obfuscateCanvasLayer)
    // obfuscate views are mask of obfuscateCanvasLayer
    obfuscateCanvasLayer.mask = obfuscateMaskLayers
  }
  
  // MARK: - Tracking areas
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
  
  public override func layout() {
    super.layout()
    obfuscateLayer.frame = self.frame
    obfuscateCanvasLayer.frame = self.frame
    
    // fallback in case if obfuscate palette image will not be generated later for some reason
    if obfuscateCanvasLayer.contents == nil {
      obfuscateCanvasLayer.contents = obfuscateFallbackImage(size: frame.size,
                                                             .black)
    }
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
  
  // MARK: - Create item
  // create with mouse down event if possible (texts only)
  public func createItem(mouseDown: PointModel, color: ModelColor) -> CanvasDrawable? {
    switch createMode {
    case .text:
      var params: TextParams = textStyle
      if params.foregroundColor == nil {
        params.foregroundColor = color
      }
      return createTextView(origin: mouseDown,
                            params: params)
    default:
      return nil
    }
  }
  
  // create with mouse dragged event if possible (all except texts)
  public func createItem(dragFrom: PointModel,
                         to: PointModel,
                         color: ModelColor) -> (CanvasDrawable?, KnobView?) {
    switch createMode {
    case .text:
      return (nil, nil)
    case .arrow:
      return createArrowView(origin: dragFrom, to: to, color: color)
    case .rect:
      return createRectView(origin: dragFrom, to: to, color: color)
    case .obfuscate:
      return createObfuscateView(origin: dragFrom, to: to, color: color)
    case .pen:
      return createPenView(origin: dragFrom, to: to, color: color)
    case .highlight:
      return createHighlightView(origin: dragFrom, to: to, color: color, size: frame.size)
    }
  }
  
  public func add(_ item: CanvasDrawable) {
    item.addTo(canvas: self)
    items.append(item)
    
    delegate?.canvasView(self, didCreateAnnotation: item)
  }
  
  // MARK: - Delete item
  public func delete(item: CanvasDrawable) -> CanvasModel {
    switch item {
    case let arrow as ArrowView:
      return delete(arrow: arrow)
    case let obfuscate as ObfuscateView:
      return delete(obfuscate: obfuscate)
    case let rect as RectView:
      return delete(rect: rect)
    case let pen as PenView:
      return delete(pen: pen)
    case let highlight as HighlightView:
      return delete(highlight: highlight)
    default:
      return model
    }
  }
  
  public func deleteSelectedItem() {
    if let selectedItem = selectedItem {
      let newModel = delete(item: selectedItem)
      update(model: newModel)
      delegate?.canvasView(self, didUpdateModel: newModel)
    } else if let selectedTextAnnotation = selectedTextAnnotation {
      selectedTextAnnotation.delete()
      self.selectedTextAnnotation = nil
    }
  }
  
  // MARK: - Select / deselect
  public func deselectSelectedItem() {
    selectedItem = nil
    selectedTextAnnotation?.deselect()
    selectedTextAnnotation = nil
  }
  
  // MARK: - Part Updates
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
  
  // MARK: - Render
  
  public func update(model: CanvasModel) {
    self.model = model
    redraw()
  }
  
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
  
  var canvasLayer: CALayer {
    return layer!
  }
}

// MARK: - Text annotations
extension CanvasView {
  public var isSelectedTextAnnotation: Bool {
    return selectedTextAnnotation != nil
  }
  
  public func deselectTextAnnotation() {
    guard let selectedTextAnnotation = self.selectedTextAnnotation else { return }
    selectedTextAnnotation.deselect()
    self.selectedTextAnnotation = nil
    
    delegate?.canvasView(self, didDeselect: selectedTextAnnotation)
  }
}

// MARK: - Obfuscate views

extension CanvasView {
  
  // pass image that is under annotations
  public func setAnnotationsImage(_ image: NSImage) {
    DispatchQueue.global().async {
      let colors = self.imageColorsCalculator.mostUsedColors(from: image,
                                                             count: 5)
      DispatchQueue.main.async {
        self.updateObfuscateCanvas(with: colors)
      }
    }
  }
  
  func updateObfuscateCanvas(with colors: [NSColor]) {
    let image = generateObfuscatePaletteImage(size: obfuscateCanvasLayer.bounds.size,
                                              colorPalette: colors)
    if let image = image {
      obfuscateCanvasLayer.contents = image
    } else {
      // fallback with black color in case if image generation failed
      obfuscateCanvasLayer.contents = obfuscateFallbackImage(size: obfuscateCanvasLayer.bounds.size,
                                                             .black)
    }
  }
}
