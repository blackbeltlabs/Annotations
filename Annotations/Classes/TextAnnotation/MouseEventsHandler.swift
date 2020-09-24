import Cocoa

class MouseEventsHandler {
  unowned var textContainerView: TextContainerView!
    
  var textView: NSTextView! {
    textContainerView.textView
  }
  
  
  private var cursorHelper = CursorHelper()
  
  private var lastMouseLocation: NSPoint?
  

  func mouseDown(with event: NSEvent) {
    let mouseLocation = textContainerView.convert(event.locationInWindow, from: nil)
    
    guard let transformState = mouseDownState(location: mouseLocation) else { return }
    
    switch transformState {
    case .move:
      if textContainerView.state == .inactive {
        textContainerView.state = .active
      }
    default:
      break
    }
  
    
    self.textContainerView.transformState = transformState
    
    lastMouseLocation = event.locationInWindow
    print("mouse down = \(mouseLocation)")
  }
  
  func mouseDragged(with event: NSEvent) {
    guard let difference = getDifference(with: event,
                                         lastMouseLocation: lastMouseLocation) else {
                                          return
    }
    
    self.lastMouseLocation = event.locationInWindow
  
    switch textContainerView.transformState {
    case .resize(let type):
      textContainerView.resize(distance: difference.width, type: type)
     // cursorHelper.resizeCursor.set()
    case .move:
      textContainerView.move(difference: difference)
   //   cursorHelper.moveCursor.set()
    case .scale:
      textContainerView.scale(distance: difference.height)
   //   cursorHelper.scaleCursor.set()
    default:
      return
    }
  }
    
  func mouseUp(with event: NSEvent) {
    switch textContainerView.transformState {
    case .scale:
      textContainerView.reduceWidthIfNeeded()
      textContainerView.reduceHeightIfNeeded()
    default:
      break
    }
    
    // add to history if needed
    if textContainerView.transformState != nil {
      textContainerView.notifyAboutTextAnnotationUpdates()
    }
    
    textContainerView.transformState = nil
  }
    
  public func mouseDownState(location: NSPoint) -> TextAnnotationTransformState? {
    if textView.frame.contains(location) {
      return .move
    } else if textContainerView.leftKnobView.frame.contains(location) {
      return .resize(type: .leftToRight)
    } else if textContainerView.rightKnobView.frame.contains(location) {
      return .resize(type: .rightToLeft)
    } else if textContainerView.scaleKnobView.frame.contains(location) {
      return .scale
    }
    
    return nil
  }
  
  private func getDifference(with event: NSEvent,
                             lastMouseLocation: NSPoint?) -> CGSize? {
    guard let lastMouseLocation = lastMouseLocation else {
      return nil
    }

    let locationInWindow = event.locationInWindow
    return CGSize(width: locationInWindow.x - lastMouseLocation.x,
                  height: locationInWindow.y - lastMouseLocation.y)
  }
}
