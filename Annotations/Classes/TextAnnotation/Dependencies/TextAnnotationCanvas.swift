import Cocoa

public protocol TextAnnotationCanvas: ActivateResponder where Self: TextAnnotationDelegate {
  var view: NSView { get }
  var textAnnotations: [TextAnnotation] { get set }
  var selectedTextAnnotation: TextAnnotation? { get set }
  var lastMouseLocation: NSPoint? { get set }
  var enableEmojies: Bool { get }
}

extension TextAnnotationCanvas {
  func set(selectedTextAnnotation: TextAnnotation?) {
    if self.selectedTextAnnotation === selectedTextAnnotation {
      return
    }
    
    if let lastSelection = self.selectedTextAnnotation {
      lastSelection.state = .inactive
    }
    
    self.selectedTextAnnotation = selectedTextAnnotation
  }
  
  public func createTextAnnotation(text: String,
                                   location: CGPoint,
                                   textParams: TextParams) -> TextAnnotation {
    let annotation = TextContainerView(frame: NSRect(origin: location, size: CGSize.zero),
                                       text: text,
                                       textParams: textParams,
                                       legibilityEffectEnabled: false,
                                       enableEmojies: enableEmojies)
    
    // some offset for new created annotations
    if text.isEmpty {
      annotation.frame.origin.y -= annotation.frame.size.height / 2
      annotation.frame.origin.x -= annotation.decParams.knobSide / 2
    }

    annotation.activateResponder = self
    annotation.state = .active
    
    return annotation
  }
  
  public func createTextAnnotation(modelable: TextAnnotationModelable) -> TextAnnotation {
    let annotation = TextContainerView(modelable: modelable, enableEmojies: enableEmojies)
    
    annotation.activateResponder = self
    
    annotation.state = .inactive
    
    return annotation
    
  }
  
  public func add(textAnnotation: TextAnnotation) {
    view.addSubview(textAnnotation)
    
    textAnnotations.append(textAnnotation)
    
    set(selectedTextAnnotation: textAnnotation)
  }
  
  public func textAnnotationCanvasMouseDown(event: NSEvent) {
    let screenPoint = event.locationInWindow
    
    var annotationToActivate: TextAnnotation?
    for annotation in textAnnotations {
      let locationInView = view.convert(screenPoint, to: annotation)
      
      if annotation.frame.contains(locationInView) {
        annotationToActivate = annotation
        break
      }
    }
		
    if annotationToActivate == nil {
      set(selectedTextAnnotation: nil)
    }
  }
  
  public func setTextExperimentalSettings(enabled: Bool) {
    TextContainerView.experimentalSettings = enabled
  }
}

// ActivateResponder
extension TextAnnotationCanvas {
  public func textViewDidActivate(_ activeItem: Any?) {
    guard let anActiveItem = activeItem as? TextContainerView else { return }
    set(selectedTextAnnotation: anActiveItem)
  }
}
