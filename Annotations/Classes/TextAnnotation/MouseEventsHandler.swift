import Cocoa

class MouseEventsHandler {
  
  // MARK: - Dependencies
  weak var textContainerView: TextContainerView?
    
  private var textView: NSTextView? {
    textContainerView?.textView
  }
  
  // MARK: - Helpers
  private var cursorHelper = CursorHelper()
  
  // MARK: - Properties
  private var lastMouseLocation: NSPoint?
  

  // MARK: - Mouse events
  func mouseDown(with event: NSEvent) {
    guard let textContainerView = self.textContainerView else { return }
    
    let mouseLocation = textContainerView.convert(event.locationInWindow, from: nil)
    
    guard let transformState = mouseDownState(location: mouseLocation) else { return }
    
    switch transformState {
    case .move:
      if textContainerView.state == .inactive {
        textContainerView.state = .active
      }
    default:
      // ignore other mouse down events if textContainerView state is inactive
      if textContainerView.state == .inactive {
        return
      }
      break
    }
  
    self.textContainerView?.transformState = transformState
    
    lastMouseLocation = event.locationInWindow
  }
  
  func mouseDragged(with event: NSEvent) {
    guard let textContainerView = self.textContainerView else { return }

    guard let difference = getDifference(with: event,
                                         lastMouseLocation: lastMouseLocation) else {
                                          return
    }
    
    self.lastMouseLocation = event.locationInWindow
  
    switch textContainerView.transformState {
    case .resize(let type):
      textContainerView.resize(distance: difference.width, type: type)
    case .move:
      textContainerView.move(difference: difference)
    case .scale:
      textContainerView.scale(distance: difference.height)
    default:
      return
    }
  }
    
  func mouseUp(with event: NSEvent) {
    guard let textContainerView = self.textContainerView else { return }

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
    guard let textContainerView = self.textContainerView,
          let textView = self.textView else { return nil }

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
  
  // MARK: - Private
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
