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
    
    // do not allow to transform if text is empty
    guard !textContainerView.text.isEmpty else { return }
    
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
    
    guard let transformState = textContainerView.transformState else { return }
  
    switch transformState {
    case .resize(let type):
      textContainerView.resize(distance: difference.width, type: type)
    case .move:
      textContainerView.move(difference: difference)
    case .scale:
      textContainerView.scale(distance: difference.height)
    }
    
    // update cursor if needed
    guard let cursor = self.cursor(for: transformState) else { return }
    cursor.set()
  }
    
  func mouseUp(with event: NSEvent) {
    guard let textContainerView = self.textContainerView else { return }

    switch textContainerView.transformState {
    case .scale:
      // FIXME: - Ensure that width is reduced correctly and doesn't affect text resizing
      /* textContainerView.reduceWidthIfNeeded() */
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
  
  func mouseMoved(with event: NSEvent) {
    guard let textContainerView = self.textContainerView else { return }
    let mouseLocation = textContainerView.convert(event.locationInWindow, from: nil)
    
    let transformState: TextAnnotationTransformState
    
    // get the correct transform state here (or that already was set or depending on mouse location)
    if let transfState = self.textContainerView?.transformState {
      transformState = transfState
    } else if let transfState = mouseDownState(location: mouseLocation) {
      transformState = transfState
    } else {
      setDefaultCursorWithRect()
      return
    }
    
    // update cursor is needed
    guard let cursor = self.cursor(for: transformState) else { return }
    cursor.set()
  }
  
  
  func mouseExited(with event: NSEvent) {
    guard let textContainerView = textContainerView else { return }
    if textContainerView.transformState == nil {
      setDefaultCursorWithRect()
    }
  }
  
  func cursorRectsReseted() {
    guard let textContainerView = self.textContainerView else { return }
    
    guard let transformState = textContainerView.transformState else {
      setDefaultCursorWithRect()
      return
    }
    
    // set cursor for the cursor rect depending on transform state
    guard let cursor = self.cursor(for: transformState) else { return }
    textContainerView.addCursorRect(textContainerView.bounds, cursor: cursor)
    
    cursor.set()
  }
  
  private func setDefaultCursorWithRect() {
    if let textContainerView = self.textContainerView {
    textContainerView.addCursorRect(textContainerView.bounds, cursor:  cursorHelper.defaultCursor)
    }
    cursorHelper.defaultCursor.set()
  }
  
  public func mouseDownState(location: NSPoint) -> TextAnnotationTransformState? {
    guard let textContainerView = self.textContainerView,
          let textView = self.textView else { return nil }

    if textContainerView.leftKnobView.frame.contains(location) {
      return .resize(type: .leftToRight)
    } else if textContainerView.rightKnobView.frame.contains(location) {
      return .resize(type: .rightToLeft)
    } else if textContainerView.scaleKnobView.frame.contains(location) {
      return .scale
    } else if textView.frame.contains(location) {
      return .move
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
  
  private func cursor(for transformState: TextAnnotationTransformState) -> NSCursor? {
    switch transformState {
    case .resize(_):
      return cursorHelper.resizeCursor
    case .move:
      guard textContainerView?.state == .active else { return nil }
      return cursorHelper.moveCursor
    case .scale:
      return cursorHelper.scaleCursor
    }
  }
    
}
